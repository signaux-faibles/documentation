# Documentation Signaux Faibles

<!-- DOCTOC SKIP -->

## Table des matières

- [Présentation du projet](#présentation-du-projet)
- [Guide utilisateur de l'application](https://signaux-faibles.gitbook.io/guide-dutilisation-et-f.a.q.-de-signaux-faibles/)
- [Prise en Main](prise-en-main.md)
- [Architecture logicielle](architecture-logicielle.md) (wip)
- [Description des données](description-donnees.md) (wip)
- [Procédure de préparation des données](procedure-import-donnees.md)
- [Processus de traitement des données](processus-traitement-donnees.md)
- [Mise en ligne d'une nouvelle liste de détection](processus-nouvelle-liste.md) (TODO)
- [Algorithme + Evaluation](algorithme-evaluation.md) (wip)
- [Permissions d'accès](permissions.md) (wip)
- [Staging frontend](staging-frontend.md)
- [Comment intégrer une nouvelle source de données](integration-nouvelle-source-donnees.md)

## Présentation du projet

L'organisation github [Signaux-Faibles](https://github.com/signaux-faibles/) regroupe tous les outils développés au sein de la startup d'état [Signaux Faibles](https://beta.gouv.fr/startups/signaux-faibles.html).

L'objectif de ces outils est de fournir les outils techniques nécessaires à la mise en oeuvre de la détection algorithmique ainsi que la diffusion des résultats de cette détection auprès des utilisateurs.

## Logiciels

- [signauxfaibles-web](https://github.com/signaux-faibles/signauxfaibles-web) est l'interface utilisateur destinée aux agents publics
- [datapi](https://github.com/signaux-faibles/datapi) est une api orientée sur
  l'hébergement et l'échange de données dans un contexte de gestion complexe
  des attributions
- [opensignauxfaibles](https://github.com/signaux-faibles/opensignauxfaibles)
  contient le socle technique permettant l'intégration des données et les
  calculs en vue d'entraîner l'algorithme.
- [prepare-import](https://github.com/signaux-faibles/prepare-import) permet de
  générer un "batch" de fichiers bruts (transférés via goup) en vue de leur
  importation en base de données.
- [keycloakUpdater](https://github.com/signaux-faibles/keycloakUpdater) se charge de configurer les utilisateurs de l'application et leurs permissions
- [libwekan](https://github.com/signaux-faibles/libwekan) contient des fonctions pour accéder à une base de données Wekan
- [goSirene](https://github.com/signaux-faibles/goSirene) permet la lecture des fichiers de l'INSEE
- [wekan-alerter](https://github.com/signaux-faibles/wekan-alerter) envoie certaines notifications liées à l'activité Wekan
- [signaux-faibles.github.io](https://github.com/signaux-faibles/signaux-faibles.beta.gouv.fr) est la page des statistiques publiques éponymes

## Contribuer à cette documentation

Avant tout commit, exécuter `make` pour une mise en forme et une génération des tables des matières automatique.
