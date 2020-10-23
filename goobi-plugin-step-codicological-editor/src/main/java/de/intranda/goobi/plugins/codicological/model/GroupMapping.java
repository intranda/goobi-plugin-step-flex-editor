package de.intranda.goobi.plugins.codicological.model;

import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.configuration.HierarchicalConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class GroupMapping {
    private String sourceVocabulary;
    private String groupName;
    private String label;
    private List<Mapping> mappings;

    public static GroupMapping fromConfig(HierarchicalConfiguration conf) {
        String sourceVocabulary = conf.getString("./@sourceVocabulary");
        String groupName = conf.getString("./@groupName");
        String label = conf.getString("./@label");
        List<Mapping> mappings = conf.configurationsAt("./mapping")
                .stream()
                .map(Mapping::fromConfig)
                .collect(Collectors.toList());
        return new GroupMapping(sourceVocabulary, groupName, label, mappings);
    }
}
