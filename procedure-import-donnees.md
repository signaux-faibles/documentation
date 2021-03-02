<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Procédure pour importer les données mensuelles](#proc%C3%A9dure-pour-importer-les-donn%C3%A9es-mensuelles)
  - [Structure des fichiers](#structure-des-fichiers)
  - [Mettre à jour les outils](#mettre-%C3%A0-jour-les-outils)
  - [Mettre les nouveaux fichiers dans un répertoire spécifique](#mettre-les-nouveaux-fichiers-dans-un-r%C3%A9pertoire-sp%C3%A9cifique)
  - [Télécharger le fichier Siren](#t%C3%A9l%C3%A9charger-le-fichier-siren)
  - [Télécharger le fichier Diane](#t%C3%A9l%C3%A9charger-le-fichier-diane)
  - [Créer un objet admin pour l'intégration des données](#cr%C3%A9er-un-objet-admin-pour-lint%C3%A9gration-des-donn%C3%A9es)
  - [Mettre à jour la commande `sfdata` (optionnel)](#mettre-%C3%A0-jour-la-commande-sfdata-optionnel)
  - [Lancer l'import](#lancer-limport)
  - [Lancer le compactage](#lancer-le-compactage)
  - [Calcul des variables et génération de la liste de detection](#calcul-des-variables-et-g%C3%A9n%C3%A9ration-de-la-liste-de-detection)
  - [Maintenance: nettoyage des données hors périmètre](#maintenance-nettoyage-des-donn%C3%A9es-hors-p%C3%A9rim%C3%A8tre)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<!-- importé depuis https://github.com/signaux-faibles/prepare-import/blob/master/tools/procedure_import.md -->

> Note: Les informations liées à l'environnement de production ont été déplacées sur notre wiki d'équipe.

# Procédure pour importer les données mensuelles

Cette procédure décrit:

- la structure recommandée pour organiser les fichiers par (sous-)batch;
- comment récupérer les fichiers de données de nos partenaires;
- comment constituer un objet `batch` à partir de ces fichiers, en vue de les importer dans la base de données MongoDB, à l'aide de `sfdata`. (cf [Processus de traitement des données](processus-traitement-donnees.md))

## Structure des fichiers

Un _batch_ est un ensemble de fichiers de données permettant de constituer (à minima) un _périmètre SIREN_ (aussi appelé _filtre_ ou _filter_) à partir de données `effectif` fraiches. Les fichiers d'un _batch_ sont réunis dans un même répertoire. Le nom d'un _batch_ est sous la forme `AAMM`, soit les deux derniers chiffres de l'année suivi par les deux chiffres du mois.

Un _sous-batch_ est un ensemble de fichiers de données venant compléter un _batch_ déjà importé, en ré-utilisant le _périmètre SIREN_ de ce _batch_. Les fichiers d'un _sous-batch_ sont réunis dans un même répertoire, lui-même contenu dans le répertoire du _batch_ qu'il complète. Le nom d'un _sous-batch_ est sous la forme `AAMM_NN`, soit le nom du _batch_ parent suivi par un numéro à incrémenter pour chaque _sous-batch_.

Voici une illustration de la structure des répertoires attendue par `prepare-import`, en supposant que nous ayons deux _batches_ et un _sous-batch_ sur la période de Février 2018:

```
|-- 1801
|-- 1802
|    |-- 1802_01
```

La génération de _batch_ ou _sous-batch_ s'effectue depuis le répertoire contenant les _batches_:

```sh
$ ~/prepare-import/prepare-import --batch 1801
$ ~/prepare-import/prepare-import --batch 1802
$ ~/prepare-import/prepare-import --batch 1802_01
```

Les informations suivantes seront inférées automatiquement par `prepare-import`:

- `filter`: fichier de _périmètre SIREN_ hérité ou généré depuis le fichier `effectif` du batch parent
- `date_fin_effectif`: date détectée depuis le fichier `effectif` du batch parent

Note: quand on appelle `prepare-import` sur un sous-batch, le fichier `filter` du batch parent sera copié dans le répertoire du sous-batch, et intégré dans l'objet `Admin` résultant, en conservant le même nom de fichier.

## Mettre à jour les outils

```sh
cd ~/prepare-import/
git pull # pour mettre à jour les outils
go build
```

## Mettre les nouveaux fichiers dans un répertoire spécifique

```sh
sudo su
cd /var/lib/goup_base/public
mkdir _<batch>_
~/prepare-import/tools/goupy.py . # pour afficher les métadonnées de chaque fichier de données
# /!\ Attention commande suivante non fonctionnelle !
find -maxdepth 1 -ctime -10 -print0 | xargs -0 mv -t _<batch>_/
```

## Télécharger le fichier Siren

```sh
cd _<batch>_
curl https://files.data.gouv.fr/insee-sirene/StockUniteLegale_utf8.zip | zcat > sireneUL.csv
curl https://data.cquest.org/geo_sirene/v2019/last/StockEtablissement_utf8_geo.csv.gz | zcat > StockEtablissement_utf8_geo.csv
```

> Notes:
>
> - Disponible depuis [la page de la Base Sirene](https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/), le fichier `sireneUL.csv` contient les données par entreprise
> - Le fichier `StockEtablissement_utf8_geo.csv` contient les données par établissement de data.gouv.fr enrichies de leur géolocalisation. La composante `v2019` représente la version du format de fichier, et non la fraicheur des données.

## Télécharger le fichier Diane

1. Se connecter sur le site [Diane+](https://diane.bvdinfo.com)

2. Identifier le numéro de la nouvelle variable à importer. (ex: `CF00011`)
   Le suivant du dernier numéro déjà importé dans:
   _Mes données_ > _Données importées_ > _Importer nouvelle variable_

3. Créer la nouvelle variable en indiquant qu'il s'agit d'un champs `identifiant d'entreprise`. Télécharger le fichier.

4. Transformer le filtre de périmètre généré par `prepare-import` lors du dernier import d'un fichier `effectif`:
   `$ tools/filter_to_diane -v var_num="CF000xx" ../20xx/filter_20xx.csv > ../diane_req/diane_filter_20xx.csv`
   puis `$ ssconvert ../diane_req/diane_filter_20xx.csv ../diane_req/diane_filter_20xx.xls`
   ... en spécifiant le numéro de la nouvelle variable dans le paramètre `var_num`.
   Par exemple si le dernier est `CF00011` dans diane+ alors il faut passer `CF00012` au script.

5. Dans l'interface _importer nouvelle variable_ de Diane+, envoyer le fichier Excel ainsi généré.

6. Sélectionner la nouvelle variable dans:
   _Mes données_ > _Données importées_ > _Entreprises avec une donnée importée_

> _Autres ..._

Cette sélection peut-être complétée avec:
_Entreprises mises à jour_ > _Données financières et descriptives_

## Créer un objet admin pour l'intégration des données

```sh
~/prepare-import/prepare-import -batch "<BATCH>"
```

Penser à changer le nom du batch en langage naturel: ex "Février 2020".

Insérer le document résultant dans la collection `Admin`.

## Mettre à jour la commande `sfdata` (optionnel)

```sh
cd opensignauxfaibles
git checkout master            # sélectionne la branche principale de sfdata
git pull                       # met à jour le code source de sfdata
make build-prod                # compile sfdata pour l'environnement de production
./sfdata --help                # vérifie que la commande fonctionne
```

> Documentation d'usage: [Commande `sfdata`](processus-traitement-donnees.md#commande-sfdata)

## Lancer l'import

```sh
./sfdata check --batch="2002_1"
```

Vérifier dans les logs que les fichiers sont bien valides. Corriger le batch si nécéssaire.

Puis:

```sh
./sfdata import --batch="2002_1"
```

> Documentation de référence: [Workflow classique](processus-traitement-donnees.md#workflow-classique) et [Spécificités de l'import](processus-traitement-donnees.md#sp%C3%A9cificit%C3%A9s-de-limport)

## Lancer le compactage

Le compactage consiste à intégrer dans la collection `RawData` les données du batch qui viennent d'être importées dans la collection `ImportedData`.

Commencer par vérifier la validité des données importées:

```sh
./sfdata validate --collection="ImportedData" # valider les données importées
./sfdata validate --collection="RawData"      # valider les données déjà en bdd (recommandé)
```

Les entrées de données invalides seront rendues dans la sortie standard.

Puis, avant de lancer le compactage, corriger ou supprimer les entrées invalides éventuellement trouvées dans les collections `ImportedData` et/ou `Rawdata`.

Une fois les données validées:

```sh
./sfdata compact --batch="2002_1"
```

> Documentation de référence: [Spécificités du compactage](processus-traitement-donnees.md#sp%C3%A9cificit%C3%A9s-du-compactage)

## Calcul des variables et génération de la liste de detection

> Documentation de référence: [Exécution des calculs pour populer la collection `Features`](prise-en-main.md#5-ex%C3%A9cution-des-calculs-pour-populer-la-collection-features)

## Maintenance: nettoyage des données hors périmètre

Dans le cas où certaines entités (entreprises et/ou établissements) seraient représentées dans la collection `RawData` alors qu'elles ne figurent pas dans le _périmètre SIREN_ (représenté par le fichier _filtre_ rattaché à tout _batch_ importé dans la base de donnée), il convient de les retirer afin d'alléger le stockage et les traitements de données.

Ce traitement est destructif et irréversible, il convient de porter une attention particulière si le nombre de document à supprimer est conséquent.

Pour cela, utiliser la commande `sfdata pruneEntities`:

```sh
# dry-run, pour compter les entités à supprimer
./sfdata pruneEntities --batch=2010 --count

# après vérification, supprimer ces entités de RawData
./sfdata pruneEntities --batch=2010 --delete
```

Remplacer l'identifiant de _batch_ par celui du dernier _batch_ importé avec un fichier _filtre_ à jour.
