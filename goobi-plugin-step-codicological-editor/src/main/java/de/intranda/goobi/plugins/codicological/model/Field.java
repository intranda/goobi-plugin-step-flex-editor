package de.intranda.goobi.plugins.codicological.model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.configuration.HierarchicalConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Field {
    private FieldType type;
    private String metadatatype;
    private String name;
    private List<String> values;
    private List<String> sourceVocabularies;
    private boolean show;

    public static Field fromConfig(HierarchicalConfiguration conf) {
        FieldType type = FieldType.valueOf(conf.getString("./@type"));
        boolean show = conf.getBoolean("./@defaultDisplay", false);
        String metadatatype = conf.getString("./metadatatype");
        String name = conf.getString("./name");
        List<String> values = new ArrayList<String>();
        List<String> sourceVocabulary = Arrays.asList(conf.getStringArray("./sourceVocabulary"));

        return new Field(type, metadatatype, name, values, sourceVocabulary, show);
    }
}
