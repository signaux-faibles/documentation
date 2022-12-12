# Comment intégrer une nouvelle source de données

Cette page donne la marche à suivre pour intégrer une nouvelle source de données, en plusieurs étapes:

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Définition des attentes / Écriture de tests automatisés](#d%C3%A9finition-des-attentes--%C3%89criture-de-tests-automatis%C3%A9s)
- [Implémentation du parseur](#impl%C3%A9mentation-du-parseur)
- [Mise à disposition des données pour la chaine de traitement](#mise-%C3%A0-disposition-des-donn%C3%A9es-pour-la-chaine-de-traitement)
- [Publication des données sur le web](#publication-des-donn%C3%A9es-sur-le-web)
- [Pré-traitement des données pour l'apprentissage et la génération de listes](#pr%C3%A9-traitement-des-donn%C3%A9es-pour-lapprentissage-et-la-g%C3%A9n%C3%A9ration-de-listes)
- [Détection des fichiers pour population automatique du `batch` à importer](#d%C3%A9tection-des-fichiers-pour-population-automatique-du-batch-%C3%A0-importer)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

La plupart de ces étapes auront pour effet d'enrichir les fonctionnalités de la commande `sfdata`, en modifiant le code source du dépôt [signaux-faibles/opensignauxfaibles](https://github.com/signaux-faibles/opensignauxfaibles).

## Définition des attentes / Écriture de tests automatisés

Pré-requis:

- Se procurer des données d'exemple depuis cette source + la documentation de leur format

- Vérifier que cette source de données n'est pas déjà supportée, ou redondante avec une source déjà supportée (cf [Description des données](https://github.com/signaux-faibles/documentation/blob/master/description-donnees.md), [Tableau des types de fichiers supportés](https://github.com/signaux-faibles/documentation/blob/master/processus-traitement-donnees.md#sp%C3%A9cificit%C3%A9s-de-limport) et [liste `registeredParsers` de `opensignauxfaibles`](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/lib/parsing/main.go#L24))

- Choisir un identifiant unique mais reconnaissable (ex: `paydex`, `sirene_ul`...) qui sera utilisé pour nommer le parseur, grouper les fichiers de ce type dans le `batch` et pour identifier la source d'erreurs éventuelles de parsing dans le Journal

Étapes recommandées:

1. Constituer un jeu de données concis et anonymisé (mais réaliste et représentatif) qui sera utilisé pour tester le bon fonctionnement du parseur et du reste de la chaine de traitement sur ces données. Exemple: [`lib/paydex/testData/paydexTestData.csv`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-4d30c0a429c0bf0163db25dac95bf7578165e2f7418539a0a97f3dee99534986)

2. Inclure ces données de test dans le `batch` de `test-import.sh`. Nous allons laisser le test échouer, jusqu'à ce que le parseur soit opérationnel. (cf dernière étape de la section suivante) Exemple: [ajout d'un fichier `paydex` dans la propriété `"files"`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-f51ecfd8355c3d64dbdf03c617e5c835fcc1c12c7a73203c43da1e2409fed425)

Ces premières étapes vont permettre de mesurer notre avancement pendant l'implémentation du parseur, en observant les résultats de chaque itération, après avoir exécuté `tests/test-import.sh`.

## Implémentation du parseur

Étapes recommandées:

1. Écrire un test unitaire pour définir les données attendues en sortie du parseur, après lecture du jeu de données de test constitué à l'étape précédente. Ce test passera une fois que le parseur sera correctement implémenté. Exemple: [`"should parse a valid row"` défini pour le parseur `paydex`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-45a283bb3b7bb926cb7afc4a9a70de90ab30727c00c24b5505e05cc8be77003cR18)

2. Définir le type `struct` en sortie du parseur, sans oublier d'implémenter les méthodes `Key()`, `Scope()` et `Type()` associées. Exemple: [type `Paydex`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-a41d55843c143ae9786efd5d5f224a1ad0dede3a589e379ff502ff6c5b037979R24)

3. Écrire le parseur en implémentant les méthodes attendues par l'interface `marshal/parser.go` puis définir une variable publique contenant une instance de ce parseur. Exemple: [instance de `paydexParser`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-a41d55843c143ae9786efd5d5f224a1ad0dede3a589e379ff502ff6c5b037979R46)

4. Ajouter l'instance du parseur dans `registeredParsers`. Exemple: [association de l'instance `paydex.ParserPaydex` à l'identifiant `paydex`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-aba77fcb5c2f400fe1392d619974a683863356e668b188ed70c548fba322b405R35)

5. Exécuter `go generate ./...`, `make` puis `tests/test-import.sh --update` pour inclure dans `tests/output-snapshots/test-import.golden.txt` les données parsées depuis le jeu de données de test. Si nécéssaire, effectuer des modifications du parseurs puis ré-exécuter ces commandes.

## Mise à disposition des données pour la chaine de traitement

Une fois le parseur fonctionnel et correctement testé, nous allons documenter les données qu'il intègre puis rendre ces données exploitables par les commandes `sfdata public` et `sfdata reduce`.

Étapes recommandées:

1. Ajouter une section dans [`description-donnees.md`](https://github.com/signaux-faibles/documentation/blob/master/description-donnees.md) pour décrire la source des données. Exemple: [ajout de la documentation des données Ellisphere](https://github.com/signaux-faibles/documentation/pull/37/files#diff-d1d9fa3a20207050840af2817a44919c8c226a5b59fd1d52e4c9b6f18982d941R686)

2. Ajouter la source dans la liste des fichiers supportés, de [`processus-traitement-donnees.md`](https://github.com/signaux-faibles/documentation/blob/master/processus-traitement-donnees.md#sp%C3%A9cificit%C3%A9s-de-limport). Exemple: [ajout de la source `paydex` dans la liste](https://github.com/signaux-faibles/documentation/pull/33/files#diff-6dcf1abaea3e6c2845c1fb9ba63930e0f3dc16715cf65d821cf6e4bb514a207dR167)

3. Pour permettre la validation des données importées en base de données ainsi que pour garantir l'alignement de leur structure (en sortie du parseur) avec les types qui seront manipulés en TypeScript/JavaScript par la chaine de traitements, écrire un fichier JSON Schema dans le [répertoire `validation`](https://github.com/signaux-faibles/opensignauxfaibles/tree/master/validation) et le référencer dans [la liste `typesToCompare` de `validation/validation_test.go`](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/validation/validation_test.go#L113).

4. Générer les types TypeScript (`js/GeneratedTypes.d.ts`) à l'aide de la commande `go generate ./...` puis exécuter `go test ./...` pour s'assurer que le fichier JSON Schema est aligné avec la structure en sortie du parseur.

5. Ajouter un champ pour la nouvelle source de données dans le type `EntrepriseBatchProps` ou `EtablissementBatchProps` de [`js/RawDataTypes.ts`](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/js/RawDataTypes.ts). Utiliser l'identifiant de la source de données en guise de clé et le type TypeScript correspondant, celui qui a été ajouté à `js/GeneratedTypes.d.ts` dans l'étape précédente. Dans les documents de la collection `RawData`, cette propriété contiendra les données de la nouvelle source, classées par `hash`. Exemple: [ajout de `paydex: ParHash<EntréePaydex>` dans le type `EntrepriseBatchProps`](https://github.com/signaux-faibles/opensignauxfaibles/pull/280/files#diff-db5088da2bac6b883d2bbe137667636a1c70cb51dbb0f8ce32ebf0722c32eb71R59)

> Note: cet ajout aura pour effet de rendre incomplets les jeux de données employés par des tests d'intégration définis dans les répertoires `js/public/` et `js/reduce.algo2/`. Nous allons compléter ces données de tests dans les étapes suivantes.

## Publication des données sur le web

La publication de données sur l'application web de Signaux Faible commence par l'exécution d'une opération map-reduce sur la collection `RawData` appelant des fonctions TypeScript.

Dans la section précédente, nous avons documenté le type des entrées de données introduites de manière à ce qu'elles soient manipulables depuis ces fonctions, tout en bénéficiant de la vérification statique de l'intégrité de ces données.

Il ne nous reste donc plus qu'à tester la présence et la validité de ces entrées, puis à les intégrer dans les fonctions de l'opération map-reduce appelée `public`.

Étapes recommandées:

1. Compléter le test d'intégration "public.map() retourne toutes les propriétés d'entreprise (_ou d'établissement_) attendues sur le frontal" défini dans `js/public/ava_tests.ts`, en ajoutant à `rawEntrData` (ou `rawEtabData`) la propriété rattachant des données de test au nom de la source de données. Exemple: [ajout de `paydex` à `rawEntrData`](https://github.com/signaux-faibles/opensignauxfaibles/pull/280/files#diff-9338b6b17c7e1f5f7027f05b1d57865534a9d115ebe77e0676a11f568ff2bfedR82).

2. Implémenter l'intégration des entrées de données dans la fonction `map()` du map-reduce `public`, dans le fichier `public/map.ts`. Exemple: [intégration du champ `paydex` dans `map()`](https://github.com/signaux-faibles/opensignauxfaibles/pull/280/files#diff-5316941fcda6e5db677f7d0c709d941cc0d6aa425c3ed38a3a1abdbec2781976)

> Note: Si l'intégration prend un nombre considérable de lignes de code, ne pas hésiter à l'extraire dans une fonction séparée, définie dans un fichier dédié. Exemple: [`public/diane.ts`](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/js/public/diane.ts). Dans ce cas, ne pas oublier d'inclure cette fonction dans l'espace de noms `f`, défini dans `functions.ts`. Exemple: [inclusion de `raison_sociale` dans `public/functions.ts`](https://github.com/signaux-faibles/opensignauxfaibles/commit/ac72e7f551017de9cdc4141bcbf69854560d058e#diff-73bec79f1e3b8aee202fe33fcabc681fd81a65e41d74edcfca400b53c4205cef)

3. Pour transpiler et empaqueter les fonctions en JavaScript puis mettre à jour les clichés (_snapshots_ et _golden masters_) de résultats attendus de tests automatisés, exécuter `./test-all.sh --update-snapshots`.

## Pré-traitement des données pour l'apprentissage et la génération de listes

La génération de liste de détection et l'apprentissage permettant ces prévisions s'appuie sur des variables pré-traitées par l'exécution d'une opération map-reduce sur la collection `RawData` appelant des fonctions TypeScript.

Plus haut, nous avons documenté le type des entrées de données introduites de manière à ce qu'elles soient manipulables depuis ces fonctions, tout en bénéficiant de la vérification statique de l'intégrité de ces données.

Il ne nous reste donc plus qu'à tester la présence et la validité de ces entrées depuis l'opération map-reduce appelée `reduce.algo2`, puis à les intégrer dans les fonctions appelées par cette opération.

Étapes recommandées:

1. Compléter le test d'intégration "algo2.map() retourne les propriétés d'entreprise (_ou d'établissement_) attendues par l'algo d'apprentissage" défini dans `js/reduce.algo2/algo2_tests.ts`, en ajoutant à `rawEntrData` (ou `rawEtabData`) la propriété rattachant des données de test au nom de la source de données. Exemple: [ajout de `paydex` à `rawEntrData`](https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-18cc393cea779aa67a061bf323932ed0f0c499e986e18e6f12744a8364ee8f9eR132).

2. Implémenter l'intégration des entrées de données dans la fonction `map()` du map-reduce `reduce.algo2`, dans le fichier `reduce.algo2/map.ts`. Exemple: [intégration du champ `paydex` dans `map()`](https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-f059593bf57f4dc717825eab1fa6d2614c9df5b33e5d16175062538ef9db4fe8)

> Note: Si l'intégration prend un nombre considérable de lignes de code, ne pas hésiter à l'extraire dans une fonction séparée, définie dans un fichier dédié. Exemple: [`reduce.algo2/entr_paydex.ts`](https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-dc4940c77ded6c779957cbc2e53475d07cb6d3ac04838d5f80674da9ee0ec446). Dans ce cas, ne pas oublier d'inclure cette fonction dans l'espace de noms `f`, défini dans `functions.ts`. Exemple: [inclusion de `entr_paydex` dans `reduce.algo2/functions.ts`](https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-0ba5a109a0aedc28c9c5cb6a84a29342dad7ffb37ef5e7471cafcb23209d7d31)

3. Recommandé: écrire des tests unitaires pour documenter les traitements effectués et éviter les régressions. Exemple: [`reduce.algo2/entr_paydex_tests.ts`](https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-706ca5d4f2746d02d28ff5d5f6fa5eedc38322f8056437bd52f0c6338a531c67)

4. Exporter un type `Variables` constitué des propriétés `source`, `computed` et `transmitted`, afin de générer de manière automatique la documentation des variables fournies à l'algorithme (`js/reduce.algo2/docs/variables.json`). Exemple: [description des champs calculés et transmis de `entr_paydex`](https://github.com/signaux-faibles/opensignauxfaibles/pull/296/files#diff-dc4940c77ded6c779957cbc2e53475d07cb6d3ac04838d5f80674da9ee0ec446R12).

> Note: Le commentaire JSDoc de chaque champs sera automatiquement extrait comme description de ce champ, au moment de la génération de `variables.json`. Exemple: [commentaire JSDoc du champ `statut_juridique` de `entr_paydex`](https://github.com/signaux-faibles/opensignauxfaibles/pull/296/files#diff-7f402bfddb6fe578a1fa2c55f03931127de178ee44c4e6c82bca6ac5eafaa293R5)

5. Pour transpiler et empaqueter les fonctions en JavaScript puis mettre à jour les clichés (_snapshots_ et _golden masters_) de résultats attendus de tests automatisés, exécuter `./test-all.sh --update-snapshots`.

## Détection des fichiers pour population automatique du `batch` à importer

La nouvelle source de donnée est désormais supportée par toute la chaine d'intégration couverte par la commande `sfdata`.

Pour faciliter l'intégration régulière de données, nous pouvons à présent faire en sorte que la commande [`prepare-import`](https://github.com/signaux-faibles/prepare-import) reconnaisse automatiquement les fichiers permettant d'importer ces données.

Étapes recommandées:

1. Ajouter le(s) nom(s) de fichier(s) de test dans le test de bout en bout de `prepare-import` (`main_test.go`). Exemple: [intégration d'un fichier paydex de test](https://github.com/signaux-faibles/prepare-import/pull/51/files#diff-79ce3229c13921b79b1175dcb211336aaf84dfd8edcf19c07698934d4fe70e5eR37)

2. Ajouter dans le test unitaire `TestExtractFileTypeFromFilename` quelques exemples de noms que pourraient avoir les fichiers issues de la nouvelle source de données, pour assurer que ces noms seront systématiquement reconnus par `prepare-import`. Exemple: [ajout de noms de fichiers `sirene` et `paydex`](https://github.com/signaux-faibles/prepare-import/pull/51/files#diff-14a00cc655ecff968c4c9e926d4348c165bf4795e942f1bd6093392b52bababd).

3. Implémenter la détection du type de données à partir du nom du fichier (exemple: [détection `paydex` par une expression régulière](https://github.com/signaux-faibles/prepare-import/pull/51/files#diff-e4b9d0eb67b99b6e21ec7e8f4e2ab15272606ca07a2db3494d73eba0b15a21b1)), ou à partir des métadonnées associées (exemple: [détection `bdf` depuis la métadonnée `goup-path`](https://github.com/signaux-faibles/prepare-import/blob/0593e8e40ab0f89f6e15e074db7ff05538b29256/prepareimport/filemetadata.go#L20)).

4. Vérifier que tous les tests passent, et mettre à jour les clichés (_snapshots_ et _golden masters_) de résultats attendus par les tests automatisés, en exécutant `make test-update`.
