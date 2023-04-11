package de.intranda.goobi.plugins.flex.model;

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
    private List<GroupMapping> groupMappings;
    private String name;
    private List<FieldValue> values;
    private List<String> sourceVocabularies;
    private boolean show;
    private boolean repeatable;
    private boolean multiVocabulary;

    public static Field fromConfig(HierarchicalConfiguration conf) {
        FieldType type = FieldType.valueOf(conf.getString("./@type"));
        boolean show = conf.getBoolean("./@defaultDisplay", false);
        boolean repeatable = conf.getBoolean("./@repeatable", false);
        boolean multiVocabulary = conf.getBoolean("./@multiVocabulary", false);
        List<GroupMapping> groupMappings = conf.configurationsAt("./groupMapping")
                .stream()
                .map(GroupMapping::fromConfig)
                .collect(Collectors.toList());
        String metadatatype = conf.getString("./metadatatype");

        String name = conf.getString("./name");
        List<FieldValue> values = new ArrayList<>();
        List<String> sourceVocabulary = Arrays.asList(conf.getStringArray("./sourceVocabulary"));

        return new Field(type, metadatatype, groupMappings, name, values, sourceVocabulary, show, repeatable, multiVocabulary);
    }
}
