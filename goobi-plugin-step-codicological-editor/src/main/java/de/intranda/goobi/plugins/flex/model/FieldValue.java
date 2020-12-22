package de.intranda.goobi.plugins.flex.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FieldValue {
    private String value;
    private GroupValue groupValue;
}
