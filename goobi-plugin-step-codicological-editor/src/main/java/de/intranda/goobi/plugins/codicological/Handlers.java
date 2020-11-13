package de.intranda.goobi.plugins.codicological;

import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.TreeMap;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.apache.commons.configuration.SubnodeConfiguration;
import org.apache.commons.configuration.XMLConfiguration;
import org.apache.commons.configuration.tree.xpath.XPathExpressionEngine;
import org.goobi.beans.Process;
import org.goobi.beans.Ruleset;
import org.goobi.vocabulary.Vocabulary;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import de.intranda.goobi.plugins.CodicologicalEditor;
import de.intranda.goobi.plugins.codicological.model.Box;
import de.intranda.goobi.plugins.codicological.model.Column;
import de.intranda.goobi.plugins.codicological.model.Field;
import de.intranda.goobi.plugins.codicological.model.FieldValue;
import de.intranda.goobi.plugins.codicological.model.GroupMapping;
import de.intranda.goobi.plugins.codicological.model.GroupValue;
import de.intranda.goobi.plugins.codicological.model.ImagesResponse;
import de.intranda.goobi.plugins.codicological.model.Mapping;
import de.sub.goobi.config.ConfigPlugins;
import de.sub.goobi.helper.exceptions.DAOException;
import de.sub.goobi.helper.exceptions.SwapException;
import de.sub.goobi.persistence.managers.ProcessManager;
import de.sub.goobi.persistence.managers.VocabularyManager;
import spark.Route;
import ugh.dl.DigitalDocument;
import ugh.dl.DocStruct;
import ugh.dl.Fileformat;
import ugh.dl.Metadata;
import ugh.dl.MetadataGroup;
import ugh.dl.MetadataGroupType;
import ugh.dl.MetadataType;
import ugh.dl.Prefs;
import ugh.exceptions.MetadataTypeNotAllowedException;
import ugh.exceptions.PreferencesException;
import ugh.exceptions.ReadException;
import ugh.exceptions.WriteException;

public class Handlers {
    private static Gson gson = new Gson();
    private static Type columnListType = TypeToken.getParameterized(List.class, Column.class).getType();

