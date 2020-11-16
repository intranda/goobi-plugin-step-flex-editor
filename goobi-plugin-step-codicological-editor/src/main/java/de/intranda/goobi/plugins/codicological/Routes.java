package de.intranda.goobi.plugins.codicological;

import com.google.gson.Gson;

import spark.Service;

public class Routes {
    private static Gson gson = new Gson();

    public static void initRoutes(Service http) {
        http.path("/ce", () -> {
            http.get("/vocabularies", Handlers.allVocabs, gson::toJson);
            http.get("/process/:processid/mets", Handlers.getMetadata, gson::toJson);
            http.get("/process/:processid/images", Handlers.getImages, gson::toJson);
            http.post("/process/:processid/mets", Handlers.saveMets);
            http.post("/vocabularies/:vocabname/records", Handlers.newVocabEntry, gson::toJson);
        });
    }
}
