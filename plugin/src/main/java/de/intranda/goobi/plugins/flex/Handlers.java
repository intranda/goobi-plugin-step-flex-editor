package de.intranda.goobi.plugins.flex;

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

import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;

import org.apache.commons.configuration.SubnodeConfiguration;
import org.apache.commons.configuration.XMLConfiguration;
import org.apache.commons.configuration.tree.xpath.XPathExpressionEngine;
import org.apache.commons.lang3.StringUtils;
import org.goobi.beans.Process;
import org.goobi.beans.Ruleset;
import org.goobi.vocabulary.VocabRecord;
import org.goobi.vocabulary.Vocabulary;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import de.intranda.goobi.plugins.FlexEditor;
import de.intranda.goobi.plugins.flex.model.Box;
import de.intranda.goobi.plugins.flex.model.Column;
import de.intranda.goobi.plugins.flex.model.Field;
import de.intranda.goobi.plugins.flex.model.FieldValue;
import de.intranda.goobi.plugins.flex.model.GroupMapping;
import de.intranda.goobi.plugins.flex.model.GroupValue;
import de.intranda.goobi.plugins.flex.model.ImagesResponse;
import de.intranda.goobi.plugins.flex.model.Mapping;
import de.sub.goobi.config.ConfigPlugins;
import de.sub.goobi.config.ConfigurationHelper;
import de.sub.goobi.helper.FacesContextHelper;
import de.sub.goobi.helper.exceptions.DAOException;
import de.sub.goobi.helper.exceptions.SwapException;
import de.sub.goobi.persistence.managers.ProcessManager;
import de.sub.goobi.persistence.managers.VocabularyManager;
import lombok.extern.log4j.Log4j2;
import spark.Route;
import ugh.dl.Corporate;
import ugh.dl.DigitalDocument;
import ugh.dl.DocStruct;
import ugh.dl.Fileformat;
import ugh.dl.Metadata;
import ugh.dl.MetadataGroup;
import ugh.dl.MetadataGroupType;
import ugh.dl.MetadataType;
import ugh.dl.Person;
import ugh.dl.Prefs;
import ugh.exceptions.MetadataTypeNotAllowedException;
import ugh.exceptions.PreferencesException;
import ugh.exceptions.ReadException;
import ugh.exceptions.WriteException;

@Log4j2
public class Handlers {
    private static Gson gson = new Gson();
    private static Type columnListType = TypeToken.getParameterized(List.class, Column.class).getType();

