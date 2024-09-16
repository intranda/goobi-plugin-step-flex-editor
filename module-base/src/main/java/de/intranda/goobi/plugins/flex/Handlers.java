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
import java.util.TreeSet;
import java.util.function.Function;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.configuration.SubnodeConfiguration;
import org.apache.commons.configuration.XMLConfiguration;
import org.apache.commons.configuration.tree.xpath.XPathExpressionEngine;
import org.apache.commons.lang3.StringUtils;
import org.goobi.beans.Process;
import org.goobi.beans.Ruleset;

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
import de.intranda.goobi.plugins.flex.model.json.vocabulary.JsonVocabulary;
import de.intranda.goobi.plugins.flex.model.json.vocabulary.JsonVocabularyField;
import de.intranda.goobi.plugins.flex.model.json.vocabulary.JsonVocabularyRecord;
import de.intranda.goobi.plugins.flex.model.json.vocabulary.VocabularyBuilder;
import de.sub.goobi.config.ConfigPlugins;
import de.sub.goobi.helper.exceptions.SwapException;
import de.sub.goobi.persistence.managers.ProcessManager;
import de.unigoettingen.sub.commons.contentlib.exceptions.IllegalRequestException;
import io.goobi.vocabulary.exchange.FieldDefinition;
import io.goobi.vocabulary.exchange.FieldInstance;
import io.goobi.vocabulary.exchange.VocabularySchema;
import io.goobi.workflow.api.vocabulary.VocabularyAPIManager;
import io.goobi.workflow.api.vocabulary.helper.ExtendedVocabulary;
import io.goobi.workflow.api.vocabulary.helper.ExtendedVocabularyRecord;
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
    private static final String STRING_PROCESS_ID = "processid";

    private static final VocabularyAPIManager vocabularyAPI = VocabularyAPIManager.getInstance();
    private static final VocabularyBuilder vocabularyBuilder = new VocabularyBuilder(vocabularyAPI);

    private Handlers() {
        // hide the implicit constructor
    }

    public static final Route allVocabs = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(FlexEditor.TITLE);
        List<Column> colList = readColsFromConfig(conf);

        Set<String> vocabNames = new TreeSet<String>();
        for (Column col : colList) {
            for (Box box : col.getBoxes()) {
                for (Field field : box.getFields()) {

                    for (String vocabName : field.getSourceVocabularies()) {
                        if (vocabName != null) {
                            vocabNames.add(vocabName);
                        }
                    }

                    for (GroupMapping gm : field.getGroupMappings()) {
                        for (Mapping mapping : gm.getMappings()) {
                            String vocabName = mapping.getSourceVocabulary();
                            if (vocabName != null) {
                                vocabNames.add(vocabName);
                            }
                        }
                    }
                }
            }
        }

        Map<String, JsonVocabulary> vocabMap = new HashMap<>();
        vocabularyAPI.vocabularies().all().forEach(vocab -> {
            if (vocabNames.contains(vocab.getName())) {
                JsonVocabulary jsonVocab = vocabularyBuilder.buildVocabulary(vocab);
                vocabMap.put(vocab.getName(), jsonVocab);
            }
        });

        return vocabMap;
    };

    public static final Route getMetsTranslations = (req, res) -> {
        int processId = Integer.parseInt(req.params(STRING_PROCESS_ID));
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

    public static final Route getMetadata = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(FlexEditor.TITLE);
        List<Column> colList = readColsFromConfig(conf);
        mergeMetadata(colList, Integer.parseInt(req.params(STRING_PROCESS_ID)));
        return colList;
    };

    public static final Route getImages = (req, res) -> {
        int processId = Integer.parseInt(req.params(STRING_PROCESS_ID));
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

    public static final Route saveMets = (req, res) -> {
        List<Column> userInput = gson.fromJson(req.body(), columnListType);
        int processId = Integer.parseInt(req.params(STRING_PROCESS_ID));
        Process p = ProcessManager.getProcessById(processId);
        HttpServletRequest httpRequest = req.raw();
        saveMetadata(userInput, p, httpRequest);
        return "";
    };

    public static final Route newVocabEntry = (req, res) -> {
        String vocabName = req.params("vocabName");
        ExtendedVocabulary vocab = vocabularyAPI.vocabularies().findByName(vocabName);
        VocabularySchema schema = vocabularyAPI.vocabularySchemas().getSchema(vocab);

        JsonVocabularyRecord jsonRecord = gson.fromJson(req.body(), JsonVocabularyRecord.class);

        ExtendedVocabularyRecord record = vocabularyAPI.vocabularyRecords().createEmptyRecord(vocab.getId(), null, false);

        List<FieldInstance> fields = new ArrayList<>();
        for (int i = 0; i < jsonRecord.getFields().size(); i++) {
            JsonVocabularyField jsonField = jsonRecord.getFields().get(i);
            FieldDefinition definition =
                    schema.getDefinitions()
                            .stream()
                            .filter(def -> def.getId() == jsonField.getDefinitionId())
                            .findAny()
                            .orElseThrow(() -> new IllegalRequestException("No vocabulary field definition with id " + jsonField.getDefinitionId()));

            record.getFieldForDefinitionName(jsonField.getLabel()).ifPresent(fieldInstance -> {
                fieldInstance.setFieldValue(jsonField.getValue());
            });
        }

        record = vocabularyAPI.vocabularyRecords().save(record);

        return vocabularyBuilder.buildRecord(record);
    };

    /**
     * read columns from configuration
     * 
     * @param conf
     * @return list of Column objects
     */
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

    /**
     * save the metadata
     * 
     * @param userInput input list of column objects from the user
     * @param p Goobi process
     * @param request HttpServletRequest object
     * @throws ReadException
     * @throws IOException
     * @throws SwapException
     * @throws PreferencesException
     * @throws MetadataTypeNotAllowedException
     * @throws WriteException
     */
    private static void saveMetadata(List<Column> userInput, Process p, HttpServletRequest request)
            throws ReadException, IOException, SwapException, PreferencesException, MetadataTypeNotAllowedException, WriteException {

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
                        processMultiVocabularyField(prefs, ds, field, request);
                    } else { // !field.isMultiVocabulary()
                        processSingleVocabularyField(prefs, ds, field);
                    }
                }
            }
        }
        p.writeMetadataFile(ff);
    }

    /**
     * process Multi-Vocabulary field object for saving
     * 
     * @param prefs Prefs
     * @param ds DocStruct
     * @param field Field that should be processed
     * @param request HttpServletRequest
     * @throws MetadataTypeNotAllowedException
     */
    private static void processMultiVocabularyField(Prefs prefs, DocStruct ds, Field field, HttpServletRequest request)
            throws MetadataTypeNotAllowedException {
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
                String metadataValue = groupValue.getValues().get(metadataTypeName);
                log.debug("metadataValue = " + metadataValue);
                String recordId = metadataValue.substring(metadataValue.lastIndexOf("/") + 1);
                log.debug("recordId = " + recordId);
                prepareMetadataGivenTypeName(newGroup, metadataTypeName, recordId, metadataTypeToMappingMap, request);
            }
            ds.addMetadataGroup(newGroup);
        }
    }

    /**
     * process Single-Vocabulary field object for saving
     * 
     * @param prefs Prefs
     * @param ds DocStruct
     * @param field Field that should be processed
     * @throws PreferencesException
     * @throws MetadataTypeNotAllowedException
     */
    private static void processSingleVocabularyField(Prefs prefs, DocStruct ds, Field field)
            throws PreferencesException, MetadataTypeNotAllowedException {
        String fieldMdt = field.getMetadatatype();
        if (fieldMdt == null || "unknown".equals(fieldMdt)) {
            return;
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

    /**
     * prepare a Metadata object for the input MetadataGroup
     * 
     * @param newGroup MetadataGroup that should be added with the prepared Metadata object
     * @param metadataTypeName name of the MetadataType based on which the Metadata object should be prepared
     * @param recordId id of the record that should be retrieved
     * @param metadataTypeToMappingMap Map from MetadataTypes' names to Mapping objects
     * @param request HttpServletRequest
     * @throws MetadataTypeNotAllowedException
     */
    private static void prepareMetadataGivenTypeName(MetadataGroup newGroup, String metadataTypeName, String recordId,
            Map<String, Mapping> metadataTypeToMappingMap, HttpServletRequest request) throws MetadataTypeNotAllowedException {
        log.debug("metadataTypeName = " + metadataTypeName);
        // a direct call of newGroup.getMetadataList() will return an empty list, so we have to choose another way:
        // 1. find out the MetadataType whose name is equal to metadataTypeName
        // 2. create a Metadata object based on this MetadataType
        // 3. add this Metadata object to the MetadataGroup newGroup
        Metadata groupMd = createMetadataObject(newGroup, metadataTypeName);
        if (groupMd == null) {
            return;
        }

        if (recordId != null && recordId.matches("\\d+")) {

            ExtendedVocabularyRecord record = vocabularyAPI.vocabularyRecords().get(Long.parseLong(recordId));
            if (record != null) {
                record.writeReferenceMetadata(groupMd);
            }
        }
    }

    /**
     * create a Metadata object given the input metadataTypeName, and add it to the input MetadataGroup newGroup
     * 
     * @param newGroup MetadataGroup that should be added with the new Metadata object
     * @param metadataTypeName name of the MetadataType based on which the Metadata object should be created
     * @return the new Metadata object
     * @throws MetadataTypeNotAllowedException
     */
    private static Metadata createMetadataObject(MetadataGroup newGroup, String metadataTypeName) throws MetadataTypeNotAllowedException {
        for (MetadataType mdType : newGroup.getAddableMetadataTypes(false)) {
            log.debug("mdType = " + mdType.getName());
            if (mdType.getName().equals(metadataTypeName)) {
                // create a Metadata object based on this MetadataType and add it to the newGroup
                if (mdType.getIsPerson()) {
                    Person person = new Person(mdType);
                    person.setRole(mdType.getName());
                    newGroup.addPerson(person);
                    return person;
                }

                if (mdType.isCorporate()) {
                    Corporate corporate = new Corporate(mdType);
                    corporate.setRole(mdType.getName());
                    newGroup.addCorporate(corporate);
                    return corporate;
                }

                Metadata metadata = new Metadata(mdType);
                newGroup.addMetadata(metadata);
                return metadata;
            }
        }
        return null;
    }

    /**
     * create a map from MetadataTypes' names to Mapping objects
     * 
     * @param field Field object
     * @return a map from MetadataTypes' names to Mapping objects
     */
    private static Map<String, Mapping> createMetadataTypeToMappingMap(Field field) {
        Map<String, Mapping> metadataTypeToMappingMap = new HashMap<>();
        for (GroupMapping gm : field.getGroupMappings()) {
            for (Mapping mapping : gm.getMappings()) {
                metadataTypeToMappingMap.put(mapping.getMetadataType(), mapping);
            }
        }
        return metadataTypeToMappingMap;
    }

    /**
     * merge all saved Metadata
     * 
     * @param colList list of Column objects
     * @param processId id of the Goobi process
     * @throws ReadException
     * @throws IOException
     * @throws SwapException
     * @throws PreferencesException
     */
    private static void mergeMetadata(List<Column> colList, int processId) throws ReadException, IOException, SwapException, PreferencesException {
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
                        mergeMultiVocabularyField(ds, field);
                    } else {
                        mergeSingleVocabularyField(prefs, ds, field);
                    }
                }
            }
        }
    }

    /**
     * merge multi-vocabulary fields
     * 
     * @param ds DocStruct
     * @param field Field
     */
    private static void mergeMultiVocabularyField(DocStruct ds, Field field) {
        Map<String, GroupMapping> metadataGroupToGroupMapping = field.getGroupMappings()
                .stream()
                .collect(Collectors.toMap(GroupMapping::getGroupName, Function.identity()));
        List<MetadataGroup> groups = Optional
                .ofNullable(ds.getAllMetadataGroups())
                .orElse(new ArrayList<>());
        for (MetadataGroup mdg : groups) {
            GroupMapping gm = metadataGroupToGroupMapping.get(mdg.getType().getName());
            if (gm != null) {
                Map<String, String> values = prepareValuesForGroupValue(mdg, gm);
                GroupValue groupValue = new GroupValue(gm.getGroupName(), values);
                field.getValues().add(new FieldValue(null, groupValue));
            }
        }

        if (!field.getValues().isEmpty()) {
            field.setShow(true);
        }
    }

    /**
     * merge single vocabulary fields
     * 
     * @param prefs Prefs
     * @param ds DocStruct
     * @param field Field
     * @throws PreferencesException
     */
    private static void mergeSingleVocabularyField(Prefs prefs, DocStruct ds, Field field) throws PreferencesException {
        String fieldMdt = field.getMetadatatype();
        if (fieldMdt == null || "unknown".equals(fieldMdt)) {
            return;
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

    /**
     * perpare the field "values" for the GroupValue object
     * 
     * @param mdg MetadataGroup
     * @param gm GroupMapping
     * @return a Map that shall be used as the field "values" of a GroupValue object
     */
    private static Map<String, String> prepareValuesForGroupValue(MetadataGroup mdg, GroupMapping gm) {
        Map<String, String> values = new HashMap<>();
        for (Metadata md : mdg.getMetadataList()) {
            Optional<Mapping> insideGroupMapping = gm.getMappings()
                    .stream()
                    .filter(mapping -> mapping.getMetadataType().equals(md.getType().getName()))
                    .findAny();

            if (insideGroupMapping.isEmpty()) {
                continue;
            }

            Mapping mapping = insideGroupMapping.get();
            String authorityValue = md.getAuthorityValue();

            if (StringUtils.isNoneBlank(mapping.getSourceVocabulary(), authorityValue)) {
                // the following statement is the reason why we get the string "/vocabularies/{vocabularyId}/{recordId}" at reloading previously saved provenances
                values.put(mapping.getMetadataType(), authorityValue.replace(md.getAuthorityURI(), ""));
            } else {
                values.put(mapping.getMetadataType(), md.getValue());
            }
        }

        return values;
    }

}
