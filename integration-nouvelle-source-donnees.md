# Comment intégrer une nouvelle source de données

Cette page donne la marche à suivre pour intégrer une nouvelle source de données, en plusieurs étapes:

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Définition des attentes / Écriture de tests automatisés](#d%C3%A9finition-des-attentes--%C3%A9criture-de-tests-automatis%C3%A9s)
- [Implémentation d'un parseur](#impl%C3%A9mentation-dun-parseur)
- [Publication des données sur le web](#publication-des-donn%C3%A9es-sur-le-web)
- [Pré-traitement des données pour l'apprentissage et la génération de listes](#pr%C3%A9-traitement-des-donn%C3%A9es-pour-lapprentissage-et-la-g%C3%A9n%C3%A9ration-de-listes)
- [Détection des fichiers pour population automatique du `batch` à importer](#d%C3%A9tection-des-fichiers-pour-population-automatique-du-batch-%C3%A0-importer)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Définition des attentes / Écriture de tests automatisés

Pré-requis:

- Se procurer des données d'exemple depuis cette source + la documentation de leur format

- Vérifier que cette source de données n'est pas déjà supportée, ou redondante avec une source déjà supportée (cf [Description des données](https://github.com/signaux-faibles/documentation/blob/master/description-donnees.md), [Tableau des types de fichiers supportés](https://github.com/signaux-faibles/documentation/blob/master/processus-traitement-donnees.md#sp%C3%A9cificit%C3%A9s-de-limport) et [liste `registeredParsers` de `opensignauxfaibles`](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/lib/parsing/main.go#L24))

- Choisir un identifiant unique mais reconnaissable (ex: `paydex`, `sirene_ul`...) qui sera utilisé pour nommer le parseur, grouper les fichiers de ce type dans le `batch` et pour identifier la source d'erreurs éventuelles de parsing dans le Journal

Étapes recommandées:

1. Constituer un jeu de données concis et anonymisé (mais réaliste et représentatif) qui sera utilisé pour tester le bon fonctionnement du parseur et du reste de la chaine de traitement sur ces données. Exemple: [`lib/paydex/testData/paydexTestData.csv`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-4d30c0a429c0bf0163db25dac95bf7578165e2f7418539a0a97f3dee99534986)

2. Inclure ces données de test dans le `batch` de `test-import.sh`. Exemple: [ajout d'un fichier `paydex` dans la propriété `"files"`](https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-f51ecfd8355c3d64dbdf03c617e5c835fcc1c12c7a73203c43da1e2409fed425)

Ces premières étapes vont permettre de mesurer notre avancement pendant l'implémentation du parseur, en observant les résultats de chaque itération, après avoir exécuté `tests/test-import.sh`.
## Implémentation d'un parseur

**TODO**

Exemples:

- écriture de tests unitaires: https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-45a283bb3b7bb926cb7afc4a9a70de90ab30727c00c24b5505e05cc8be77003c
- écriture du parseur: https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-a41d55843c143ae9786efd5d5f224a1ad0dede3a589e379ff502ff6c5b037979
- ajout dans type `EntrepriseBatchProps` et/ou `EtablissementBatchProps`: https://github.com/signaux-faibles/opensignauxfaibles/pull/280/files#diff-db5088da2bac6b883d2bbe137667636a1c70cb51dbb0f8ce32ebf0722c32eb71R59
- validation/alignement des types avec ceux en sortie du parseur => écrire un fichier JSON Schema: https://github.com/signaux-faibles/opensignauxfaibles/pull/318/files#diff-b2b971a31c7d966ef0a52bba76519c5ea5c5c52014abd24f9ba7c29d52740f48 => génération de `GeneratedTypes.d.ts`
- ajout de la documentation des données: https://github.com/signaux-faibles/documentation/pull/37/files#diff-d1d9fa3a20207050840af2817a44919c8c226a5b59fd1d52e4c9b6f18982d941R685
- ajout dans la liste des fichiers supportés: https://github.com/signaux-faibles/documentation/pull/33/files#diff-6dcf1abaea3e6c2845c1fb9ba63930e0f3dc16715cf65d821cf6e4bb514a207dR167

3. Ajouter dans `registeredParsers`: https://github.com/signaux-faibles/opensignauxfaibles/pull/277/files#diff-aba77fcb5c2f400fe1392d619974a683863356e668b188ed70c548fba322b405R19

## Publication des données sur le web

**TODO**

Exemples:

- test d'intégration: https://github.com/signaux-faibles/opensignauxfaibles/pull/280/files#diff-9338b6b17c7e1f5f7027f05b1d57865534a9d115ebe77e0676a11f568ff2bfedR82
- intégration dans `public/map.ts`: https://github.com/signaux-faibles/opensignauxfaibles/pull/280/files#diff-5316941fcda6e5db677f7d0c709d941cc0d6aa425c3ed38a3a1abdbec2781976

## Pré-traitement des données pour l'apprentissage et la génération de listes

**TODO**

Exemples:

- test d'intégration par ajout dans `rawEntrData` et/ou `rawEtabData`: https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-18cc393cea779aa67a061bf323932ed0f0c499e986e18e6f12744a8364ee8f9eR132
- intégration dans `reduce.algo2/map.ts`: https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-f059593bf57f4dc717825eab1fa6d2614c9df5b33e5d16175062538ef9db4fe8
- écriture de tests unitaires: https://github.com/signaux-faibles/opensignauxfaibles/pull/284/files#diff-706ca5d4f2746d02d28ff5d5f6fa5eedc38322f8056437bd52f0c6338a531c67
- description des champs pour génération automatique de documentation (`js/reduce.algo2/docs/variables.json`):
  1. ajouter commentaires JSDoc sur chaque champ: https://github.com/signaux-faibles/opensignauxfaibles/pull/296/files#diff-7f402bfddb6fe578a1fa2c55f03931127de178ee44c4e6c82bca6ac5eafaa293R5
  2. exporter un type `Variables`: https://github.com/signaux-faibles/opensignauxfaibles/pull/296/files#diff-dc4940c77ded6c779957cbc2e53475d07cb6d3ac04838d5f80674da9ee0ec446R12

## Détection des fichiers pour population automatique du `batch` à importer

**TODO**

Exemples:

- ajout dans test de bout en bout de `prepare-import`: https://github.com/signaux-faibles/prepare-import/pull/51/files#diff-79ce3229c13921b79b1175dcb211336aaf84dfd8edcf19c07698934d4fe70e5eR37
- ajout de tests unitaires pour la détection: https://github.com/signaux-faibles/prepare-import/pull/51/files#diff-14a00cc655ecff968c4c9e926d4348c165bf4795e942f1bd6093392b52bababd
- implémentation de la détection du type de fichier: https://github.com/signaux-faibles/prepare-import/pull/51/files#diff-e4b9d0eb67b99b6e21ec7e8f4e2ab15272606ca07a2db3494d73eba0b15a21b1
