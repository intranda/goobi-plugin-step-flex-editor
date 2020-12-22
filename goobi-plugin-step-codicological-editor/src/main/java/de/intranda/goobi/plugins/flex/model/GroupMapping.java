package de.intranda.goobi.plugins.flex.model;

import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.configuration.HierarchicalConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class GroupMapping {
    private String groupName;
    private List<Mapping> mappings;

    public static GroupMapping fromConfig(HierarchicalConfiguration conf) {
        String groupName = conf.getString("./@groupName");
        List<Mapping> mappings = conf.configurationsAt("./mapping")
                .stream()
                .map(Mapping::fromConfig)
                .collect(Collectors.toList());
        return new GroupMapping(groupName, mappings);
    }
}
