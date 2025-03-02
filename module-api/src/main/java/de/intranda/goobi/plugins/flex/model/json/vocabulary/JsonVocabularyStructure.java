package de.intranda.goobi.plugins.flex.model.json.vocabulary;

public class JsonVocabularyStructure {
    private final String label;
    private final boolean mainEntry;

    public JsonVocabularyStructure(String label, boolean mainEntry) {
        super();
        this.label = label;
        this.mainEntry = mainEntry;
    }

    public String getLabel() {
        return label;
    }

    public boolean isMainEntry() {
        return mainEntry;
    }

}
