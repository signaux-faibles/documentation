# Architecture logicielle

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Objectifs du dispositif](#objectifs-du-dispositif)
- [Schéma fonctionnel](#sch%C3%A9ma-fonctionnel)
- [goup](#goup)
  - [Objectif](#objectif)
  - [Composition](#composition)
  - [Authentification JWT](#authentification-jwt)
  - [Traitement des fichiers uploadés](#traitement-des-fichiers-upload%C3%A9s)
  - [Structure du stockage](#structure-du-stockage)
  - [dépendances logicielles](#d%C3%A9pendances-logicielles)
- [opensignauxfaibles](#opensignauxfaibles)
  - [Objectif](#objectif-1)
  - [Modules](#modules)
    - [sfdata](#sfdata)
      - [Dépendances logicielles](#d%C3%A9pendances-logicielles)
      - [utilisation](#utilisation)
    - [module R/H2O](#module-rh2o)
  - [Flux de traitement](#flux-de-traitement)
  - [Publication vers datapi](#publication-vers-datapi)
- [datapi](#datapi)
  - [Objectif](#objectif-2)
  - [Principe d'alimentation](#principe-dalimentation)
  - [Principe de stockage / sécurité](#principe-de-stockage--s%C3%A9curit%C3%A9)
  - [Planification/péremption des données](#planificationp%C3%A9remption-des-donn%C3%A9es)
  - [Politiques de sécurité](#politiques-de-s%C3%A9curit%C3%A9)
  - [Principe de sécurité](#principe-de-s%C3%A9curit%C3%A9)
  - [Dépendances logicielles](#d%C3%A9pendances-logicielles-1)
- [signauxfaibles-web](#signauxfaibles-web)
  - [Connexion / Authentification](#connexion--authentification)
  - [Architecture interne](#architecture-interne)
  - [Dépendances logicielles](#d%C3%A9pendances-logicielles-2)
- [Briques extérieures](#briques-ext%C3%A9rieures)
  - [MongoDB](#mongodb)
  - [Keycloak](#keycloak)
  - [Structure du chargement JWT](#structure-du-chargement-jwt)
  - [PostgreSQL](#postgresql)
  - [Client tus](#client-tus)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Objectifs du dispositif

- récolter les données brutes en provenance des partenaires (goup + stockage POSIX)
- traiter/importer les données brutes ([prepare-import](https://github.com/signaux-faibles/prepare-import) + opensignauxfaibles + mongodb)
- raffiner les données pour obtenir les variables nécessaires à la bonne marche de l'algorithme (opensignauxfaibles + mongodb)
- exécuter la détection algorithmique (opensignauxfaibles + mongodb)
- publier les données à destination des agents (datapi + postgresql + signauxfaibles-web)

## Schéma fonctionnel

![schéma](architecture-logicielle/archi.png)

## goup

Plus de détails sont disponibles [ici](https://github.com/signaux-faibles/goup)

### Objectif

goup permet aux partenaires de déposer les fichiers de données brutes sur la plateforme.

### Composition

goup est basé sur [tusd](https://github.com/tus/tusd) et lui ajoute des fonctionnalités:

- authentification par JWT
- espaces privatifs par utilisateurs (gestion des droits et des chemins)
- supprime la possibilité de télécharger les fichiers

### Authentification JWT

En l'absence d'un JWT valide, le service refuse les sollicitations.  
Ce token devra en plus fournir dans son chargement une propriété `goup-path` correspondant au nom d'utilisateur posix ciblé par le versement.

### Traitement des fichiers uploadés

- Lors de l'envoi, le fichier n'est accessible qu'au serveur
- La métadonnée `private` associée à l'upload permettra au serveur de décider quel traitement effectuer sur le fichier pour sa mise à disposition.
- Une fois l'envoi complété, le fichier reste disponible dans l'espace du serveur de sorte qu'il pourra naturellement détecté que le fichier est déjà complet et éviter un deuxième envoi.
- Les droits sont fixés sur le fichier pour limiter l'accès aux utilisateurs souhaités (grace à la propriété `goup-path`)
- Un lien est créé dans l'espace de stockage ad-hoc.

### Structure du stockage

Le fichiers uploadés sont matérialisés sur le disque dur par deux fichiers nommés d'après le hash de l'upload généré par TUS:

- un fichier .bin qui contient les données du fichier
- un fichier .info qui contient les métadonnées

Le stockage est organisé dans 2 répertoires permanents:

- tusd: espace de traitement des upload par le serveur et accessible uniquement par ce dernier
- public: espace commun à tous les utilisateurs

1 répertoire privé pour chaque utilisateur (voir exemple ci-dessous)

Voici l'état du stockage après l'upload de 4 fichiers par deux utilisateurs:

- file1: user1, envoi public
- file2: user1, envoi privé
- file3: user2, envoi public
- file4: user2, envoie privé

```
chemin                           user:group            mode

.
+-- tusd                         goup:goup             770
|   +-- file1.bin                user1:users           660
|   +-- file1.info               user1:users           660
|   +-- file2.bin                user1:goup            660
|   +-- file2.info               user1:goup            660
|   +-- file3.bin                user2:users           660
|   +-- file3.info               user2:users           660
|   +-- file4.bin                user2:goup            660
|   +-- file4.info               user2:goup            660
+-- public                       user1:users           770
|   +-- file1.bin                user1:users           660
|   +-- file1.info               user1:users           660
|   +-- file3.bin                user2:users           660
|   +-- file3.info               user2:users           660
+-- user1                        user1:goup            770
|   +-- file2.bin                user1:goup            660
|   +-- file2.info               user1:goup            660
+-- user2                        user2:goup            770
|   +-- file4.bin                user2:goup            660
|   +-- file4.info               user2:goup            660
```

### dépendances logicielles

goup est développé en go (v1.10) et exploite les packages suivants:

- https://github.com/tus/tusd
- https://github.com/tus/tusd/filestore
- https://github.com/appleboy/gin-jwt
- https://github.com/gin-contrib/cors
- https://github.com/gin-gonic/gin
- https://github.com/spf13/viper

## opensignauxfaibles

### Objectif

opensignauxfaibles se charge du traitement des données:

- import des fichiers bruts (avec l'aide de [prepare-import](https://github.com/signaux-faibles/prepare-import))
- calcul des données d'entrée de l'algorithme
- stockage des résultats

Cette brique intègre le stockage de l'historique des données brutes, mais aussi calculées, ainsi que des résultats de façon à permettre l'audit des calculs a posteriori.

### Modules

#### sfdata

Écrit en Go, ce module centralise les fonctions de traitement des données suivantes:

- analyse des fichiers bruts
- conversion/insert dans mongodb
- ordonnancement des traitements mapreduce/aggregations mongodb
- publication vers datapi

##### Dépendances logicielles

- https://github.com/appleboy/gin-jwt
- https://github.com/gin-contrib/cors
- https://github.com/gin-contrib/static
- https://github.com/gin-gonic/gin
- https://github.com/gorilla/websocket
- https://github.com/spf13/viper
- https://github.com/swaggo/gin-swagger
- https://github.com/swaggo/gin-swagger/swaggerFiles
- https://github.com/globalsign/mgo
- https://github.com/globalsign/mgo/bson
- https://github.com/spf13/viper
- https://github.com/tealeg/xlsx
- https://github.com/chrnin/gournal
- MongoDB 4.2

> Note: Les dépendances et versions sont tenues à jour dans [README.md](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/README.md) et [go.mod](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/go.mod).

##### utilisation

`sfdata` est une commande (CLI) pour ordonner les traitements. Une documentation openapi est disponible [ici](https://raw.githubusercontent.com/signaux-faibles/opensignauxfaibles/master/sfdata/docs/swagger/swagger.yaml)

#### module R/H2O

Ce module permet le traitement algorithmique. (à écrire)

### Flux de traitement

![schéma](architecture-logicielle/workflow-osf.png)

1. Lecture des fichiers bruts ([sfdata](#sfdata))
1. Les données brutes sont converties et insérées dans mongodb ([sfdata](#sfdata))
1. Les données sont compactées dans mongodb par un traitement map-reduce ([sfdata](#sfdata))
1. Les variables sont calculées dans mongodb par un traitement map-reduce ([sfdata](#sfdata))
1. Le traitement algorithmique est effectué par le module [R/H2O](#module-rh2o)
1. Les résultats sont injectés dans mongodb par le module [R/H2O](#module-rh2o)
1. Les données nécessaires au frontend sont exportées dans datapi par le module ([sfdata](#sfdata))

Pour plus de détail sur le traitement des données et les transformations qui leur sont appliquées, voir [ici](processus-traitement-donnees.md).

### Publication vers datapi

opensignauxfaibles dispose d'un identifiant lui ouvrant la possibilité de publier des données sur datapi.
Il lui incombe de fournir à datapi:

- des données détaillées sur les établissements et les entreprises (niveau A)
- des données synthétiques sur les établissements et les entreprises (niveau B)
- les listes de détection (niveau A)
- les badges de sécurité pour tous les objets exportés afin d'appliquer les niveaux de sécurité.

Ce traitement est écrit en dur dans le code de sfdata [ici](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/sfdata/lib/engine/datapi.go)

## datapi

Le détail sur le fonctionnement de Datapi est disponible [ici](https://github.com/signaux-faibles/datapi)

datapi est écrit en go (1.10) et se base sur postgresql (10).

### Objectif

Dans cette infrastructure, datapi est la brique permettant la diffusion contrôlée des données produites dans le projet et sert notamment de back-end pour le signauxfaibles-web.  
Parmi les fonctionnalités notables:

- stockage arbitraire d'objets JSON
- gestion dynamique des permissions en lecture/écriture
- journalisation des requêtes
- programmation de la péremption des données

### Principe d'alimentation

![workflow](architecture-logicielle/workflow-datapi.png)
Il est à noter que:

- les insertions et lectures de données sont effectuées au sein de transactions postgres.
- la prise en compte de l'ajout de données et de politiques de sécurité est intégrée dans le système transactionnel de façon à présenter un comportement synchrone
- les permissions accordées aux utilisateurs sont véhiculées dans le token JWT et reposent sur la sécurité de keycloak, on les retrouve dans les rôles clients communiqués dans le token.

### Principe de stockage / sécurité

Un object datapi est identifié par une clé et de multiples feuillets composés d'un scope de sécurité (ensemble des badges nécessaires) et d'un objet contenant les données souhaitées.

datapi propose par ailleurs un système de paniers d'objets (buckets) qui permet de faciliter l'encodage des politiques de sécurité. Les politiques de sécurité sont stockées dans le bucket `system`.

Avec l'exemple ci-dessous, nous avons un objet qui pourra-être vu de 3 façons différentes selon le niveau d'accéditation:
![stockage](architecture-logicielle/datapi-object.png)

- un utilisateur disposant d'un scope vide verra:

```javascript
{
  raisonSociale: "TEST";
}
```

- un utilisateur disposant du scope [bfc]:

```javascript
{
  raisonSociale: "TEST",
  activitePartielle: [..., ..., ...]
}
```

- un utilisateur disposant du scope [bfc, crp]:

```javascript
{
  raisonSociale: "TEST",
  activitePartielle: [..., ..., ...],
  debitUrssaf: [..., ..., ...],
  bilanBDF: [..., ..., ...]
}
```

Une requête consiste à demander au serveur d'assembler les feuillets de tous les objets contenant la clé fournie dans la requête. Ce principe est appuyé sur l'opérateur `@>` du type hstore fourni par postgres, et comme on peut le voir ci-dessus, seuls les feuillets visibles par l'utilisateur sont utilisés dans l'assemblage.
Seul le premier niveau de clé de l'objet contenu dans la valeur d'un objet sont confrontés, ce qui expose le système à des risques de collision, et dans ce cas, c'est la valeur insérée en dernier qui remplace les valeurs précédentes.

### Planification/péremption des données

Il est possible de fournir à datapi une date de publication à un feuillet de données, et dans ce cas, ce feuillet sera ignoré tant que la date système n'aura pas atteint cette valeur.

La péremption des données est obtenue en publiant une version vide écrasant la donnée que l'on souhaite oblitérer avec une date de publication correspondant à la date de péremption.

Ce principe seul ne permet pas de supprimer les données de la base de données, il ne fait qu'en contenir la diffusion, toutefois il est envisagé d'avoir un traitement planifié pour retrouver toutes ces valeurs les oblitérer.

### Politiques de sécurité

Une politique de sécurité permet d'intéragir avec les permissions accordées aux utilisateurs. Le périmètre d'application d'une politique de sécurité est définie par une clé d'objet, un scope, un ensemble de buckets (définis par une expression régulière).

- en ajoutant des badges aux utilisateurs
- en ajoutant des badges aux objets

### Principe de sécurité

- Une ressource comporte des «badges» de sécurité (une liste de tags), les utilisateurs disposent dans leurs attributions de badges.
- Une ressource n'est disponible à un utilisateur que si il dispose de l'ensemble des badges demandés par la ressource.
- Des politiques de sécurités permettent de fixer des règles ajoutant des badges aux ressources (renforcement de la contrainte de sécurité) ou aux utilisateurs (promotion)
- Les politiques de sécurité peuvent s'appliquer à un ensemble d'objets

### Dépendances logicielles

- postgresql v10
- https://github.com/gin-contrib/cors
- https://github.com/gin-gonic/gin
- https://github.com/appleboy/gin-jwt
- https://github.com/swaggo/gin-swagger
- https://github.com/swaggo/gin-swagger/swaggerFiles
- https://github.com/gin-gonic/gin
- https://github.com/lib/pq
- https://github.com/lib/pq/hstore
- https://golang.org/x/crypto/bcrypt

## signauxfaibles-web

Il s'agit de l'interface web utilisée par les agents.
Elle communique avec datapi.

### Connexion / Authentification

![workflow](architecture-logicielle/workflow-sfw.png)
Les tokens JWT (long terme et session) contiennent notamment dans leur payload l'adresse email de l'agent auquel il est adressé et un contrôle est effectué pour empêcher une connexion avec un autre profil.

### Architecture interne

signauxfaibles-web est une application Vue.js écrite en TypeScript qui fait principalement usage des bibliothèques suivantes :

- Vuetify comme bibliothèque d'interface utilisateur
- Vuex pour centraliser la gestion des états de l'application
- axios pour faire des appels Ajax notamment à datapi
- ApexCharts comme bibliothèque de graphique

Elle est architecturée de la manière suivante :

| Vue                       | Description                                                                  | Vues parentes                                   |
| ------------------------- | ---------------------------------------------------------------------------- | ----------------------------------------------- |
| Browse                    | Consultation d'un établissement                                              |                                                 |
| Etablissement             | Fiche établissement                                                          | Browse, PredictionWidget                        |
| Etablissement/Commentaire | Commentaires sur un établissement                                            | Etablissement                                   |
| Etablissement/Effectif    | Effectifs de l'établissement (dont activité partielle)                       | Etablissement                                   |
| Etablissement/Finance     | _Non utilisé_                                                                | Etablissement                                   |
| Etablissement/Historique  | Historique des alertes issues des listes de détection passées                | Etablissement/Identite                          |
| Etablissement/Identite    | Identité de l'établissement (raison sociale, SIRET, coordonnées et activité) | Etablissement                                   |
| Etablissement/Map         | Carte dynamique                                                              | Etablissement                                   |
| Etablissement/NewComment  | Saisie d'un nouveau commentaire                                              | Etablissement/Commentaire, Etablissement/Thread |
| Etablissement/OldFinance  | Informations financières (dont CA, REX, etc.)                                | Etablissement                                   |
| Etablissement/Thread      | Fil de commentaires                                                          | Etablissement/Commentaire, Etablissement/Thread |
| Etablissement/Urssaf      | Cotisations et dettes Urssaf                                                 | Etablissement                                   |
| Goup                      | Envoi de données manuel                                                      |                                                 |
| Help                      | Menu d'aide contextuelle                                                     | Etablissement, Goup                             |
| Login                     | _Non utilisé_                                                                |                                                 |
| NavigationDrawer          | Menu latéral de navigation                                                   | App                                             |
| News                      | Changelog                                                                    | NavigationDrawer                                |
| PageNotFound              | Page non trouvée                                                             |                                                 |
| Prediction                | Liste de détection des établissements                                        |                                                 |
| PredictionWidget          | Élément de la liste                                                          | Prediction                                      |
| PredictionWidgetScore     | _Non utilisé_                                                                |                                                 |
| ScoreWidget               | Niveau d'alerte détecté                                                      | PredictionWidget, Historique                    |
| Security                  | Boîte de dialogue sur la confidentialité                                     | App                                             |
| Spinner                   | En cours de chargement                                                       | Prediction                                      |
| Toolbar                   | Barre supérieure                                                             | Browse, Goup                                    |
| Upload                    | Upload de fichier                                                            | Goup                                            |

Veuillez consulter la [documentation de l'interface graphique](interface-graphique.md) pour en savoir plus sur les aspects fonctionnels.

### Dépendances logicielles

Les dépendances logicielles sont gérées par yarn.

Voici les paquets requis par le projet par ordre alphabétique :

- [@babel/core](https://yarn.pm/@babel/core) (7.4.3) : Babel compiler core
- [@dsb-norge/vue-keycloak-js](https://yarn.pm/@dsb-norge/vue-keycloak-js) (1.1.1) : A Keycloak plugin for Vue >= 2.x
- [@types/jwt-decode](https://yarn.pm/@types/jwt-decode) (2.2.1) : TypeScript definitions for jwt-decode
- [apexcharts](https://yarn.pm/apexcharts) (3.8.6)
- [axios](https://yarnpkg.com/package/axios) (0.18.0) : Promise based HTTP client
- [core-js](https://yarn.pm/core-js) (2.6.5) : Modular standard library for JavaScript including polyfills for ECMAScript up to 2019
- [filesize](https://yarn.pm/filesize) (4.1.2) : JavaScript library to generate a human readable String describing the file size
- [identicon.js](https://yarn.pm/identicon.js) (2.3.3) : GitHub-style identicons as PNGs or SVGs in JS
- [jest](https://yarn.pm/jest) (>=22 <24) : Delightful JavaScript Testing
- [js-md5](https://yarn.pm/js-md5) (0.7.3) : A simple MD5 hash function for JavaScript supports UTF-8 encoding
- [jwt-decode](https://yarn.pm/jwt-decode) (2.2.0) : Decode JWT tokens which are Base64Url encoded
- [mapbox-gl](https://yarn.pm/mapbox-gl) (1.4.1) : A WebGL interactive maps librar
- [tiptap](https://yarn.pm/tiptap) (1.26.5) : A rich-text editor for Vue.js
- [tiptap-extensions](https://yarn.pm/tiptap-extensions) (1.28.5) : Extensions for tiptap
- [tus-js-client](https://yarn.pm/tus-js-client) (1.8.0-1) : A pure JavaScript client for the tus resumable upload protocol
- [uuid](https://yarn.pm/uuid) (3.3.3) : RFC4122 (v1, v4, and v5) UUIDs
- [vue](https://yarn.pm/vue) (2.6.10)
- [vue-apexcharts](https://yarn.pm/apexcharts) (1.5.0)
- [vue-class-component](https://yarn.pm/vue-class-component) (7.0.2) : ES201X/TypeScript class decorator for Vue components
- [vue-mapbox](https://yarn.pm/vue-mapbox) (0.4.1) : Combine powers of Vue.js and Mapbox Gl JS
- [vue-native-websocket](https://yarn.pm/vue-native-websocket) (2.0.13) : Native websocket implemantation for Vue.js and Vuex
- [vue-property-decorator](https://yarn.pm/vue-property-decorator) (8.1.0) : Property decorators for Vue Component
- [vue-router](https://yarn.pm/vue-router) (3.0.3) : Official router for Vue.js 2
- [vuetify](https://yarn.pm/vuetify) (1.5.5)
- [vuex](https://yarn.pm/vuex) (3.0.1)
- [vuex-persistedstate](https://yarn.pm/vuex-persistedstate) (2.5.4) : Persist and rehydrate your Vuex state between page reloads
- [webpack](https://yarn.pm/webpack) (4.30.0) : The module bundler

Voici les paquets spécifiques au développement par ordre alphabétique :

- [@types/jest](https://yarn.pm/@types/jest) (23.1.4) : TypeScript definitions for Jest
- [@vue/cli-plugin-babel](https://yarn.pm/@vue/cli-plugin-babel) (3.6.0) : Babel plugin for vue-cli
- [@vue/cli-plugin-e2e-nightwatch](https://yarn.pm/@vue/cli-plugin-e2e-nightwatch) (3.6.0) : e2e-nightwatch plugin for vue-cli
- [@vue/cli-plugin-typescript](https://yarn.pm/@vue/cli-plugin-typescript) (3.6.0) : Typescript plugin for vue-cli
- [@vue/cli-plugin-unit-jest](https://yarn.pm/@vue/cli-plugin-unit-jest) (3.6.0) : unit-jest plugin for vue-cli
- [@vue/cli-service](https://yarn.pm/@vue/cli-service) (3.6.0) : Local service for vue-cli projects
- [@vue/test-utils](https://yarnpkg.com/package/@vue/test-utils) (1.0.0-beta.29) : Utilities for testing Vue components.
- [babel-core](https://yarn.pm/babel-core) (7.0.0-bridge.0) : Babel compiler core
- [stylus](https://yarn.pm/stylus) (0.54.5) : Robust, expressive, and feature-rich CSS superset
- [stylus-loader](https://yarn.pm/stylus-loader) (3.0.1) : Stylus loader for webpack
- [ts-jest](https://yarn.pm/ts-jest) (23.0.0) : A preprocessor with source maps support to help use TypeScript with Jest
- [typescript](https://yarn.pm/typescript) (3.4.3) : TypeScript is a language for application scale JavaScript development
- [vue-cli-plugin-vuetify](https://yarnpkg.com/package/vue-cli-plugin-vuetify) (0.5.0) : Vuetify Framework Plugin for Vue CLI 3
- [vue-template-compiler](https://yarn.pm/vue-template-compiler) (2.5.21) : Template compiler for Vue 2.0
- [vuetify-loader](https://yarn.pm/vuetify-loader) (1.0.5) : A Webpack plugin for treeshaking Vuetify components

## Briques extérieures

### MongoDB

La version de MongoDB utilisée est la 4.2.

> Note: Les dépendances et versions sont tenues à jour dans [README.md](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/README.md) et [go.mod](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/go.mod).

### Keycloak

Il s'agit du produit officiel développé par Red Hat.
Keycloak fournit les services d'authentification pour `goup` et `datapi` en forgeant les JWT des utilisateurs.

Ce produit est utilisé en version 6.0.1.

### Structure du chargement JWT

Le chargement du token est effectué par Keycloak à l'aide du modèle utilisateur.

Un attribut utilisateur `goup-path` fixé dans Keycloak sera utilisé pour fixer le nom d'utilisateur à utiliser sur l'infrastructure pour l'enregistrement des fichiers.

Le scope utilisé par datapi sera accessible au travers des rôles clients configurés également dans Keycloak et fixés par utilisateur.

### PostgreSQL

La version utilisée est la 10.8.
Le module hstore du packages contrib est utilisé.

### Client tus

Un exemple de client tus (protocole de téléchargement résumable) est fourni [ici](https://github.com/signaux-faibles/goup/tree/master/goup-client) et permet de voir une implémentation JavaScript basée sur le client officiel.  
On trouve toutefois des clients dans de nombreux langages qui permettront aux utilisateurs d'intégrer l'upload de fichier dans leurs plateformes.
