package de.intranda.goobi.plugins.codicological.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.SubnodeConfiguration;

import lombok.Data;

@Data
public class Box {
    public String name;
    public List<Field> fields;

    public Box(String name) {
        this.name = name;
        this.fields = new ArrayList<>();
    }

    public static Box fromConfig(SubnodeConfiguration conf) {
        Box box = new Box(conf.getString("./@name"));
        List<SubnodeConfiguration> subConfs = conf.configurationsAt("./field");
        for (SubnodeConfiguration fieldConf : subConfs) {
            box.addField(Field.fromConfig(fieldConf));
        }
        return box;
    }

    private void addField(Field f) {
        this.fields.add(f);
    }
}