    public static Route allVocabs = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(FlexEditor.title);
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
                        for (Mapping mapping : gm.getMappings()) {
                            String vocabName = mapping.getSourceVocabulary();
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
        }
        return vocabMap;
    };

    public static Route getMetsTranslations = (req, res) -> {
        int processId = Integer.parseInt(req.params("processid"));
        String language = req.params("language");
        Map<String, String> translationMap = new HashMap<>();

        Process process = ProcessManager.getProcessById(processId);
        Prefs prefs = process.getRegelsatz().getPreferences();
        for (MetadataType mdt : prefs.getAllMetadataTypes()) {
            if (mdt.getAllLanguages() != null) {
                translationMap.put(mdt.getName(), mdt.getNameByLanguage(language));
            }
        }

        return translationMap;
    };

    public static Route getMetadata = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(FlexEditor.title);
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
        log.debug("The Route saveMets is called");
        //        log.debug(req.body());
        List<Column> userInput = gson.fromJson(req.body(), columnListType);
        int processId = Integer.parseInt(req.params("processid"));
        Process p = ProcessManager.getProcessById(processId);
        log.debug("setting up httpRequest");
        HttpServletRequest httpRequest = req.raw();
        log.debug("httpRequest is set up");
        saveMetadata(userInput, p, httpRequest);
        return "";
    };

    public static Route newVocabEntry = (req, res) -> {
        String vocabName = req.params("vocabName");
        Vocabulary vocab = VocabularyManager.getVocabularyByTitle(vocabName);
        VocabRecord record = gson.fromJson(req.body(), VocabRecord.class);
        for (int i = 0; i < record.getFields().size(); i++) {
            record.getFields().get(i).setDefinition(vocab.getStruct().get(i));
        }
        VocabularyManager.saveRecord(vocab.getId(), record);
        return record;
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

    private static void saveMetadata(List<Column> userInput, Process p, HttpServletRequest request)
            throws ReadException, PreferencesException, WriteException, IOException,
            InterruptedException, SwapException, DAOException, MetadataTypeNotAllowedException {
        log.debug("saveMetadata is called");

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
                        Map<String, Mapping> metadataTypeToMappingMap = createMetadataTypeToMappingMap(field);
                        //delete all groups managed by this field
                        for (String groupName : allGroups) {
                            MetadataGroupType mdgt = prefs.getMetadataGroupTypeByName(groupName);
                            for (MetadataGroup metadataGroup : ds.getAllMetadataGroupsByType(mdgt)) {
                                ds.removeMetadataGroup(metadataGroup, true);
                            }
                        }
                        for (FieldValue fv : field.getValues()) {
                            GroupValue groupValue = fv.getGroupValue();
                            MetadataGroupType mdgt = prefs.getMetadataGroupTypeByName(groupValue.getGroupName());
                            MetadataGroup newGroup = new MetadataGroup(mdgt);
                            for (String metadataTypeName : groupValue.getValues().keySet()) {
                                log.debug("metadataTypeName = " + metadataTypeName);
                                // newGroup.getMetadataList() will return an empty list, so we have to choose another way:
                                // 1. find out the MetadataType whose name is equal to metadataTypeName
                                // 2. create a Metadata object based on this MetadataType
                                // 3. add this Metadata object to the MetadataGroup newGroup
                                for (MetadataType mdType : newGroup.getAddableMetadataTypes(false)) {
                                    log.debug("mdType = " + mdType.getName());
                                    if (mdType.getName().equals(metadataTypeName)) {
                                        // create a Metadata object based on this MetadataType and add it to the newGroup
                                        if (mdType.getIsPerson()) {
                                            Person person = new Person(mdType);
                                            person.setRole(mdType.getName());
                                            newGroup.addPerson(person);
                                        } else if (mdType.isCorporate()) {
                                            Corporate corporate = new Corporate(mdType);
                                            corporate.setRole(mdType.getName());
                                            newGroup.addCorporate(corporate);
                                        } else {
                                            Metadata metadata = new Metadata(mdType);
                                            newGroup.addMetadata(metadata);
                                        }
                                    }
                                }
                                // ======= REFACTORING NEEDED ======= //
                                for (Metadata groupMd : newGroup.getMetadataList()) {
                                    if (groupMd.getType().getName().equals(metadataTypeName)) {
                                        // fetch records from vocabulary here and set this as AuthorityFile 
                                        String metadataValue = groupValue.getValues().get(metadataTypeName);
                                        Mapping mapping = metadataTypeToMappingMap.get(metadataTypeName);
                                        log.debug("mapping.getMetadataType() = " + mapping.getMetadataType());
                                        log.debug("mapping.getSourceVocabulary() = " + mapping.getSourceVocabulary());
                                        if (mapping.getSourceVocabulary() != null) {
                                            Vocabulary vocab = VocabularyManager.getVocabularyByTitle(mapping.getSourceVocabulary());
                                            log.debug("vocab.getUrl() = " + vocab.getUrl());
                                            log.debug("vocab.getTitle() = " + vocab.getTitle());
                                            log.debug("vocab.getDescription() = " + vocab.getDescription());
                                            log.debug("vocab.getId() = " + vocab.getId());
                                            VocabRecord record = VocabularyManager.getRecord(vocab.getId(), Integer.parseInt(metadataValue));
                                            log.debug("record.getTitle() = " + record.getTitle());
                                            log.debug("record.getId() = " + record.getId());
                                            log.debug("record.getVocabularyId() = " + record.getVocabularyId());
                                            setAuthorityData(groupMd, vocab, record, request);
                                            // groupMd.setAutorityFile("GOOBI_VOCABULARY", vocab.getTitle(), metadataValue);
                                            List<String> titleStrings = record.getFields()
                                                    .stream()
                                                    .filter(f -> f.getDefinition().isTitleField())
                                                    .map(f -> f.getValue())
                                                    .collect(Collectors.toList());
                                            groupMd.setValue(StringUtils.join(titleStrings, " "));
                                        } else {
                                            groupMd.setValue(metadataValue);
                                        }
                                        log.debug(groupMd.getValue());
                                    }
                                }
                            }
                            ds.addMetadataGroup(newGroup);
                        }
                    } else { // !field.isMultiVocabulary()
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

    private static void setAuthorityData(Metadata groupMd, Vocabulary vocab, VocabRecord record, HttpServletRequest request) {
        log.debug("setAuthorityData is called");
        if (StringUtils.isNotBlank(ConfigurationHelper.getInstance().getGoobiAuthorityServerUser())
                && StringUtils.isNotBlank(ConfigurationHelper.getInstance().getGoobiAuthorityServerUrl())) {
            groupMd.setAutorityFile("GOOBI_VOCABULARY",
                    ConfigurationHelper.getInstance().getGoobiAuthorityServerUrl(),
                    ConfigurationHelper.getInstance().getGoobiAuthorityServerUrl()
                            + ConfigurationHelper.getInstance().getGoobiAuthorityServerUser() + "/vocabularies/"
                            + record.getVocabularyId() + "/records/" + record.getId());
        } else {
            FacesContext context = FacesContextHelper.getCurrentFacesContext();
            log.debug("context is" + (context == null ? " " : " NOT ") + "null");
            //            HttpServletRequest request = (HttpServletRequest) context.getExternalContext().getRequest();
            String contextPath = request.getContextPath();
            String scheme = request.getScheme(); // http
            String serverName = request.getServerName(); // hostname.com
            int serverPort = request.getServerPort(); // 80
            String reqUrl = scheme + "://" + serverName + ":" + serverPort + contextPath;
            log.debug("contextPath = " + contextPath);
            log.debug("scheme = " + scheme);
            log.debug("serverName = " + serverName);
            log.debug("serverPort = " + serverPort);
            log.debug("reqUrl = " + reqUrl);
            Client client = ClientBuilder.newClient();
            WebTarget base = client.target(reqUrl);
            WebTarget vocabularyBase = base.path("api").path("vocabulary");
            groupMd.setAutorityFile(vocab.getTitle(), vocabularyBase.getUri().toString(),
                    vocabularyBase.getUri() + "/vocabularies/" + record.getVocabularyId() + "/" + record.getId());
        }
        log.debug("setAuthorityData is exited");
    }

    private static Map<String, Mapping> createMetadataTypeToMappingMap(Field field) {
        Map<String, Mapping> metadataTypeToMappingMap = new HashMap<String, Mapping>();
        for (GroupMapping gm : field.getGroupMappings()) {
            for (Mapping mapping : gm.getMappings()) {
                metadataTypeToMappingMap.put(mapping.getMetadataType(), mapping);
            }
        }
        return metadataTypeToMappingMap;
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
                                    Optional<Mapping> insideGroupMapping = gm.getMappings()
                                            .stream()
                                            .filter(mapping -> mapping.getMetadataType().equals(md.getType().getName()))
                                            .findAny();
                                    if (insideGroupMapping.isPresent()) {
                                        if (!StringUtils.isBlank(insideGroupMapping.get().getSourceVocabulary())
                                                && !StringUtils.isBlank(md.getAuthorityValue())) {
                                            values.put(insideGroupMapping.get().getMetadataType(),
                                                    md.getAuthorityValue().replace(md.getAuthorityURI(), ""));
                                        } else {
                                            values.put(insideGroupMapping.get().getMetadataType(), md.getValue());
                                        }
                                    }
                                }
                                GroupValue groupValue = new GroupValue(gm.getGroupName(), values);
                                field.getValues().add(new FieldValue(null, groupValue));
                            }
                        }
                        if (field.getValues().size() > 0) {
                            field.setShow(true);
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
