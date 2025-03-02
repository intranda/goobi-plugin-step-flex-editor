package de.intranda.goobi.plugins.flex.model.json.vocabulary;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class JsonVocabularyRecord {

    private final Long id;
    private final List<JsonVocabularyField> fields;

    public JsonVocabularyRecord(Long id) {
        this(id, new ArrayList<>());
    }

    public JsonVocabularyRecord(Long id, List<JsonVocabularyField> fields) {
        super();
        this.id = id;
        this.fields = fields;
    }

    public Long getId() {
        return id;
    }

    public List<JsonVocabularyField> getFields() {
        return Collections.unmodifiableList(fields);
    }

    public boolean addField(JsonVocabularyField field) {
        return this.fields.add(field);
    }

}
