package de.intranda.goobi.plugins;

import java.nio.file.Path;
import java.util.HashMap;

//import org.goobi.beans.Step;
//import org.goobi.production.enums.PluginGuiType;
//import org.goobi.production.enums.PluginType;
import org.goobi.production.enums.StepReturnValue;
import org.goobi.production.plugin.interfaces.IRestGuiPlugin;

import de.intranda.goobi.plugins.flex.Routes;
import lombok.Data;
import lombok.extern.log4j.Log4j2;
import net.xeoh.plugins.base.annotations.PluginImplementation;
import spark.Service;

@Data
@PluginImplementation
@Log4j2
public class FlexEditor implements IRestGuiPlugin {
    private Step step;
    private String returnPath;
    public final static String title = "intranda_step_flex-editor";

    @Override
    public String cancel() {
        return "/uii/" + returnPath;
    }

    @Override
    public boolean execute() {
        return false;
    }

    @Override
    public String finish() {
        return "/uii/" + returnPath;
    }

    @Override
    public String getPagePath() {
        return "/uii/guiPlugin.xhtml";
    }

    @Override
    public PluginGuiType getPluginGuiType() {
        return PluginGuiType.FULL;
    }

    @Override
    public void initialize(Step step, String returnPath) {
        log.info(returnPath);
        this.step = step;
        this.returnPath = returnPath;

    }

    @Override
    public HashMap<String, StepReturnValue> validate() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String getTitle() {
        return title;
    }

    @Override
    public PluginType getType() {
        return PluginType.Step;
    }

    @Override
    public void extractAssets(Path arg0) {
        //nothing to do here - doesn't work anyway
    }

    @Override
    public String[] getJsPaths() {
        return new String[] { "js/app.js" };
    }

    @Override
    public void initRoutes(Service http) {
        Routes.initRoutes(http);
    }

}
