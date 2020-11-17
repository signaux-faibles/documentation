# Le modèle et son évaluation

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Objectif et historique du modèle](#objectif-et-historique-du-mod%C3%A8le)
- [Modèlisation et variables latentes](#mod%C3%A8lisation-et-variables-latentes)
  - [L'apprentissage supervisé](#lapprentissage-supervis%C3%A9)
    - [Les principaux éléments](#les-principaux-%C3%A9l%C3%A9ments)
  - [Corrections liées à la crise](#corrections-li%C3%A9es-%C3%A0-la-crise)
  - [Construction de variables latentes](#construction-de-variables-latentes)
  - [Seuils de détection](#seuils-de-d%C3%A9tection)
- [Évaluation du modèle](#%C3%A9valuation-du-mod%C3%A8le)
  - [Évaluation du modèle par validation croisée](#%C3%A9valuation-du-mod%C3%A8le-par-validation-crois%C3%A9e)
  - [Choix de la métrique](#choix-de-la-m%C3%A9trique)
  - [Reproductibilité de l'évaluation.](#reproductibilit%C3%A9-de-l%C3%A9valuation)
    - [Import des données dans R](#import-des-donn%C3%A9es-dans-r)
    - [Reproductibilité des traitements dans R](#reproductibilit%C3%A9-des-traitements-dans-r)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Objectif et historique du modèle

Le modèle Signaux Faibles vise à identifier de nouvelles
entreprises en
situation de fragilité, passées inaperçues auprès des
administrations, alors que
des dispositifs d'aide pourraient leur être proposés. Pour
cela, il est
important d'anticiper suffisamment les défaillances pour
avoir le temps de
mettre en œuvre ces dispositifs.

Un modèle d'apprentissage supervisé a été initialement
développé avant la
crise, a été étendu à la France entière en décembre 2019, mais a été mis à
l'arrêt depuis le début du confinement, car inapte à traiter la situation
spécifique à la crise.

Depuis octobre 2020, un nouveau modèle tenant en compte de
l'impact de la crise a été proposé. Le
Le modèle qui a été retenu à cet effet est un modèle
transparent, qui permet la définition de variables latentes
explicatives, qui a été fortement inspiré par [ce
modèle](http://dukedatasciencefico.cs.duke.edu/). périmètre
a été provisoirement réduit aux entreprises industrielles
et dont on
connaît les informations financières, mais le même modèle a
pour vocation a être étendu à tous les secteurs d'activité.

## Modèlisation et variables latentes

Les prédictions sont obtenues en deux étapes:

- D'abord, les variables peu affectées par la crise sont
  utilisées pour faire de l'apprentissage supervisé.
- Ensuite, des corrections liées à la crise sont
  apportées.

Le modèle permet, à des fins d'explicabilité, la
construction de variables latentes, constituées de
l'agrégation des contributions de plusieurs variables.

Enfin, la prédiction finale est transformée en trois
catégories: niveau d'alerte rouge, orange ou verte.

Chacun de ces aspects est détaillé dans ce qui suit.

### L'apprentissage supervisé

#### Les principaux éléments

- _Objectif d'apprentissage_ : anticiper de 18 mois
  l'entrée en procédure collective (liquidation,
  redressement judiciaires, et sauvegarde) ou 3 mois
  consécutifs de cotisations sociales impayées.

  Cet objectif d'apprentissage est imparfait : des
  entreprises en difficulté peuvent ne
  pas avoir de défaillance dans les 18 mois, mais seraient
  pertinentes à être
  détectées. C'est le cas par exemple d'entreprises
  financièrement solides mais dont l'activité ne leur
  permette pas d'être profitable. Inversement, certaines
  défaillances sont dues à des évènements non encore
  identifiables avec 18 mois d'anticipation (accidents,
  etc.).

  La cible d'apprentissage est très désiquilibrée.

- _Périmètre_ :

  - Établissements de 10 salariés et plus.
  - France métropolitaine entière
  - Provisoire : secteur industriel uniquement
  - Provisoire : données financières disponibles

- _Modèle_ : Le modèle utilisé est un modèle additif généralisé avec une
  fonction de lien "logit". Le caractère additif du modèle permet la
  construction facile de variables latentes en guise d'explicabilité, tout en
  garantissant un bon niveau de performance, similaire aux modèles concurrents
  permettant les interactions (par exemple: xgboost).

  Une différence majeure avec ce modèle et le modèle qui a servi d'inspiration
  présenté en introduction est que les contributions de toutes les variables
  sont calculées **concomitamment**, et non séparémment (avec un modèle
  spécifique par variable latente). Les variables latentes sont donc des scores
  intermédiaires **conditionnels** aux autres variables latentes.

### Corrections liées à la crise

Deux corrections "expertes" sont faites après
l'apprentissage supervisé:

- Une correction pour caractériser l'impact par secteur
  d'activité de la crise, qui s'appuye sur les enquêtes de conjoncture de la
  Banque de France. Pour cela, un modèle simple est entraîné, pour prédire le
  taux de défaillance en fonction du niveau de l'enquête de conjoncture, et est
  appliqué aux valeurs observées pendant la crise.

  Comme ces valeurs sont hors des données d'entraînement, il s'agit d'une
  extrapolation (contrairement aux plus classiques interpolations), qui repose
  sur l'hypothèse suivante: la probabilité de défaillance d'une entreprise, en
  fonction de la conjoncture économique, est une densité de probabilité de la
  loi normale (fonction de lien "probit").

  La pénalité est appliquée dans l'espace des log-vraisemblances.

- Une seconde correction vise à pénaliser les entreprises qui ont encore des
  dettes URSSAF. Cette correction est à ce stade simpliste et mériterait d'être
  enrichie.

  Elle consiste à classer les entreprises ayant des dettes par ordre
  décroissant de ratio dette/effectif dans chaque secteur d'activité (code ape
  niveau 3), et d'appliquer une pénalité décroissante de 1 à 0 (dans l'espace
  des log-vraisemblances toujours).

### Construction de variables latentes

Le caractère additif du modèle permet de construire des variables latentes
simplement en additionnant les contributions d'un groupe de variables liées à
une problématique.

Les variables latentes proposées sont les suivantes: TODO à compléter

### Seuils de détection

Si les prédictions étaient calibrés en probabilité, alors une manière efficace
de fixer les seuils serait de définir des seuils du type "L'établissement a 4x
plus de chances de subir une défaillance à 18 mois qu'un établissement moyen".

Comme nous ne connaissons pas la distribution des défaillances dues à la crise,
il est difficile de procéder de cette manière.

Ainsi, les seuils ont pour l'instant été arbitrairement fixés pour garantir des
volumes raisonnables d'entreprises détéctées. Il serait pertinent d'améliorer
cette méthode arbitraire.

## Évaluation du modèle

Uniquement la partie "apprentissage supervisée" du modèle peut être évaluée
proprement, dans la mesure où la crise n'a pas produit tous ses effets
économiques et que nous ne disposons pas de visibilité sur les défaillances
futures pour évaluer la performance des corrections apportées.

### Évaluation du modèle par validation croisée

Afin que l'évaluation représente le mieux possible la mesure de la capacité de
généralisation à la situation réelle d'utilisation du modèle, il faut veiller
aux éléments suivants:

- Plusieurs observations d'un même établissement ou les établissements de la
  même entreprise doivent se retrouver dans le même échantillon, sous peine
  d'avoir une fuite d'information de l'échantillon d'entraînement vers
  l'échantillon de test (la performance biaisée du modèle favoriserait le
  sur-apprentissage au niveau de l'entreprise).
- la période d'entraînement et les 18 mois qui suivent ne doivent pas être
  utilisés pour l'évaluation, sous peine de faire fuiter l'information sur la
  situation macro-économique
  (générale ou par secteur d'activité) au travers le la variable
  d'apprentissage (qui observe les défaillances à 18 mois).
- Enfin, l'évaluation ne doit pas tenir compte des entreprises déjà
  défaillantes, pour lesquelles le modèle n'est pas utilisé en pratique.

En conséquence, pour l'évaluation, une validation croisée est effectuée, dans
laquelle sont garantis:

- les différentes "vues" d'un même établissement à des périodes différentes, et
  les établissements d'une même entreprise seront toujours regroupées dans le
  même échantillon.
- un établissement pour l'entraînement est observé dans la période temporelle
  2015-01 à 2016-06 inclus, alors qu'un établissement dans l'échantillon de
  test est observé entre 2018-01 et 2018-06 inclus. L'échantillon de test ne
  peut pas aller au-delà car il faut au moins 18 mois de visibilité dans le
  futur pour la variable d'apprentissage (nécessaire à l'évaluation), et du
  fait du souhait d'exclure les périodes affectées par la crise COVID.
- les "signaux forts", c'est-à-dire les entreprises pour lesquelles on peut
  affirmer avec certitudes qu'elles tombent dans la cible d'apprentissage, sont
  retirés des échantillons d'évaluation.

### Choix de la métrique

Après retrait des "signaux forts" (cf paragraphe précédent), la cible à détecter représente à peine 3% de l'échantillon d'entreprise. Il s'agit donc d'un échantillon très biaisé.

L'**aire sous la courbe précision-rappel** (AUCPR) est une métrique adaptée à
ce contexte.

### Reproductibilité de l'évaluation.

Des mesures ont été prises pour que l'évaluation soit reproductibile,
c'est-à-dire que sous réserve de faire les mêmes requêtes en base pour charger
les données, la performance mesurée sera identique.

Les paragraphes suivants indiquent de quelle manière cette reproductibilité est
assurée.

#### Import des données dans R

D'abord, l'échantillonnage des données importées depuis la base mongodb sous R
doit être reproductible. Pour cela, un nombre aléatoire est sauvegardé à même
la base de données, sous l'intitulé "random_order". La requête utilisera ce
nombre aléatoire pour ordonner les observations, et prendre les N premières, où
N est le nombre d'observations à échantillonner.

#### Reproductibilité des traitements dans R

La reproductibilité des traitements dans R est assurée par l'utilisation de
suites pseudo-aléatoires avec `set.seed`, au moment du découpage en différents
échantillons (réalisé par mlr3).

Il a néanmoins été constaté des ruptures dans la reproductibilité de
l'échantillonnage dû à des changements de version de mlr3 (suspicion, cf
https://github.com/signaux-faibles/rsignauxfaibles/issues/41)

La même procédure peut être appliquée aux modèles qui ont un entraînement avec
une composante aléatoire.
