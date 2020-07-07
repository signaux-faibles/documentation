# Documentation Signaux Faibles

<!-- DOCTOC SKIP -->

## Table des matières

- [Présentation du projet](#présentation-du-projet)
- [Prise en Main](prise-en-main.md)
- [Architecture logicielle](architecture-logicielle.md) (wip)
- [Processus de traitement des données](processus-traitement-donnees.md) (wip)
- [Publication des données](publication-donnees.md) (wip)
- [Description des données](description-donnees.md) (wip)
- [Algorithme + Evaluation](algorithme-evaluation.md) (wip)
- [Interface Graphique](interface-graphique.md) (wip)
- [Supervision](supervision.md) (wip)
- [Staging frontend](staging-frontend.md)

## Présentation du projet

L'organisation github [Signaux-Faibles](https://github.com/signaux-faibles/) regroupe tous les outils développés au sein de la startup d'état [Signaux Faibles](https://beta.gouv.fr/startups/signaux-faibles.html).

L'objectif de ces outils est de fournir les outils techniques nécessaires à la mise en oeuvre de la détection algorithmique ainsi que la diffusion des résultats de cette détection auprès des utilisateurs.

## Logiciels

- [signauxfaibles-web](https://github.com/signaux-faibles/signauxfaibles-web) est l'interface utilisateur destinée aux agents publics
- [opensignauxfaibles](https://github.com/signaux-faibles/opensignauxfaibles)
  contient le socle technique permettant l'intégration des données et les
  calculs en vue d'entraîner l'algorithme.
- [rsignauxfaibles](https://github.com/signaux-faibles/rsignauxfaibles)
  contient les méthodes d'apprentissage de l'algorithme et de prédiction.
- [datapi](https://github.com/signaux-faibles/datapi) est une api orientée sur
  l'hébergement et l'échange de données dans un contexte de gestion complexe
  des attributions
- [goup](https://github.com/signaux-faibles/goup) est une api destinée à permettre le transfert des fichiers bruts avec un protocole flexible et fiable basé sur http (voir [tus](https://github.com/tus))
- [frontend](https://github.com/signaux-faibles/frontend) est le site vitrine à
  vocation publique.
- [gorncs-api](https://github.com/signaux-faibles/gorncs-api) est une api basée sur le dépôt RNCS fourni par l'INPI.
- [prepare-import](https://github.com/signaux-faibles/prepare-import) permet de
  générer un "batch" de fichiers bruts (transférés via goup) en vue de leur
  importation en base de données.
