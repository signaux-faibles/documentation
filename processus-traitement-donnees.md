# Processus traitement des données

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Préambule](#pr%C3%A9ambule)
- [Vue d'ensemble des canaux de transformation des données](#vue-densemble-des-canaux-de-transformation-des-donn%C3%A9es)
  - [Étape 1 – Import](#%C3%A9tape-1--import)
  - [Étape 2 – Compactage](#%C3%A9tape-2--compactage)
  - [Étape 3 – Calcul des variables](#%C3%A9tape-3--calcul-des-variables)
- [Workflow classique](#workflow-classique)
- [Commande `sfdata`](#commande-sfdata)
- [La base de données MongoDB](#la-base-de-donn%C3%A9es-mongodb)
- [Spécificités de l'import](#sp%C3%A9cificit%C3%A9s-de-limport)
- [Spécificités du compactage](#sp%C3%A9cificit%C3%A9s-du-compactage)
- [Spécificités des calculs de variables](#sp%C3%A9cificit%C3%A9s-des-calculs-de-variables)
- [Spécificités de la publication de données](#sp%C3%A9cificit%C3%A9s-de-la-publication-de-donn%C3%A9es)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Préambule

Dans cette partie, nous explorons comment les données sont importées puis transformées par `sfdata`, à partir des fichiers bruts.

## Vue d'ensemble des canaux de transformation des données

Le schéma ci-dessous montre les différentes étapes de transformation des données.

![Schéma vue d'ensemble traitement](./traitement-donnees/Vue_densemble_traitement.png)

L'intégration et le stockage de données se fait par mises-à-jours successives, qu'on appelle "batch". Le parcours de la données est alors à chaque fois identique.

Note: La base de données MongoDB dans laquelle les données sont intégrées est spécifiée dans le fichier `config.toml`.

### Étape 1 – Import

Ce parcours est représenté avec des flêches pleines. Toutes les nouvelles données sont d'abord importées dans une collection ImportedData à l'aide de fonctions golang spécifiques à chaque type de fichier. La collection Admin définit quels sont les fichiers à intégrer pour chaque "batch". Le processus d'intégration et les potentielles erreurs d'ouverture de fichier, de lecture, ou de conversion sont logués dans la collection Journal.

Les données ainsi intégrées proviennent de fichiers de différents formats: .csv, .excel, .sas7dbat etc. La façon dont les données sont mises-à-jour peut également être différente, avec des fichiers qui annulent et remplacent, qu'on qualifiera de "fichiers stocks", et des fichiers qui viennent amender, qu'on qualifiera de "fichiers flux". Ceci est configuré dans la collection admin.

### Étape 2 – Compactage

Une fois le batch importées dans la collection ImportedData, elles vont venir compléter la collection RawData, qui concentrent les informations autour de l'établissement (identifiant: numéro siret) ou de l'entreprise (identifiant: numéro siren). C'est une opération de MapReduce qui est utilisé à cet effet.

Le processus de compactage consiste à attribuer à chaque objet les nouvelles données qui le concernent, vérifier si ces donneés étaient déjà connues (auquel cas l'objet n'est pas modifié), si les données amendent les informations connues, ou si des informations connues, qui ne seraient plus d'actualité, sont à supprimer.

La collection RawData conserve l'historique des modifications successives à chaque batch, ce qui rend possible de rétablir chaque objet dans son état après l'intégration de n'importe quel batch.

Si le compactage réussit, la collection ImportedData est purgée.

### Étape 3 – Calcul des variables

Enfin, les données ainsi stockées vont servir au calcul des variables qui alimenteront l'algorithme, stockées dans la collection Features. C'est à nouveau une opération de MapReduce qui permet de prendre en compte l'historique des données conservées dans RawData et calculer les variables pertinentes.

## Workflow classique

Le workflow classique d'intégration consiste à:

- Constituer un objet `batch` listant les fichiers de données à importer (cf [procédure avec `prepare-import`](procedure-import-donnees.md)), puis l'insérer dans la collection `Admin`.

- Mettre à jour la commande `sfdata`, depuis `ssh centos@labtenant -t tmux att`:

  ```sh
  killall sfdata
  cd opensignauxfaibles
  git pull
  go build # pour compiler la commande ./sfdata
  ./sfdata --help
  ```

- Appeler séquentiellement les fonctions d'intégration (et de contrôle) pour importer, compacter les données puis calculer les variables avec les options idoines:

  ```sh
  # 1. Import
  ./sfdata check --batch="1904"
  ./sfdata import --batch="1904"
  # 2. Compactage
  ./sfdata validate --collection="ImportedData"
  ./sfdata compact --since-batch="1904"
  ./sfdata validate --collection="RawData"
  # 3. Calcul et publication
  ./sfdata reduce --up-to-batch="1904"
  ./sfdata public --up-to-batch="1904"
  ```

Au cours de l'import, un log des début et des fin d'intégration de fichiers et de types de fichiers sont loggés dans la collection `Journal`. (cf [Journalisation/Logging de l'intégration](journalisation-integration.md))

Pendant le compactage et le calcul des variables, le log de MongoDB peut être consulté.

Entre ces traitements, une façon de s'assurer que le processus tourne est de vérifier qu'il n'y a pas d'erreur golang, et que MongoDB travaille, par exemple avec la commande _top_.

## Commande `sfdata`

L'intégralité des opérations sur les données se font au moyen de la commande `sfdata` (_CLI_ anciennement connu sous le nom de `dbmongo`), qui analyse et cadence les opérations à effectuer sur la base MongoDB.

Elle est implémentée en Golang, au sein du projet `opensignauxfaibles`.

```sh
cd opensignauxfaibles
go build # pour compiler la commande ./sfdata
./sfdata --help
```

Certaines des commandes seront plus amplement détaillées dans ce qui suit.

## La base de données MongoDB

Le stockage des données se fait dans une base de données "objet", notre choix s'est porté sur MongoDB. L'adresse et le port de la base de données est spécifiée dans le fichier `config.toml`.

Les différentes collections utilisées seront détaillées par la suite.

## Spécificités de l'import

L'import est le processus qui consiste à récupérer les fichiers bruts, c'est-à-dire dans le format dans lequel il a été transmis, de le lire, d'en extraire les informations pertinentes et de les intégrer dans la base de données mongodb.

L'intégration se fait par "batch". Chaque batch est défini dans la collection "Admin" de la base MongoDB par un objet de la forme suivante:

```js
{
  "_id": {
    "key": "1802", // Doit être en ordre alphabétique
    "type": "batch"
  },
  "files": {
    "admin_urssaf": ["/1802/admin_urssaf/admin_urssaf.csv"],
    "autre_type": ["Chemin/daccès/1.xlsx", "Chemin/daccès/2.xlsx"]
  },
  "readonly": true,
  "complete_types": ["apconso", "apdemande", "effectif"],
  "param": {
    "date_debut": ISODate("2014-01-01T00:00:00.000+0000"),
    "date_fin": ISODate("2018-12-01T00:00:00.000+0000"),
    "date_fin_effectif": ISODate("2018-06-01T00:00:00.000+0000")
  }
}
```

Le champ `_id` permet de spécifier qu'il s'agit un objet batch, et lui donne un nom, sous forme de clé. Attention, les batchs seront traités par ordre alphabétique. Par convention, les batchs sont intitulés "AAMM", en fonction de la période à laquelle ils sont intégrés, et peuvent être découpés en plusieurs parties nommée "AAMM_partX" ou X est incrémenté à chaque partie. Le champ `key` doit être unique.

Le champs `files` associe à un type un ou plusieurs fichiers. Les types définissent quel script d'intégration sera utilisé pour intégrer les fichiers mentionnés. Les chemins d'accès sont spécifiées avec comme racine le dossier défini dans config.toml avec le champs `APP_DATA`, sans `.` préalable au début du chemin d'accès. Une liste des types et des fichiers associés est donné dans le tableau, plus bas.

Le champ `readonly` permet d'empêcher la modification de l'objet par l'API, une fois les traitements lancés, pour assurer l'adéquation entre l'objet dans Admin et les objets importés.

Le champ `complete_types` est utile pour le comportement de compactage (cf paragraphe suivant). Les fichiers des types complets annulent et remplacent toutes les données précédemment importées pour ce type, alors que les autres viennent compléter les données passées.

Le champ `param` est utile pour le calcul des variables (cf le paragraphe à ce sujet). Il définit l'étendu des périodes à traiter et la dernière période pour laquelle les données d'effectif sont disponibles.

Les types reconnus sont listés dans [handlers.go](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/handlers.go) (variable `registeredParsers`) et dans [prepare-import](https://github.com/signaux-faibles/prepare-import/blob/master/prepareimport/filetypes.go).

| Parser              | type         | extension    | Scope                                 |
| ------------------- | ------------ | ------------ | ------------------------------------- |
| urssaf.Parser       | admin_urssaf | csv          | table etablissement <-> compte Urssaf |
|                     | cotisation   | csv          | compte Urssaf                         |
|                     | procol       | csv          | etablissement                         |
|                     | debit        | csv          | compte Urssaf                         |
|                     | effectif     | csv          | etablissement                         |
|                     | delai        | csv          | compte Urssaf                         |
|                     | dpae         | csv          | compte Urssaf                         |
|                     | ccsf         | csv          | compte Urssaf                         |
|                     | dmmo         | xlsx         | compte Urssaf                         |
| apartconso.Parser   | apconso      | xlsx         | etablissement                         |
| apartdemande.Parser | apdemande    | xlsx         | etablissement                         |
| altares.Parser      | altares      | csv          | etablissement                         |
| bdf.Parser          | bdf          | csv          | entreprise                            |
| interim.Parser      | interim      | sas7dbat     | etablissement                         |
| sirene.Parser       | sirene       | csv          | etablissement                         |
| diane.Parser        | diane        | script + csv | entreprise                            |

Les fichiers en provenance des urssaf ont été regroupées dans un parser spécifique du fait de leur dépendance à la table de correspondance entre comptes Urssaf et codes Siret, qui est ainsi chargée une seule fois en mémoire.

L'import est lancé de la manière suivante:

```sh
cd opensignauxfaibles
./sfdata import [options]
# Par exemple
./sfdata import --batch="1904" --parsers="urssaf,diane"
```

Le paramètre obligatoire `batch` indique la clé du batch à importer. Le paramètre optionnel `parsers`, qui est entré sous forme de tableau, permet de sélectionner les parsers à faire tourner. Par défaut, tous les parsers du batch sont lancés, cette option permet de corriger un type de fichier en particulier en cas d'erreur pendant l'intégration.

> Important: Pour prévenir l'intégration de données corrompues, nous recommandons l'usage de `./sfdata check` avant importation en base de données. (cf [Procédure d'importation de données](procedure-import-donnees.md))

## Spécificités du compactage

Le compactage est la procédure de fusion des nouvelles données importées avec les données importées dans des batchs antérieurs.

Le paramètre `complete_types` dans la collection Admin définit la manière dont les nouvelles données se comportent par rapport au données existantes. Si le type est "complet", ou en "stock" (c'est-à-dire que chaque nouveau fichier reprèsente le stock à la période courante) alors les nouvelles données remplacent intégralement les dernières. Attention, si aucun fichier n'est intégré et que le type est considéré comme complet, alors toutes les données passées seront ignorées. Les types qui ne sont pas complets sont dits de "flux" (c'est-à-dire que chaque nouveau fichier vient compléter les fichiers des périodes précédentes), et les données précédentes sont conservées.

Par exemple, si certaines données n'ont pas changé d'une période sur l'autre, alors il n'est pas nécessaire de réintégrer de fichier mais simplement de veiller que le type n'est pas listé parmi les `complete_types`.

Le compactage se lance avec la commande suivante:

```sh
cd opensignauxfaibles
./sfdata compact [options]
# Par exemple
./sfdata compact --fromBatchKey="1804"
```

L'option `fromBatchKey` indique le premier batch dans l'ordre alphabétique qui nécessite d'être compacté (c'est-à-dire qui a subi des changements). Tous les suivants le seront automatiquement.

> Important: Le compactage est une opération difficilement réversible. Pour prévenir toute corruption de données et/ou interruption prématurée du compactage, nous recommandons de valider les données importées avant leur compactage, à l'aide de `./sfdata validate --collection="ImportedData"`. (cf [Procédure d'importation de données](procedure-import-donnees.md))

## Spécificités des calculs de variables

TODO
`param` dans la collection Admin

Le calcul des variables est lancé de la manière suivante:

```sh
cd opensignauxfaibles
./sfdata reduce [options]
# Par exemple
./sfdata reduce --up-to-batch="1904" --key="01234567891011"
```

Le paramètre obligatoire `up-to-batch` spécifie la clé du dernier batch intégré.

Le paramètre facultatif `key` permet de ne faire tourner les calculs que pour un siret particulier, essentiellement pour des raisons de debugging. Les données sont alors importées dans la collection `Features_debug` plutôt que dans la collection `Features`.

## Spécificités de la publication de données

La publication de variables est lancée de la manière suivante:

```sh
cd opensignauxfaibles
./sfdata public [options]
# Par exemple
./sfdata public --up-to-batch="1904"
```

Le paramètre obligatoire `up-to-batch` spécifie la clé du dernier batch intégré.
