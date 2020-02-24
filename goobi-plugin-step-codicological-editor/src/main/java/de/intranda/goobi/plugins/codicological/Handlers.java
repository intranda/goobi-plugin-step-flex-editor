package de.intranda.goobi.plugins.codicological;

import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

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
import de.intranda.goobi.plugins.codicological.model.ImagesResponse;
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
                    String vocabName = field.getSourceVocabulary();
                    if (vocabName != null && !vocabMap.containsKey(vocabName)) {
                        Vocabulary vocab = VocabularyManager.getVocabularyByTitle(vocabName);
                        VocabularyManager.loadRecordsForVocabulary(vocab);
                        vocabMap.put(vocabName, vocab);
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
        if(Files.exists(imDir)) {
            return new ImagesResponse("media", imDir.toFile().list());
        }
        imDir = Paths.get(p.getImagesOrigDirectory(false));
        return new ImagesResponse("orig", imDir.toFile().list());
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
                    List<String> fieldValues = field.getValues();
                    int maxListLen = Math.max(metadataList.size(), fieldValues.size());
                    for (int i = 0; i < maxListLen; i++) {
                        //TODO: not sure if this works, better check...
                        if (i >= fieldValues.size()) {
                            ds.removeMetadata(metadataList.get(i));
                            continue;
                        }
                        if (i >= metadataList.size()) {
                            Metadata newMeta = new Metadata(mdt);
                            newMeta.setValue(fieldValues.get(i));
                            ds.addMetadata(newMeta);
                            continue;
                        }
                        Metadata oldMeta = metadataList.get(i);
                        oldMeta.setValue(fieldValues.get(i));
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
                        field.getValues().add(md.getValue());
                    }
                }
            }
        }

    }
}
