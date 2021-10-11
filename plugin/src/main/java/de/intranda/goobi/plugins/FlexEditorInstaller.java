package de.intranda.goobi.plugins;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.Callable;

import picocli.CommandLine;
import picocli.CommandLine.Option;

public class FlexEditorInstaller implements Callable<Integer> {

    @Option(names = { "--install", "-i" }, description = "install this plugin")
    private boolean install;

    @Option(names = { "-sa", "--static_assets" }, description = "the goobi static assets dir")
    private String staticAssetsDir = "/opt/digiverso/goobi/static_assets/";

    @Option(names = { "-pd", "--plugins_dir" }, description = "the goobi plugins directory")
    private String pluginDir = "/opt/digiverso/goobi/plugins/";

    public static void main(String[] args) {
        if (args.length == 0) {
            CommandLine cl = new CommandLine(new FlexEditorInstaller());
            cl.usage(System.out);
            System.exit(0);
        }
        try {
            int exitCode = new CommandLine(new FlexEditorInstaller()).execute(args);
            System.exit(exitCode);
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(1);
        }
    }

    @Override
    public Integer call() throws Exception {
        if (this.install) {
            System.out.println("installing static files to " + staticAssetsDir);
            extractAssets(Paths.get(staticAssetsDir));

            System.out.println("installing plugin to " + pluginDir);
            String myJarFile = FlexEditorInstaller.class.getProtectionDomain().getCodeSource().getLocation().getPath();
            Path jarPath = Paths.get(myJarFile);
            Files.copy(jarPath, Paths.get(pluginDir, "step", jarPath.getFileName().toString()), StandardCopyOption.REPLACE_EXISTING);
        }
        return 0;
    }

    public void extractAssets(Path assetsDir) {
        String[] paths = new String[] { "css/style.css", "js/app.js" };
        for (String p : paths) {
            extractFile(p, assetsDir);
        }
    }

    public void extractFile(String filePath, Path assetsDir) {
        Path out = assetsDir.resolve("plugins").resolve(FlexEditor.title).resolve(filePath);
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("frontend/" + filePath)) {
            if (!Files.exists(out.getParent())) {
                Files.createDirectories(out.getParent());
            }
            if (is != null) {
                Files.copy(is, out, StandardCopyOption.REPLACE_EXISTING);
            } else {
                System.out.println("file not found: " + filePath);
            }
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}
