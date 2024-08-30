---
title: Flex Editor
identifier: intranda_step_flex_editor
description: Step Plugin for the dynamic adjustment of user interfaces
published: true
---

## Introduction
This plugin enables dynamic customization of the user interface, allowing specific metadata management requirements to be efficiently implemented.

## Installation
This plugin is delivered as a tar archive. To install it, the archive `plugin_intranda_step_flex-editor.tar` must be extracted into the Goobi directory:

```
tar -C /opt/digiverso/goobi/ -xf plugin_intranda_step_flex-editor.tar --exclude="pom.xml"
```

This plugin also comes with a configuration file named `plugin_intranda_step_flex-editor.xml`. It must be placed in the following path:

```bash
/opt/digiverso/goobi/config/plugin_intranda_step_flex-editor.xml
```

To use the plugin, it must be selected in a workflow step:

![Configuration of the workflow step for using the plugin](screen1_en.png)

## Overview and Functionality
The Flex Editor for Goobi Workflow allows flexible customization of the metadata input interface. Through an XML configuration file, you can define how metadata fields are organized and displayed in columns and boxes. Various field types, such as text fields, checkboxes, and dropdowns, provide different input options.

![Example appearance of a customized metadata input interface](screen2_de.png)
![Example appearance of a customized metadata input interface](screen3_de.png)
![Example appearance of a customized metadata input interface](screen4_de.png)


## Confifiguration

The plugin is configured using the file plugin_intranda_step_flex-editor.xml as shown here:

{{CONFIG_CONTENT}}

{{CONFIG_DESCRIPTION_PROJECT_STEP}}

The configuration file describes the structure of the user interface as seen in Goobi. The configuration consists of multiple <column> elements, each representing a column in the interface. Within the <column> elements, there are <box> elements that group multiple metadata fields into a box within the interface. Inside the <box> elements are <field> elements, representing a metadata field in the process. The <field> elements can have different types, giving them specific functionality in the user interface:

| Parameter          | Explanation                                                                                     |
|--------------------|-------------------------------------------------------------------------------------------------|
| `Input`            | A single-line input field used for capturing simple text inputs. A metadata type must also be specified. |
| `TEXTAREA`         | A multi-line input field. Specifying a metadata type is also required.                           |
| `BOOLEAN`          | A checkbox used for yes/no decisions or binary options. A metadata type must also be specified.  |
| `DROPDOWN`         | A dropdown menu with values sourced from the predefined vocabulary. In addition to the metadata type, the name of the vocabulary to be used must be specified. |
| `MODAL_PROVENANCE` | Creates a metadata group that includes multiple fields. These fields can also be sourced from vocabularies. The field is repeatable and can use multiple vocabularies. |