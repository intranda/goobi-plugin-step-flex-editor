package de.intranda.goobi.plugins.codicological.model;

import org.apache.commons.configuration.HierarchicalConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Mapping {
    private String vocabularyName;
    private String metadataType;

    public static Mapping fromConfig(HierarchicalConfiguration conf) {
        String vocabularyName = conf.getString("./@vocabularyName");
        String metadataType = conf.getString("./@metadataType");
        return new Mapping(vocabularyName, metadataType);
    }
}
