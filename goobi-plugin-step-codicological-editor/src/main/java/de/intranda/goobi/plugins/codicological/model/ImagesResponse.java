package de.intranda.goobi.plugins.codicological.model;

import java.util.List;

import lombok.Value;

@Value
public class ImagesResponse {
    String folder;
    String[] imageNames;
}
