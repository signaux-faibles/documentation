# Prise en main

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Survol des services Web](#survol-des-services-web)
- [Developpement Datapi et frontal en local](#developpement-datapi-et-frontal-en-local)
  - [1. Configuration](#1-configuration)
  - [2. Lancer la base de données en local avec Docker](#2-lancer-la-base-de-donn%C3%A9es-en-local-avec-docker)
  - [3. Initialiser la base de données locale](#3-initialiser-la-base-de-donn%C3%A9es-locale)
  - [4. Lancer keycloak (fournisseur identité oauth2) avec Docker](#4-lancer-keycloak-fournisseur-identit%C3%A9-oauth2-avec-docker)
  - [5. Lancer datapi](#5-lancer-datapi)
  - [6. Créer un utilisateur sur Keycloak](#6-cr%C3%A9er-un-utilisateur-sur-keycloak)
  - [7. Compiler et lancer le frontal](#7-compiler-et-lancer-le-frontal)
  - [8. Paramétrer `signauxfaibles-web` pour l'usage en local](#8-param%C3%A9trer-signauxfaibles-web-pour-lusage-en-local)
- [Étape de calculs pour populer "`Features`"](#%C3%A9tape-de-calculs-pour-populer-features)
  - [1. Lancement de mongodb avec Docker](#1-lancement-de-mongodb-avec-docker)
  - [2. Préparation du répertoire de données `${DATA_DIR}`](#2-pr%C3%A9paration-du-r%C3%A9pertoire-de-donn%C3%A9es-data_dir)
  - [3. Installation et configuration de `dbmongo`](#3-installation-et-configuration-de-dbmongo)
  - [4. Ajout de données de test](#4-ajout-de-donn%C3%A9es-de-test)
  - [5. Exécution des calculs pour populer la collection "`Features`"](#5-ex%C3%A9cution-des-calculs-pour-populer-la-collection-features)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Survol des services Web

- `nginx` sert l'application [frontal](https://github.com/signaux-faibles/signauxfaibles-web) (en vuejs) accessible aux utilisateurs
- `datapi` donne accès à certaines données de notre base de données au frontal, en respectant les droits de l'utilisateur qui les demande
- `fider` est un système externe permettant d'échanger avec les utilisateurs du frontal

## Developpement Datapi et frontal en local

### 1. Configuration

Créer le fichier `config.toml`:

```toml
bind = "127.0.0.1:3000"
postgres = "user=postgres dbname=datapi password=mysecretpassword host=localhost sslmode=disable"
keycloakHostname = "http://127.0.0.1:8080"
keycloakClientID = "signauxfaibles"
keycloakRealm = "master"
keycloakAdmin = "mykeycloak"
keycloakPassword = "mysecretpassword"
keycloakAdminRealm = "master"
```

### 2. Lancer la base de données en local avec Docker

Après avoir installé Docker, exécutez les commandes suivantes:

```sh
$ docker run \
    -d postgres:10 \
    --name sf-postgres \
    -P -p 127.0.0.1:5432:5432 \
    -e POSTGRES_PASSWORD=mysecretpassword
```

> Note: ces paramètres doivent coincider avec celles fournies dans la variable `postgres` du fichier `config.toml`.

Pour tester la connexion:

```sh
$ docker exec -it sf-postgres psql -U postgres
# => puis taper ctrl-D pour quiter
```

### 3. Initialiser la base de données locale

Exécutez les commandes suivantes:

```sh
$ echo "create database datapi;" \
    | docker exec -i sf-postgres psql -U postgres
```

> Notes:
>
> - Plus tard, pensez à couper le serveur avec `docker ps`, `docker kill` puis `docker rm sf-postgres`.

### 4. Lancer keycloak (fournisseur identité oauth2) avec Docker

Exécutez les commandes suivantes:

```sh
$ docker run \
    -d jboss/keycloak \
    -p 8080:8080 \
    -e KEYCLOAK_USER=mykeycloak \
    -e KEYCLOAK_PASSWORD=mysecretpassword
```

> Notes:
>
> - Les paramètres ci-dessus doivent coincider avec les valeurs fournies dans les variables `keycloakHostname`, `keycloakAdmin` et `keycloakPassword` du fichier `config.toml`.
> - Plus tard, pensez à couper le serveur avec `docker ps`, `docker kill` puis `docker rm`.

### 5. Lancer datapi

L'exécutable datapi s'attend à trouver config.toml dans le répertoire de travail courant, veillez à vous positionner là où vous l'avez créé

```sh
$ go get github.com/signaux-faibles/datapi
# Au premier lancement, créer le schéma
$ $(go env GOPATH)/bin/datapi -createschema
# Pour lancer le serveur datapi
$ $(go env GOPATH)/bin/datapi -api
```

Pour tester:

```sh
$ curl 127.0.0.1:3000 # => la requête doit s'afficher dans les logs de datapi
```

### 6. Créer un utilisateur sur Keycloak

1. ouvrir http://localhost:8080/auth/admin/master/console/#/realms/master
2. se connecter avec identifiants fournis au lancement du container keycloak
3. créer un client `signauxfaibles` (comme client ID et nom)
4. spécifier les paramètres suivants depuis l'onglet "Settings":

- Implicit Flow Enabled: `ON`
- Valid Redirect URIs: `http://localhost:8081/*`
- Base URLs: `http://localhost:8081/`
- Web Origins: `http://localhost:8081` (attention: ne pas inclure de slash en fin d'URL !)

5. Ajouter un role `urssaf`
6. Dans "Users", ouvrir le username `mykeycloak`
7. Onglet "Role Mappings": choisir le role `signaux-faibles` puis y ajouter `urssaf`

### 7. Compiler et lancer le frontal

1. Exécutez les commandes suivantes:

   ```sh
   $ git clone https://github.com/signaux-faibles/signauxfaibles-web
   $ cd signauxfaibles-web
   $ nvm use 12 # pour utiliser la version 12 de Node.js, dans la mesure du possible
   $ npm install -g yarn
   ```

2. Suivre les instructions d'installation de [signauxfaibles-web](https://github.com/signaux-faibles/signauxfaibles-web).

3. Ouvrir http://localhost:8081/ dans votre navigateur.

### 8. Paramétrer `signauxfaibles-web` pour l'usage en local

1. Replacements à effectuer dans `src/main.ts`:

   - `local = 'http://localhost/auth/'` --> `local = 'http://localhost:8080/auth/'`
   - `url: prod` --> `url: local`

2. Replacements à effectuer dans `store.ts`:

   - `baseURL = '/'` --> `baseURL = 'http://localhost:3000/'`

## Étape de calculs pour populer "`Features`"

Cette étape exécute les calculs effectués après les étapes d'import et de compactage de la collection "`DataRaw`", en vue de populer "`Features`", la collection qui alimente le modèle prédictif.

### 1. Lancement de mongodb avec Docker

Après avoir installé Docker, exécutez les commandes suivantes:

```sh
$ docker run \
    mongodb:4 \
    --name sf-mongodb \
    --publish 27017:27017 \
    --rm # retirez ce paramètre si vous voulez pouvoir réutiliser ce conteneur plus tard
```

Pour tester la connexion:

```sh
$ docker exec -it sf-mongo mongo signauxfaibles

> show collections

# puis pressez Ctrl-C pour quitter le client mongo
```

### 2. Préparation du répertoire de données `${DATA_DIR}`

Exécutez les commandes suivantes:

```sh
$ DATA_DIR=$(pwd)/opensignauxfaibles-data-raw
$ mkdir ${DATA_DIR}
$ touch ${DATA_DIR}/dummy.csv
```

### 3. Installation et configuration de `dbmongo`

Exécutez les commandes suivantes:

```sh
$ git clone https://github.com/signaux-faibles/opensignauxfaibles.git
$ cd opensignauxfaibles
$ cd dbmongo
$ go build
$ cp config-sample.toml config.toml
$ sed -i '' "s,/foo/bar/data-raw,${DATA_DIR}," config.toml
$ sed -i '' 's,naf/.*\.csv,dummy.csv,' config.toml
```

### 4. Ajout de données de test

Exécutez les commandes suivantes:

```sh
$ docker exec -it sf-mongo mongo signauxfaibles

> db.createCollection('RawData')

> db.Admin.insertOne({
    "_id" : {
        "key" : "1910",
        "type" : "batch"
    },
    "files" : {
        "bdf" : [
            "/1910/bdf_1910.csv"
        ]
    },
    "complete_types" : [
    ],
    "param" : {
        "date_debut" : ISODate("2014-01-01T00:00:00.000+0000"),
        "date_fin" : ISODate("2019-10-01T00:00:00.000+0000"),
        "date_fin_effectif" : ISODate("2019-07-01T00:00:00.000+0000")
    },
    "name" : "Octobre"
  })

> db.RawData.remove({})

> db.RawData.insertOne({
    "_id": "01234567891011",
    "value": {
        "scope": "etablissement",
        "index": {
        "algo2": true
        }
    }
  })

# puis pressez Ctrl-C pour quitter le client mongo
```

### 5. Exécution des calculs pour populer la collection "`Features`"

Après avoir installé [HTTPie – command line HTTP client](https://httpie.org/), exécutez la commande suivante:

```sh
$ http :5000/api/data/reduce algo=algo2 batch=1910 key=012345678
```

Puis vérifiez que la collection `Features_debug` a bien été populée par la chaine d'intégration:

```sh
$ docker exec -it sf-mongo mongo signauxfaibles

> db.Features_debug.find()

# puis pressez Ctrl-C pour quitter le client mongo
```

### 6. En cas d'erreur – afficher le journal de MongoDB

Il peut arriver qu'un appel API de traitement de données échoue et retourne le message d'erreur suivant: `erreurs constatées, consultez les journaux`.

Dans ce cas, vous pouvez trouver le détail de ces erreurs dans les logs de MongoDB:

```sh
$ docker logs sf-mongodb | grep "uncaught exception"
```
