package de.intranda.goobi.plugins.codicological.model;

import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FieldValue {
    private String value;
    private Map<String, String> complexValue;
}
