package de.intranda.goobi.plugins.flex.model.json.vocabulary;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class JsonVocabulary {

    private final Long id;
    private final String title;
    private final String description;
    private final List<JsonVocabularyStructure> struct;
    private final List<JsonVocabularyRecord> records;

    public JsonVocabulary(Long id, String title, String description) {
        this(id, title, description, new ArrayList<>(), new ArrayList<>());
    }

    public JsonVocabulary(Long id, String title, String description, List<JsonVocabularyStructure> struct, List<JsonVocabularyRecord> records) {
        super();
        this.id = id;
        this.title = title;
        this.description = description;
        this.struct = struct;
        this.records = records;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public List<JsonVocabularyStructure> getStruct() {
        return Collections.unmodifiableList(struct);
    }

    public List<JsonVocabularyRecord> getRecords() {
        return Collections.unmodifiableList(records);
    }

    public boolean addRecord(JsonVocabularyRecord record) {
        return this.records.add(record);
    }

    public boolean addStructure(JsonVocabularyStructure struct) {
        return this.struct.add(struct);
    }

}
