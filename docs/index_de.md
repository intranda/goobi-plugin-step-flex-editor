---
title: Flex Editor
identifier: intranda_step_flex_editor
description: Step Plugin für die dynamische Anpassung von Erfassungsmasken für Metadaten
published: true
---

## Einführung
Dieses Plugin ermöglicht die dynamische Anpassung der Benutzeroberfläche, sodass spezifische Anforderungen an die Metadatenverwaltung effizient umgesetzt werden können.

## Installation
Dieses Plugin wird als tar-Archiv ausgeliefert. Um es zu installieren, muss das Archiv plugin_intranda_step_flex-editor.tar in den Goobi-Ordner entpackt werden:

```bash
tar -C /opt/digiverso/goobi/ -xf plugin_intranda_step_flex-editor.tar --exclude="pom.xml"
```

Dieses Plugin verfügt außerdem über eine Konfigurationsdatei mit dem Namen `plugin_intranda_step_flex-editor.xml`. Sie muss unter folgendem Pfad abgelegt werden:

```bash
/opt/digiverso/goobi/config/plugin_intranda_step_flex-editor.xml
```

Für die Verwendung des Plugins muss dieses in einem Arbeitsschritt ausgewählt sein:

![Konfiguration des Arbeitsschritts für die Nutzung des Plugins](screen1_de.png)

## Überblick und Funktionsweise
Der Flex Editor für Goobi Workflow ermöglicht die flexible Anpassung der Metadaten-Eingabeoberfläche. Über eine XML-Konfigurationsdatei wird definiert, wie Metadatenfelder in Spalten und Boxen organisiert und angezeigt werden. Verschiedene Feldtypen, wie Textfelder, Checkboxen und Dropdowns, bieten verschiedene Eingabeoptionen.

![Beispielhaftes Aussehen einer angepassten Metadaten-Eingabeoberfläche](screen2_de.png)
![Beispielhaftes Aussehen einer angepassten Metadaten-Eingabeoberfläche](screen3_de.png)
![Beispielhaftes Aussehen einer angepassten Metadaten-Eingabeoberfläche](screen4_de.png)

## Konfiguration
Die Konfiguration des Plugins erfolgt in der Datei `plugin_intranda_step_flex-editor.xml` wie hier aufgezeigt:

{{CONFIG_CONTENT}}

{{CONFIG_DESCRIPTION_PROJECT_STEP}}

Die Konfigurationsdatei beschreibt den Aufbau der in Goobi zu sehenden Nutzeroberfläche. Die Konfiguration besteht aus mehreren `<column>`-Elementen, die in der Oberfläche jeweils eine Spalte ergeben. In den `<column>`-Elementen gibt es wiederum `<box>`-Elemente, die in der Oberfläche mehrere Metadatenfelder zu einer Box gruppieren. In den `<box>`-Elementen wiederum befinden sich `<field>`-Elemente, die ein Metadatenfeld im Vorgang repäsentieren. Die `<field>`-Elemente können verschiedene Typen haben, die ihnen eine bestimmte Funktionalität in der Nutzeroberfläche geben:

Parameter               | Erläuterung
------------------------|------------------------------------
`INPUT`                      | Ein einzeiliges Eingabefeld, das verwendet wird, um einfache Texteingaben zu erfassen. Es muss immer auch ein Metadatentyp angegeben werden. |
`TEXTAREA`                      | Hierbei handelt es sich um ein mehrzeiliges Eingabefeld. Auch hier ist die Angabe eines Metadatentyps erforderlich. |
`BOOLEAN`                      | Eine Checkbox, die für Ja/Nein-Entscheidungen oder binäre Optionen verwendet wird. Ein Metadatentyp muss ebenfalls angegeben werden. |
`DROPDOWN`                      | Ein Dropdown-Menü, dessen Werte aus dem vorgegebenen Vokabular stammen. Zusätzlich zum Metadatentyp muss der Name des zu verwendenden Vokabulars angegeben werden. |
`MODAL_PROVENANCE`                      | Erstellt eine Metadatengruppe, in der mehrere Felder zusammengefasst sind. Diese Felder können ebenfalls aus Vokabularen stammen. Das Feld ist wiederholbar und kann mehrere Vokabulare verwenden. |
