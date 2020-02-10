package de.intranda.goobi.plugins.codicological;

import org.apache.commons.configuration.XMLConfiguration;

import de.intranda.goobi.plugins.CodicologicalEditor;
import de.sub.goobi.config.ConfigPlugins;
import spark.Route;

public class Handlers {

    public static Route allVocabs = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        return null;
    };

    public static Route getMetadata = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        return null;
    };

    public static Route saveMets = (req, res) -> {
        XMLConfiguration conf = ConfigPlugins.getPluginConfig(CodicologicalEditor.title);
        return null;
    };
}
