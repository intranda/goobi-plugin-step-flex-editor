package de.intranda.goobi.plugins.flex.model.json.vocabulary;

public class JsonVocabularyField {

    private final Long id;
    private final Long definitionId;
    private final String label;
    private final String value;
    private final String language;

    public JsonVocabularyField(Long id, Long definitionId, String label, String value, String language) {
        super();
        this.id = id;
        this.definitionId = definitionId;
        this.label = label;
        this.value = value;
        this.language = language;
    }

    public Long getId() {
        return id;
    }

    public String getLabel() {
        return label;
    }

    public String getValue() {
        return value;
    }

    public String getLanguage() {
        return language;
    }

    public Long getDefinitionId() {
        return definitionId;
    }

}
