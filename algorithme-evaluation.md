# Le modèle et son évaluation

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Objectif et historique du modèle](#objectif-et-historique-du-mod%C3%A8le)
- [Modèle à « deux étages » de Septembre 2021](#mod%C3%A8le-%C3%A0-%C2%AB-deux-%C3%A9tages-%C2%BB-de-septembre-2021)
- [Premièr étage : L'apprentissage supervisé pré-crise](#premi%C3%A8r-%C3%A9tage--lapprentissage-supervis%C3%A9-pr%C3%A9-crise)
  - [Cible d'apprentissage](#cible-dapprentissage)
  - [Périmètre](#p%C3%A9rim%C3%A8tre)
  - [Modèle](#mod%C3%A8le)
  - [Variables d'apprentissage](#variables-dapprentissage)
    - [Variables conseillées par la MRV](#variables-conseill%C3%A9es-par-la-mrv)
    - [Variables Signaux Faibles](#variables-signaux-faibles)
  - [Explication des scores de prédiction](#explication-des-scores-de-pr%C3%A9diction)
    - [Diagramme radar](#diagramme-radar)
    - [Explications textuelles](#explications-textuelles)
  - [Évaluation du modèle: lexique](#%C3%A9valuation-du-mod%C3%A8le-lexique)
  - [Seuils de détection](#seuils-de-d%C3%A9tection)
- [Deuxième étage: Corrections liées à la crise :construction_worker: :building_construction:](#deuxi%C3%A8me-%C3%A9tage-corrections-li%C3%A9es-%C3%A0-la-crise-construction_worker-building_construction)
- [Evaluation du modèle - Méthodologie](#evaluation-du-mod%C3%A8le---m%C3%A9thodologie)
  - [Évaluation du modèle par validation croisée](#%C3%A9valuation-du-mod%C3%A8le-par-validation-crois%C3%A9e)
  - [Choix de la métrique](#choix-de-la-m%C3%A9trique)
- [Évaluation du modèle - Métriques à juin 2021](#%C3%A9valuation-du-mod%C3%A8le---m%C3%A9triques-%C3%A0-juin-2021)
- [Évaluation du modèle - Métriques à septembre 2021](#%C3%A9valuation-du-mod%C3%A8le---m%C3%A9triques-%C3%A0-septembre-2021)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Objectif et historique du modèle

Le modèle Signaux Faibles vise à identifier de nouvelles entreprises en situation de fragilité, passées inaperçues auprès des administrations, alors que des dispositifs d'aide pourraient leur être proposés. Pour cela, il est important d'anticiper suffisamment les défaillances pour avoir le temps de mettre en œuvre ces dispositifs.

Un modèle d'apprentissage supervisé a été initialement développé avant la crise, a été étendu à la France entière en décembre 2019, mais a été mis à l'arrêt depuis le début du confinement de Mars 2020, car inapte à traiter la situation spécifique à la crise.

Depuis octobre 2020, de nouveaux modèles tenant compte de l'impact de la crise ont été proposés. Le dernier en date consiste en un modèle "à deux étages" qui est décrit ci-dessous.

## Modèle à « deux étages » de Septembre 2021

La crise économique liée au Covid-19 est un contexte nouveau, pour lequel l'apprentissage automatique est mis en défaut, du fait que le crise modifie en profondeur la conjoncture économique, le comportement des entreprises, ainsi que les critères d'entrée en procédures collectives. Afin d'adapter au mieux notre algorithme à la situation économique liée à la crise Covid et de rapprocher nos listes de détection des préoccupations de nos utilisateurs, il a été décidé de faire évoluer le modèle vers une approche à « deux étages », qui permet de séparer le contexte en entrée de crise et l'impact de la crise sur chaque entreprise.

Les prédictions sont obtenues en deux étapes:

- D'abord, un **modèle _simple_ et _explicable_** (une régression logistique) est utilisé afin de prédire la situation d'un entreprise _juste avant la crise_ (à Février 2020). Cette prédiction est transformée en trois catégories : niveau d'alerte rouge (risque de défaillance élevé), orange (risque de défaillance modéré) ou verte (pas de signal de risque).
- Ensuite, des corrections liées à la crise sont apportées via des **règles expertes** transparentes et co-construites avec nos utilisateurs afin de permettre au modèle de capter des réalités terrain liées à un contexte sans précédent et qu'un modèle d'apprentissage automatisé n'aurait — par définition — pas pu apprendre. Ces règles peuvent augmenter le niveau d'alerte initialement produit par le modèle.

La prédiction finale du modèle est donc complétement transparente et explicable — étant la superposition d'une [régression logistique](https://fr.wikipedia.org/wiki/R%C3%A9gression_logistique) et d'une règle experte ayant la forme d'un arbre de décision.

Le modèle de Septembre 2021 est détaillé dans ce qui suit.

## Premièr étage : L'apprentissage supervisé pré-crise

### Cible d'apprentissage

> Le modèle cherche à prédire l'entrée en procédure collective (liquidation et redressement judiciaires, sauvegarde, etc.) à 18 mois.

Cette cible d'apprentissage est imparfaite : des entreprises en difficulté peuvent ne pas avoir de défaillance dans les 18 mois, mais il serait pertinent de les détecter. C'est le cas par exemple d'entreprises financièrement solides mais dont l'activité ne leur permet pas d'être profitable. Inversement, certaines défaillances sont dues à des évènements non encore identifiables avec 18 mois d'anticipation (accidents, etc.), qui ne pourront donc être détectés que plus tard.

À noter que la cible d'apprentissage est très déséquilibrée : statistiquement, environ 2% des entreprises observées aujourd'hui feront défaillance dans les 18 mois à venir. Ce chiffre a chuté lors au début de la crise Covid-19, du fait des dispositifs de soutien aux entreprises ayant permis de maintenir « à flot » une part des entreprises éligibles. Qui plus est, une part de ces 2% sont des entreprises pour lesquelles on dispose d'un « signal fort » (voir ci-dessous).

### Périmètre

- Entreprises de 10 salariés et plus.
- France entière.
- À l'exception des entreprises de l'administration publique (code APE O) et de l'enseignement (code APE P).

### Modèle

Le modèle utilisé est une régression logistique. Elle est aujourd'hui entrainée sur des données allant de janvier 2016 à novembre 2018 (18 mois avant la crise Covid et la diminution des entrées en procédures collectives), et produit une prédiction à Février 2020 qui peut etre interprétée comme la situation pré-crise de l’entreprise.

### Variables d'apprentissage

Le modèle est entrainé sur les variables d'apprentissage suivantes.

#### Variables conseillées par la MRV

NB: la pertinence de ces variables a été remise en cause par le partenariat, la prochaine version du modèle utilisera très probablement d'autres variables financières sur base d'une sélection de variables préalable.

```
"MNT_AF_BFONC_BFR",
"MNT_AF_BFONC_TRESORERIE",
"RTO_AF_RATIO_RENT_MBE",
"MNT_AF_BFONC_FRNG",
"MNT_AF_CA",
"MNT_AF_SIG_EBE_RET",
"RTO_AF_RENT_ECO",
"RTO_AF_SOLIDITE_FINANCIERE",
"RTO_INVEST_CA"
```

#### Variables Signaux Faibles

Les variables issues de la base Signaux Faibles sont définies au niveau SIRET (établissement) et sont donc aggrégées au niveau SIREN (entreprise) selon différente modalitées :

Variables aggrégée via une somme (`groupby(siren).sum()`) :

```python
"cotisation",
"cotisation_moy12m",
"montant_part_ouvriere",
"montant_part_ouvriere_past_1",
"montant_part_ouvriere_past_12",
"montant_part_ouvriere_past_2",
"montant_part_ouvriere_past_3",
"montant_part_ouvriere_past_6",
"montant_part_patronale",
"montant_part_patronale_past_1",
"montant_part_patronale_past_12",
"montant_part_patronale_past_2",
"montant_part_patronale_past_3",
"montant_part_patronale_past_6",
"effectif",
"apart_heures_consommees_cumulees",
"apart_heures_consommees",
```

Variables aggrégée via une moyenne (`groupby(siren).mean()`) :

```python
"ratio_dette_moy12m"
```

Variables calculées après l'aggrégation au niveau siren :

```python
"ratio_dette", # (part_ouvriere + part_patronale) / cotisation_moyenne_12mois
"avg_delta_dette_par_effectif", # evolution moyenne dette sociale par effectif sur 3 mois
```

Voir [ce document](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/js/reduce.algo2/docs/variables.json) pour la définition et la source des champs « Signaux Faibles » présents en base.

### Explication des scores de prédiction

Nos listes d'entreprises en difficulté sont accompagnées d'explications sur les raisons de la présence ou l'absence de chaque entreprise dans ces listes.

Ces explications sont produites sur la base des variables utilisées par notre «premier étage algorithmique», et à deux niveaux de granularité :

- au niveau de chaque variable utilisée par ce modèle de prédiction;
- à un niveau plus agrégé, par groupe de variables de même «thématique». Parmi ces groupes de variables, on trouve :
  - les variables de santé financière ;
  - les variables de dette sur cotisations sociales aux URSSAF ;
  - le recours à l'activité partielle.

_À noter que, en séptembre 2021, les méthodes d'explication de Signaux Faibles ne sont implémentées que pour un modèle de régression logistique._

Pour une documentation technique des scores d'explication de la régression logistique, consulter la [documentation technique des scores d'explication](./modele-explications-doc-technique.pdf).

Plusieurs indicateurs explicatifs sont ainsi présentés dans l'interface web : un «diagramme radar» et des explications textuelles.

#### Diagramme radar

Un diagramme radar affiche un score de risque associé à chacun des groupes de variables. Cet indicateur est relatif à la situation de l'entreprise en question par rapport à l'ensemble des entreprises considérées par Signaux Faibles. Quelques exemples pour comprendre ce qu'affiche ce radar :

- un indicateur « Santé financière » dans le vert indique que l'entreprise a une situation financière excellente dans l'ensemble, ou plutôt qui contribue très positivement à la considérer comme une entreprise sans risque.
- un indicateur « Dette Urssaf » dans le rouge indiquerait un historique d'encours de dette aux Urssaf particulièrement inquiétant, contribuant à un score de risque élevé.

#### Explications textuelles

Sur les fiches établissement de l'application Signaux Faibles, une liste de variables préoccupantes est fournie pour justifier un niveau de risque fort ou modéré.

### Évaluation du modèle: lexique

Par convention, nous choisissons d'attribuer un score de 1 aux entreprises ayant un risque maximal de défaillance, et 0 aux entreprises ayant un risque minimal de défaillance. En conséquence, nous avons les définitions suivantes:

- **Défaillance** : une entrée en procédure collective.
- **Entreprise positive** : une entreprise connaissant effectivement une défaillance à au moins un moment sur les 18 prochains mois.
- **Entreprise négative** : le contraire d'une entreprise positive.
- **Entreprise prédite positive** : une entreprise que notre algorithme identifie comme à risque de défaillance (fort ou modéré) sur les 18 prochains mois.
- **Entreprise prédite négative** : le contraire d'une entreprise prédite positive.
- **Entreprise faux positif** : une entreprise pour lequel une défaillance est prédite, mais qui ne connaît pas de défaillance effective.
- **Entreprise faux négatif** : une entreprise pour lequel aucune défaillance n'est prédite, mais qui connaît effectivement une défaillance.

À partir de ces définitions, on définit les métriques usuelles d'évaluation d'un algorithme d'apprentissage automatique:

- **Précision** : la part d'entreprises prédites positives étant effectivement positives
- **Rappel** : la part d'entreprises effectivement positives étant prédites positives.
- **Score F-beta** : une métrique d'évaluation prenant à la fois la précision et le rappel en compte, et accordant une importante relative `beta` fois plus importante au rappel qu'à la précision.
- **Score AUCPR** : l'aire sous la courbe rappel-précision (Area Under Curve, for Precision-Recall curve). Celle-ci permet d'étudier la performance du modèle et l'équilibre s'établissant entre ces deux scores en fonction du seuil de classification choisi.

Pour plus d'informations sur ces métriques, voir les liens ci-dessous:

- [Précision et rappel](https://fr.wikipedia.org/wiki/Pr%C3%A9cision_et_rappel)
- [Matrice de confusion](https://fr.wikipedia.org/wiki/Matrice_de_confusion)
- [Score F_beta](https://en.wikipedia.org/wiki/F-score)

### Seuils de détection

Le modèle Signaux Faibles produit un score de risque entre 0 et 1. Or, il faut décider à quel pallier de risque appartient chaque entreprise à partir de ce score de risque. Pour ce faire, et au vu du modèle et de la cible d'apprentissage actuels, il est nécessaire de définir un premier seuil sur le score de risque au-delà duquel l'entreprise est à considérer « à risque modéré » de défaillance, et un second seuil — plus élevé que le premier — au-delà duquel l'entreprise est à considérer « à risque fort » de défaillance. La méthodologie pour déterminer ces seuils est détaillée ci-dessous.

A partir de ces scores de risque, une liste d'entreprises à risque est construite, avec trois palliers de risques:

- un niveau «risque fort» :red_circle: où la précision est élevée, c'est-à-dire que les entreprises identifiées comme à risque fort le sont effectivement, quitte à manquer quelques entreprises qui font défaillance
- un niveau «risque modéré» :orange_circle: est construite de sorte à capturer un maximum d'entreprises à risque, quitte à avoir dans cette liste plus de faux positifs, c'est-à-dire d'entreprises qui sont en réalité en bonne santé.
- un niveau «aucun signal» de risque :green_circle:, comprenant toutes les entreprises de notre périmètre n'entrant pas dans les deux palliers ci-dessus.

Ces seuils sont déterminés par la maximisation du score F-beta, une métrique permettant de «sanctionner» de manière pondérée les faux positifs et les faux négatifs produits par le modèle.

Plus particulièrement:

- le seuil du pallier «risque fort» est choisi pour maximiser le F\_{0.5}, une métrique qui favorise deux fois plus la précision que le rappel. Ce score favorise ainsi une précision élevée, et donc l'exclusivité d'entreprises effectivement en défaillance dans le pallier «risque fort».
- le seuil du pallier «risque modéré» est choisi pour maximiser le score F\_2, qui favorise deux fois plus le rappel que la précision. La maximisation de cette métrique vise à obtenir un pallier «risque modéré» qui capture un maximum d'entreprises effectivement en défaillance, quitte à capturer «par erreur» des faux positifs, c'est-à-dire quitte à viser trop large et lister des entreprises qui n'entreront pas en défaillance.

La volumétrie des listes pour septembre 2021 est donnée dans le fichier [d'évaluation du modèle de septembre 2021](evaluation-modele/sept2021.md).

## Deuxième étage: Corrections liées à la crise :construction_worker: :building_construction:

Des «corrections expertes» sont réalisées après l'apprentissage supervisé:

- Une correction «Dette Sociale» qui vise à détecter les entreprises dont l'évolution de la dette sociale (URSSAF) s'est dégradée depuis l'été 2020 (date à laquelle les reports de charges consentis pendant le premier confinement se sont terminés).
- :construction_worker: D'autres corrections encore en cours de co-construction avec nos utilisateurs autour notamment :
  - du recours à l'activité partielle longue durée
  - d'articles de recherche (institutionnels ou académiques) sur l'impact de la crise Covid par secteur d'activité

## Evaluation du modèle - Méthodologie

Seule la partie « apprentissage supervisé » du modèle peut être évaluée de manière rigoureuse, dans la mesure où la crise n'a pas produit tous ses effets et que nous ne disposons pas de visibilité sur les défaillances futures pour évaluer la performance des corrections apportées.

### Évaluation du modèle par validation croisée

Afin que l'évaluation mesure le mieux possible la performance réelle du modèle, il faut veiller a çe que les observations associées à une même entreprise ne se retrouvent pas dans le même échantillon, sous peine d'avoir une fuite d'information de l'échantillon d'entraînement vers l'échantillon de test (la performance biaisée du modèle favoriserait le sur-apprentissage au niveau de l'entreprise).

### Choix de la métrique

Après retrait des « signaux forts » (cf. paragraphe précédent), la cible à détecter représente à peine 1% de l'échantillon d'entreprise. Il s'agit donc d'un échantillon très biaisé.

Dans le contexte de Signaux Faibles, les faux positifs (un doute est émis sur une entreprise en réalité bien portante) est beaucoup plus acceptable qu'un faux négatif (une entreprise en difficulté n'a pas été détectée).

Ainsi, la **précision moyenne** (average accuracy) se prête bien à l'évaluation de notre algorithme. Nous utilisons également un **score F-beta** avec une valeur de beta proche de 2 afin de pénaliser plus fortement les faux négatifs.

Le **score AUCPR** est également une métrique adaptée à ce contexte.

## Évaluation du modèle - Métriques à juin 2021

Voir [évaluation du modèle - juin 2021](evaluation-modele/juin2021.md).

## Évaluation du modèle - Métriques à septembre 2021

Voir [évaluation du modèle - septembre 2021](evaluation-modele/sept2021.md).
