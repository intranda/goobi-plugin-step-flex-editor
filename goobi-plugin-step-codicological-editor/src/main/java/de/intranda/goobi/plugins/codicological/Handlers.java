package de.intranda.goobi.plugins.codicological;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.SubnodeConfiguration;
import org.apache.commons.configuration.XMLConfiguration;
import org.apache.commons.configuration.tree.xpath.XPathExpressionEngine;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import de.intranda.goobi.plugins.CodicologicalEditor;
import de.intranda.goobi.plugins.codicological.model.Box;
import de.intranda.goobi.plugins.codicological.model.Column;
import de.intranda.goobi.plugins.codicological.model.Field;
import de.sub.goobi.config.ConfigPlugins;
import spark.Route;

public class Handlers {
    private static Gson gson = new Gson();
    private static Type columnListType = TypeToken.getParameterized(List.class, Column.class).getType();

    public static Route allVocabs = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        return null;
    };

    public static Route getMetadata = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        conf.setExpressionEngine(new XPathExpressionEngine());
        List<Column> colList = new ArrayList<>();
        SubnodeConfiguration col1Conf = conf.configurationAt("//column[1]");
        SubnodeConfiguration col2Conf = conf.configurationAt("//column[2]");
        SubnodeConfiguration col3Conf = conf.configurationAt("//column[3]");
        colList.add(Column.fromConfig(col1Conf));
        colList.add(Column.fromConfig(col2Conf));
        colList.add(Column.fromConfig(col3Conf));
        mergeMetadata(colList, Integer.parseInt(req.params("processid")));
        return colList;
    };

    public static Route saveMets = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        List<Column> userInput = gson.fromJson(req.body(), columnListType);
        //TODO: get metadata and save
        return null;
    };

    private static void mergeMetadata(List<Column> colList, int parseInt) {
        for (Column col : colList) {
            for (Box box : col.getBoxes()) {
                for (Field field : box.getFields()) {
                    //TODO: look up metadata of top DS and write value(s) to field
                }
            }
        }

    }
}
