<!-- importé depuis https://github.com/signaux-faibles/prepare-import/blob/master/tools/procedure_import.md -->

# Procédure pour importer les données mensuelles

Cette procédure décrit:

- comment récupérer les fichiers de données de nos partenaires;
- comment constituer un objet `batch` à partir de ces fichiers, en vue de les importer dans la base de données MongoDB, à l'aide de `dbmongo`. (cf [Processus de traitement des données](processus-traitement-donnees.md))

La plupart de ces opérations sont menées sur `stockage`, serveur sur lequel sont reçus et conservés les fichiers régulièrement transmis par nos partenaires.

## Mettre à jour les outils

Depuis `ssh stockage -R 1080` (pour se connecter à `stockage` en partageant la connexion internet de l'hôte via le port `1080`):

```sh
curl google.com --proxy socks5h://127.0.0.1:1080 # pour tester le bon fonctionnement du proxy http
git config --global http.proxy 'socks5h://127.0.0.1:1080' # si nécéssaire: pour que git utilise le proxy
cd /home/centos/prepare-import
git pull # pour mettre à jour les outils
go build
```

## Mettre les nouveaux fichiers dans un répertoire spécifique

Depuis `ssh stockage`:

```sh
sudo su
cd /var/lib/goup_base/public
mkdir _<batch>_
tools/goupy.py . # pour afficher les métadonnées de chaque fichier de données
# /!\ Attention commande suivante non fonctionnelle !
find -maxdepth 1 -ctime -10 -print0 | xargs -0 mv -t _<batch>_/
```

## Télécharger le fichier Siren

Depuis `ssh stockage`:

```sh
cd /var/lib/goup_base/public/_<batch>_
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

Utiliser `prepare-import` depuis `ssh stockage`:

```sh
~/prepare-import/prepare-import -batch "<BATCH>" -path "../goup/public"
```

Penser à changer le nom du batch en langage naturel: ex "Février 2020".

## (Re)lancer le serveur API `dbmongo` (optionnel)

Depuis `ssh centos@labtenant -t tmux att`:

```sh
killall dbmongo
cd opensignauxfaibles/dbmongo
git pull
go build
./dbmongo
```

> Documentation de référence: [API servie par Golang](processus-traitement-donnees.md#lapi-servie-par-golang)

## Lancer l'import

Depuis `ssh stockage -t tmux att`:

```sh
http :3000/api/data/check batch="2002_1"
```

Vérifier dans les logs que les fichiers sont bien valides. Corriger le batch si nécéssaire.

Puis, toujours depuis `ssh stockage -t tmux att`:

```sh
http :3000/api/data/import batch="2002_1"
```

> Documentation de référence: [Spécificités de l'import](processus-traitement-donnees.md#sp%C3%A9cificit%C3%A9s-de-limport)

## Lancer le compactage

Le compactage consiste à intégrer dans la collection `RawData` les données du batch qui viennent d'être importées dans la collection `ImportedData`.

Commencer par vérifier la validité des données importées, depuis `ssh stockage -t tmux att`:

```sh
http :3000/api/data/validate collection="ImportedData" # valider les données importées
http :3000/api/data/validate collection="RawData"      # valider les données déjà en bdd (recommandé)
```

Afficher les entrées de données invalides depuis `ssh centos@labtenant -t tmux att`:

```sh
cd opensignauxfaibles/dbmongo
zcat <nom_du_fichier_retourné_par_API>
```

Puis, avant de lancer le compactage, corriger ou supprimer les entrées invalides éventuellement trouvées dans les collections `ImportedData` et/ou `Rawdata`.

Une fois les données validées, toujours depuis `ssh stockage -t tmux att`:

```sh
http :3000/api/data/compact batch="2002_1"
```

> Documentation de référence: [Spécificités du compactage](processus-traitement-donnees.md#sp%C3%A9cificit%C3%A9s-du-compactage)

## Calcul des variables et génération de la liste de detection

> Documentation de référence: [Exécution des calculs pour populer la collection `Features`](prise-en-main.md#5-ex%C3%A9cution-des-calculs-pour-populer-la-collection-features)
