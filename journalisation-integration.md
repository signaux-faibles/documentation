<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Journalisation de l'Intégration des données](#journalisation-de-lint%C3%A9gration-des-donn%C3%A9es)
  - [Accès](#acc%C3%A8s)
  - [Structure](#structure)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Journalisation de l'Intégration des données

Le moteur d'intégration de données [opensignauxfaibles](https://github.com/signaux-faibles/opensignauxfaibles) génère des logs qui permettent le suivi de son bon déroulement et le traitement statistique des données d'import par type de fichier.

## Accès

Les données du journal sont stockées dans la collection `Journal` de la base de données de MongoDB.

Un [outil en ligne de commande](https://github.com/signaux-faibles/opensignauxfaibles/tree/master/tools/logsReport) permet de récupérer et d'explorer les données du journal, par exemple pour vérifier que l'Intégration des données s'est bien passée.

## Structure

Les champs du journal respectent un schéma commun afin de faciliter leur lecture et leur traitement statistique. Il est documenté ci-dessous.

- `date`: `(timestamp)` date d'émission du log
- `reportType`: `(str)` étape du traitement ayant émis cette entrée de Journal (ex: `ImportBatch` ou `CheckBatch`)
- `event`: `(object)`
  - `linesParsed`: `(int)` nombre de lignes lues dans le fichier
  - `linesValid`: `(int)` nombre de lignes valides et intégrées
  - `linesSkipped`: `(int)` nombre de lignes sautées (ex: exclue par filtre SIRET/SIREN)
  - `linesRejected`: `(int)` nombre de lignes rejetées (ex: erreurs de syntaxe)
  - `isFatal`: `(bool)` indique si une erreur fatale s'est produite (causant l'arret de l'import)
  - `headRejected`: `(list)` les 200 premiers messages pour les lignes rejetées (_NB_: plusieurs messages de rejets peuvent avoir attrait à la même ligne d'un fichier)
  - `headFatal`: `(list)` le message d'erreur fatale
  - `batchKey`: `(str)` l'ID du batch traité
  - `summary`: `(str)` un résumé lisible des informations susnommées
- `priority`: `(str)` Le niveau de log (ici, `INFO`)
- `parserCode`: `(str)` le nom du parseur de fichier utilisé (c'est un bon proxy pour le type de fichier traité)

NB : Si tout va bien, on doit avoir

`linesValid` = `linesParsed` - `linesSkipped` - `linesRejected`
