package de.intranda.goobi.plugins.codicological.model;

import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class GroupValue {
    private String groupName;
    private String sourceVocabulary;
    private Map<String, String> values;
}
