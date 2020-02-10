package de.intranda.goobi.plugins.codicological.model;

import lombok.Data;
import ugh.dl.MetadataTypeForDocStructType;

@Data
public class Field {
    private FieldType type;
    private MetadataTypeForDocStructType metadatatype;

}
