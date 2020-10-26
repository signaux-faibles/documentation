# Journalisation de l'Intégration des données

Le moteur d'intégration de données [opensignauxfaibles](https://github.com/signaux-faibles/opensignauxfaibles) génère des logs qui permettent le suivi de son bon déroulement et le traitement statistique des données d'import par type de fichier.

### Accès

Les données du journal sont stockées dans la collection `Journal` de la base de donnée `test` de MongoDB.

### Structure

Les champs du journal respectent un schéma commun afin de faciliter leur lecture et leur traitement statistique. Il est documenté ci-dessous.

- `date`: (timestamp) date d'émission du log
- `event`: (`object`)
    - `linesParsed`: `(int)` nombre de lignes parsées dans le fichier
    - `linesValid`: `(int)` nombre de lignes valides et intégrées
    - `linesSkipped`: `(int)` nombre de lignes sautées
    - `linesRejected`: `(int)` nombre de lignes rejetées
    - `isFatal`: `(bool)` indique si une erreur fatal s'est produite (causant l'arret de l'import)
    - `headSkipped`: `(list)` les 200 premiers messages pour les lignes sautées
    - `headRejected`: `(list)` les 200 premiers messages pour les lignes rejetées (_NB_: plusieurs messages de rejets peuvent avoir attrait à la même ligne d'un fichier)
    - `headFatal`: `(list)` le message d'erreur fatale
    - `batchKey`: `(str)` l'ID du batch traité
    - `summary`: `(str)` un résumé lisible des informations susnommées
- `priority`: `(str)` Le niveau de log (ici, `INFO`)
- `parserCode`: `(str)` le nom du parseur de fichier utilisé (c'est un bon proxy pour le type de fichier traité)

NB : Si tout va bien, on doit avoir

`linesValid` = `linesParsed` - `linesSkipped` - `linesRejected`