    public static Route allVocabs = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        List<Column> colList = readColsFromConfig(conf);
        Map<String, Vocabulary> vocabMap = new TreeMap<>();
        for (Column col : colList) {
            for (Box box : col.getBoxes()) {
                for (Field field : box.getFields()) {
                    for (String vocabName : field.getSourceVocabularies()) {
                        if (vocabName != null && !vocabMap.containsKey(vocabName)) {
                            Vocabulary vocab = VocabularyManager.getVocabularyByTitle(vocabName);
                            VocabularyManager.getAllRecords(vocab);
                            vocabMap.put(vocabName, vocab);
                        }
                    }
                    for (GroupMapping gm : field.getGroupMappings()) {
                        String vocabName = gm.getSourceVocabulary();
                        if (vocabName != null && !vocabMap.containsKey(vocabName)) {
                            Vocabulary vocab = VocabularyManager.getVocabularyByTitle(vocabName);
                            if (vocab != null) {
                                VocabularyManager.getAllRecords(vocab);
                                vocabMap.put(vocabName, vocab);
                            }
                        }
                    }
                }
            }
        }
        return vocabMap;
    };

    public static Route getMetadata = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        List<Column> colList = readColsFromConfig(conf);
        mergeMetadata(colList, Integer.parseInt(req.params("processid")));
        return colList;
    };

    public static Route getImages = (req, res) -> {
        int processId = Integer.parseInt(req.params("processid"));
        Process p = ProcessManager.getProcessById(processId);
        Path imDir = Paths.get(p.getImagesTifDirectory(false));
        if (Files.exists(imDir)) {
            String[] files = imDir.toFile().list();
            Arrays.sort(files);
            return new ImagesResponse("media", files);
        }
        imDir = Paths.get(p.getImagesOrigDirectory(false));
        String[] files = imDir.toFile().list();
        Arrays.sort(files);
        return new ImagesResponse("orig", files);
    };

    public static Route saveMets = (req, res) -> {
        List<Column> userInput = gson.fromJson(req.body(), columnListType);
        int processId = Integer.parseInt(req.params("processid"));
        Process p = ProcessManager.getProcessById(processId);
        saveMetadata(userInput, p);
        return "";
    };

    private static List<Column> readColsFromConfig(XMLConfiguration conf) {
        conf.setExpressionEngine(new XPathExpressionEngine());
        List<Column> colList = new ArrayList<>();
        SubnodeConfiguration col1Conf = conf.configurationAt("//column[1]");
        SubnodeConfiguration col2Conf = conf.configurationAt("//column[2]");
        SubnodeConfiguration col3Conf = conf.configurationAt("//column[3]");
        colList.add(Column.fromConfig(col1Conf));
        colList.add(Column.fromConfig(col2Conf));
        colList.add(Column.fromConfig(col3Conf));
        return colList;
    }

    private static void saveMetadata(List<Column> userInput, Process p) throws ReadException, PreferencesException, WriteException, IOException,
            InterruptedException, SwapException, DAOException, MetadataTypeNotAllowedException {
        Ruleset ruleset = p.getRegelsatz();
        Prefs prefs = ruleset.getPreferences();
        Fileformat ff = p.readMetadataFile();
        DigitalDocument dd = ff.getDigitalDocument();
        DocStruct ds = dd.getLogicalDocStruct();
        //we need to do this, so we don't read the metadata from the anchor
        if (ds.getType().isAnchor()) {
            ds = ds.getAllChildren().get(0);
        }
        for (Column col : userInput) {
            for (Box box : col.getBoxes()) {
                for (Field field : box.getFields()) {
                    if (field.isMultiVocabulary()) {
                        Set<String> allGroups = field.getGroupMappings()
                                .stream()
                                .map(GroupMapping::getGroupName)
                                .collect(Collectors.toSet());
                        //delete all groups managed by this field
                        for (String groupName : allGroups) {
                            MetadataGroupType mdgt = prefs.getMetadataGroupTypeByName(groupName);
                            for (MetadataGroup metadataGroup : ds.getAllMetadataGroupsByType(mdgt)) {
                                ds.removeMetadataGroup(metadataGroup, true);
                            }
                        }
                        for (FieldValue fv : field.getValues()) {
                            GroupValue groupValue = fv.getGroupValue();
                            Map<String, String> vocabNameToMdt = field.getGroupMappings()
                                    .stream()
                                    .filter(gm -> gm.getSourceVocabulary().equals(groupValue.getSourceVocabulary()))
                                    .flatMap(gm -> gm.getMappings().stream())
                                    .collect(Collectors.toMap(Mapping::getVocabularyName, Mapping::getMetadataType));
                            MetadataGroupType mdgt = prefs.getMetadataGroupTypeByName(groupValue.getGroupName());
                            MetadataGroup newGroup = new MetadataGroup(mdgt);
                            for (String vocabName : groupValue.getValues().keySet()) {
                                MetadataType mdt = prefs.getMetadataTypeByName(vocabNameToMdt.get(vocabName));
                                Metadata metadata = new Metadata(mdt);
                                newGroup.addMetadata(metadata);
                            }
                            ds.addMetadataGroup(newGroup);
                        }
                    } else {
                        String fieldMdt = field.getMetadatatype();
                        if (fieldMdt == null || "unknown".equals(fieldMdt)) {
                            continue;
                        }
                        //look up metadata of top DS and write value(s) to field
                        MetadataType mdt = prefs.getMetadataTypeByName(fieldMdt);
                        if (mdt == null) {
                            throw new PreferencesException(String.format("There is no MetadataType with name '%s' in the rulest", fieldMdt));
                        }
                        @SuppressWarnings("unchecked")
                        List<Metadata> metadataList = (List<Metadata>) ds.getAllMetadataByType(mdt);
                        List<FieldValue> fieldValues = field.getValues();
                        int maxListLen = Math.max(metadataList.size(), fieldValues.size());
                        for (int i = 0; i < maxListLen; i++) {
                            //TODO: not sure if this works, better check...
                            if (i >= fieldValues.size()) {
                                ds.removeMetadata(metadataList.get(i));
                                continue;
                            }
                            if (i >= metadataList.size()) {
                                Metadata newMeta = new Metadata(mdt);
                                newMeta.setValue(fieldValues.get(i).getValue());
                                ds.addMetadata(newMeta);
                                continue;
                            }
                            Metadata oldMeta = metadataList.get(i);
                            oldMeta.setValue(fieldValues.get(i).getValue());
                        }
                    }
                }
            }
        }
        p.writeMetadataFile(ff);
    }

    private static void mergeMetadata(List<Column> colList, int processId)
            throws ReadException, PreferencesException, WriteException, IOException, InterruptedException, SwapException, DAOException {
        Process p = ProcessManager.getProcessById(processId);
        if (p == null) {
            return;
        }
        Ruleset ruleset = p.getRegelsatz();
        Prefs prefs = ruleset.getPreferences();
        Fileformat ff = p.readMetadataFile();
        DigitalDocument dd = ff.getDigitalDocument();
        DocStruct ds = dd.getLogicalDocStruct();
        //we need to do this, so we don't read the metadata from the anchor
        if (ds.getType().isAnchor()) {
            ds = ds.getAllChildren().get(0);
        }
        for (Column col : colList) {
            for (Box box : col.getBoxes()) {
                for (Field field : box.getFields()) {
                    if (field.isMultiVocabulary()) {
                        Map<String, GroupMapping> metadataGroupToGroupMapping = field.getGroupMappings()
                                .stream()
                                .collect(Collectors.toMap(GroupMapping::getGroupName, Function.identity()));
                        List<MetadataGroup> groups = Optional
                                .ofNullable(ds.getAllMetadataGroups())
                                .orElse(new ArrayList<>());
                        for (MetadataGroup mdg : groups) {
                            GroupMapping gm = metadataGroupToGroupMapping.get(mdg.getType().getName());
                            if (gm != null) {
                                Map<String, String> values = new HashMap<String, String>();
                                for (Metadata md : mdg.getMetadataList()) {
                                    Optional<String> vocabName = gm.getMappings()
                                            .stream()
                                            .map(Mapping::getMetadataType)
                                            .filter(mdType -> mdType.equals(md.getType().getName()))
                                            .findAny();
                                    if (vocabName.isPresent()) {
                                        values.put(vocabName.get(), md.getValue());
                                    }
                                }
                                GroupValue groupValue = new GroupValue(gm.getGroupName(), gm.getSourceVocabulary(), values);
                                field.getValues().add(new FieldValue(null, groupValue));
                            }
                        }

                    } else {
                        String fieldMdt = field.getMetadatatype();
                        if (fieldMdt == null || "unknown".equals(fieldMdt)) {
                            continue;
                        }
                        //look up metadata of top DS and write value(s) to field
                        MetadataType mdt = prefs.getMetadataTypeByName(fieldMdt);
                        if (mdt == null) {
                            throw new PreferencesException(String.format("There is no MetadataType with name '%s' in the rulest", fieldMdt));
                        }
                        @SuppressWarnings("unchecked")
                        List<Metadata> metadataList = (List<Metadata>) ds.getAllMetadataByType(mdt);
                        if (!metadataList.isEmpty()) {
                            field.setShow(true);
                        }
                        for (Metadata md : metadataList) {
                            String value = md.getValue();
                            field.getValues().add(new FieldValue(value, null));
                        }
                    }
                }
            }
        }

    }
}
