package de.intranda.goobi.plugins;

import de.intranda.goobi.plugins.flex.Routes;
import lombok.Data;
import lombok.extern.log4j.Log4j2;
import net.xeoh.plugins.base.annotations.PluginImplementation;
import org.goobi.beans.Step;
import org.goobi.production.enums.PluginGuiType;
import org.goobi.production.enums.PluginType;
import org.goobi.production.enums.StepReturnValue;
import org.goobi.production.plugin.interfaces.IGuiPlugin;
import org.goobi.production.plugin.interfaces.IRestPlugin;
import org.goobi.production.plugin.interfaces.IStepPlugin;
import spark.Service;

import java.nio.file.Path;
import java.util.HashMap;

@Data
@PluginImplementation
@Log4j2
public class FlexEditor implements IGuiPlugin, IStepPlugin, IRestPlugin {
    private Step step;
    private String returnPath;
    public static final String TITLE = "intranda_step_flex-editor";

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
        log.debug("FlexEditor::getPagePath is called");
        return "/uii/guiPluginNew.xhtml";
    }

    @Override
    public PluginGuiType getPluginGuiType() {
        return PluginGuiType.FULL;
    }

    @Override
    public void initialize(Step step, String returnPath) {
        log.debug(returnPath);
        log.debug("FlexEditor::initialize is called");
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
        return TITLE;
    }

    @Override
    public PluginType getType() {
        return PluginType.Step;
    }

    @Override
    public String[] getJsPaths() {
        return new String[] { "app.js" };
    }

    @Override
    public void initRoutes(Service http) {
        log.debug("FlexEditor::initRoutes is called");
        log.debug("http = " + http);
        Routes.initRoutes(http);
    }

}
