# Staging frontend

Les composants du frontend Signaux-Faibles sont signauxfaibles-web (frontend) et datapi (backend)

## Évolution des numéros de version

La logique de versionning est un numéro entier incrémenté à chaque mise en production.

Les numéros de version de signauxfaibles-web et datapi sont synchronisés de façon à faciliter l'assortissement des versions entre elle.

## Cycle de vie

Le cycle de travail se décompose en 3 étapes

- développement
- pre-production
- production

### Développement

Cette étape est dédiée à l'ajout/modification de fonctionnalités ou corrections, et des tests correspondants. Chaque ajout de fonctionnalité fait l'objet d'une création de branche dédiée.

Il est à noter qu'un changelog embarqué dans signauxfaibles-web est à mettre à jour dans src/views/News.vue

Les branches créées pour les nouvelles fonctionnalités seront fusionnées dans une branche `release-vXX` pour la mise en pre-production.

### Pre-production

Cette phase est dédiée à la recette des fonctionnalités et se base sur la branche `release-vXX`.

L'aboutissement de cette phase est la fusion de la branche `release-vXX` dans la branche `master`

L'application présentée aux utilisateurs en pre-production doit être signalée comme application de recette.

### Mise en production

Cette étape consiste à rendre l'applicatif accessible aux utilisateurs, il convient de fusionner la branche `release-vXX` dans la branche master et d'ajouter un tag sur ce commit avec le numéro de version (par exemple `vXX`).
