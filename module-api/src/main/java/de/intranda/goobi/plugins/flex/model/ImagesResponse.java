package de.intranda.goobi.plugins.flex.model;

import lombok.Value;

@Value
public class ImagesResponse {
    String folder;
    String[] imageNames;
}
