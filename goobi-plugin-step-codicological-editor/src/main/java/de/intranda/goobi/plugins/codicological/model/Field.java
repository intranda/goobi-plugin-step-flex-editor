package de.intranda.goobi.plugins.codicological.model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.configuration.HierarchicalConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Field {
    private FieldType type;
    private String metadatatype;
    private List<Mapping> complexMappings;
    private String name;
    private List<FieldValue> values;
    private List<String> sourceVocabularies;
    private boolean show;
    private boolean repeatable;

    public static Field fromConfig(HierarchicalConfiguration conf) {
        FieldType type = FieldType.valueOf(conf.getString("./@type"));
        boolean show = conf.getBoolean("./@defaultDisplay", false);
        boolean repeatable = conf.getBoolean("./@repeatable", false);
        String metadatatype = conf.getString("./metadatatype");
        List<Mapping> complextMappings = conf.configurationsAt("./mapping")
                .stream()
                .map(Mapping::fromConfig)
                .collect(Collectors.toList());
        String name = conf.getString("./name");
        List<FieldValue> values = new ArrayList<FieldValue>();
        List<String> sourceVocabulary = Arrays.asList(conf.getStringArray("./sourceVocabulary"));

        return new Field(type, metadatatype, complextMappings, name, values, sourceVocabulary, show, repeatable);
    }
}
