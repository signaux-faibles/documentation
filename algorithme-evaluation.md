# Évaluation du modèle

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Évaluation du modèle par validation croisée](#%C3%A9valuation-du-mod%C3%A8le-par-validation-crois%C3%A9e)
- [Choix de la métrique](#choix-de-la-m%C3%A9trique)
- [Reproductibilité de l'évaluation.](#reproductibilit%C3%A9-de-l%C3%A9valuation)
  - [Import des données dans R](#import-des-donn%C3%A9es-dans-r)
  - [Reproductibilité des traitements dans R](#reproductibilit%C3%A9-des-traitements-dans-r)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Évaluation du modèle par validation croisée

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

## Choix de la métrique

Après retrait des "signaux forts" (cf paragraphe précédent), la cible à détecter représente à peine 3% de l'échantillon d'entreprise. Il s'agit donc d'un échantillon très biaisé.

L'**aire sous la courbe précision-rappel** (AUCPR) est une métrique adaptée à
ce contexte.

## Reproductibilité de l'évaluation.

Des mesures ont été prises pour que l'évaluation soit reproductibile,
c'est-à-dire que sous réserve de faire les mêmes requêtes en base pour charger
les données, la performance mesurée sera identique.

Les paragraphes suivants indiquent de quelle manière cette reproductibilité est
assurée.

### Import des données dans R

D'abord, l'échantillonnage des données importées depuis la base mongodb sous R
doit être reproductible. Pour cela, un nombre aléatoire est sauvegardé à même
la base de données, sous l'intitulé "random_order". La requête utilisera ce
nombre aléatoire pour ordonner les observations, et prendre les N premières, où
N est le nombre d'observations à échantillonner.

### Reproductibilité des traitements dans R

La reproductibilité des traitements dans R est assurée par l'utilisation de
suites pseudo-aléatoires avec `set.seed`, au moment du découpage en différents
échantillons (réalisé par mlr3).

Il a néanmoins été constaté des ruptures dans la reproductibilité de
l'échantillonnage dû à des changements de version de mlr3 (suspicion, cf
https://github.com/signaux-faibles/rsignauxfaibles/issues/41)

La même procédure peut être appliquée aux modèles qui ont un entraînement avec
une composante aléatoire.
