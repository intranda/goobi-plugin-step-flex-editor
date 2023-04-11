package de.intranda.goobi.plugins.flex;

import com.google.gson.Gson;

import spark.Service;

public class Routes {
    private static Gson gson = new Gson();

    private Routes() {
        // hide the implicit constructor
    }

    public static void initRoutes(Service http) {
        http.path("/ce", () -> {
            http.get("/vocabularies", Handlers.allVocabs, gson::toJson);
            http.get("/process/:processid/mets", Handlers.getMetadata, gson::toJson);
            http.get("/process/:processid/images", Handlers.getImages, gson::toJson);
            http.get("/process/:processid/ruleset/messages/:language",
                    Handlers.getMetsTranslations, gson::toJson);
            http.post("/process/:processid/mets", Handlers.saveMets);
            http.post("/vocabularies/:vocabname/records", Handlers.newVocabEntry, gson::toJson);
        });
    }
}
