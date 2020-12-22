package de.intranda.goobi.plugins.flex.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.HierarchicalConfiguration;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Column {
    private List<Box> boxes;

    public static Column fromConfig(HierarchicalConfiguration conf) {
        Column col = new Column(new ArrayList<>());
        List<HierarchicalConfiguration> boxConfs = conf.configurationsAt("./box");
        for (HierarchicalConfiguration subConf : boxConfs) {
            col.addBox(Box.fromConfig(subConf));
        }
        return col;
    }

    private void addBox(Box box) {
        this.boxes.add(box);
    }
}
