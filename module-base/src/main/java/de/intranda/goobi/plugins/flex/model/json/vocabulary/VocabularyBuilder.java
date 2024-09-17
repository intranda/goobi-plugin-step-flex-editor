package de.intranda.goobi.plugins.flex.model.json.vocabulary;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import io.goobi.vocabulary.exchange.FieldDefinition;
import io.goobi.workflow.api.vocabulary.VocabularyAPIManager;
import io.goobi.workflow.api.vocabulary.helper.ExtendedFieldInstance;
import io.goobi.workflow.api.vocabulary.helper.ExtendedFieldValue;
import io.goobi.workflow.api.vocabulary.helper.ExtendedVocabulary;
import io.goobi.workflow.api.vocabulary.helper.ExtendedVocabularyRecord;

public class VocabularyBuilder {

    private final VocabularyAPIManager vocabManager;

    public VocabularyBuilder(VocabularyAPIManager vocabManager) {
        this.vocabManager = vocabManager;
    }

    public JsonVocabulary buildVocabulary(ExtendedVocabulary orig) {

        try {
            Long id = orig.getId();
            String title = orig.getName();
            String description = orig.getDescription();

            List<FieldDefinition> fieldDefinitions =
                    vocabManager.vocabularySchemas().getSchema(orig).getDefinitions();
            List<JsonVocabularyStructure> structs = fieldDefinitions.stream().map(this::getStructure).collect(Collectors.toList());

            List<JsonVocabularyRecord> records =
                    vocabManager.vocabularyRecords()
                            .list(id)
                            .all()
                            .request()
                            .getContent()
                            .stream()
                            .map(this::buildRecord)
                            .collect(Collectors.toList());

            return new JsonVocabulary(id, title, description, structs, records);
        } catch (NullPointerException e) {
            e.printStackTrace();
            return null;
        }

    }

    public JsonVocabularyRecord buildRecord(ExtendedVocabularyRecord orig) {

        List<JsonVocabularyField> fields = orig.getExtendedFields().stream().flatMap(this::getFields).collect(Collectors.toList());
        return new JsonVocabularyRecord(orig.getId(), fields);
    }

    private Stream<JsonVocabularyField> getFields(ExtendedFieldInstance extField) {
        Long id = extField.getId();
        Long definitionId = extField.getDefinitionId();
        String name = extField.getDefinition().getName();

        return extField.getExtendedValues().stream().map(ExtendedFieldValue::getTranslations).flatMap(List::stream).map(translation -> {
            return new JsonVocabularyField(id, definitionId, name, translation.getValue(), translation.getLanguage());
        });
    }

    private JsonVocabularyStructure getStructure(FieldDefinition definition) {
        return new JsonVocabularyStructure(definition.getName(), definition.getMainEntry());
    }

}
