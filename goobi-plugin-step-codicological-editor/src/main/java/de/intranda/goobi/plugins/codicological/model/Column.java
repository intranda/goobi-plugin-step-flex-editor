package de.intranda.goobi.plugins.codicological.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.SubnodeConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Column {
    private List<Box> boxes;

    public static Column fromConfig(SubnodeConfiguration conf) {
        Column col = new Column(new ArrayList<>());
        List<SubnodeConfiguration> boxConfs = conf.configurationsAt("./box");
        for (SubnodeConfiguration subConf : boxConfs) {
            col.addBox(Box.fromConfig(subConf));
        }
        return col;
    }

    private void addBox(Box box) {
        this.boxes.add(box);
    }
}
