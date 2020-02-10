package de.intranda.goobi.plugins.codicological.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.SubnodeConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Field {
    private FieldType type;
    private String metadatatype;
    private String name;
    private List<String> values;
    private String sourceVocabulary;

    public static Field fromConfig(SubnodeConfiguration conf) {
        FieldType type = FieldType.valueOf(conf.getString("./@type"));
        String metadatatype = conf.getString("./metadatatype");
        String name = conf.getString("./name");
        List<String> values = new ArrayList<String>();
        String sourceVocabulary = conf.getString("./sourceVocabulary");

        return new Field(type, metadatatype, name, values, sourceVocabulary);
    }
}
