package de.intranda.goobi.plugins.flex.model;

import org.apache.commons.configuration.HierarchicalConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Mapping {
    private String sourceVocabulary;
    private String metadataType;

    public static Mapping fromConfig(HierarchicalConfiguration conf) {
        String sourceVocabulary = conf.getString("./@sourceVocabulary");
        String metadataType = conf.getString("./@metadataType");
        return new Mapping(sourceVocabulary, metadataType);
    }
}
