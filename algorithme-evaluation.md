# Évaluation de l'algorithme

## Découpage en échantillon d'entraînement, de validation et de test.

Lorsque différents algorithmes sont explorés, alors les données sont scindés en échantillons d'entraînement, de validation et de test.
Par défaut, les proportions de ces échantillons sont 60%, 20% et 20% respectivement. Cette scission est parfaitement reproductible (cf paragraphe consacré)

L'échantillon d'entraînement sert à l'entraînement de différents algorithmes, celui de validation à la comparaison des résultats, et celui de test n'est que rarement sollicité pour avoir une évaluation de la performance réelle de l'algorithme.

Afin d'éviter de fuite d'information d'un échantillon vers l'autre, les différentes "vues" d'un même établissement à des périodes différentes, et les établissements d'une même entreprise seront toujours regroupées dans le même échantillon.

Par défaut, **les "signaux forts"**, c'est-à-dire les entreprises pour lesquelles on peut affirmer avec certitudes qu'elles tombent dans la cible d'apprentissage, **sont retirés des échantillons d'évaluation (validation, test)**.
Ces entreprises sont les entreprises déjà en procédure collective, ou ayant déjà subi trois mois consécutifs de dette sur les cotisations sociales.
L'évaluation donne ainsi une image fidèle de la capacité prédictive de l'algorithme.

## Choix de la métrique

Après retrait des "signaux forts" (cf paragraphe précédent), la cible à détecter représente à peine 3% de l'échantillon d'entreprise. Il s'agit donc d'un échantillon très biaisé.

Le choix de l'**aire sous la courbe précision-rappel** comme métrique est compatible avec ce biais.

## Reproductibilité de l'évaluation.

Des mesures ont été prises pour la reproductibilité de l'évaluation.

### Intégration dans R

D'abord, l'échantillonnage des données importées sous R doit être reproductible.
Pour cela, un nombre aléatoire est sauvegardé à même la base de données, pour les données historiques susceptibles d'être échantillonnées, à savoir les données de 2015 et 2016.

Ce nombre aléatoire est généré dans un fichier à partir des données Sirene, puis intégré au même titre que les autres données, ce qui présente plusieurs avantages:

    * La conservation de l'historique des batchs successifs dans DataRaw
    * Le nombre aléatoire est transféré à la collection Features sous l'intitulé "random_order"
    * Il est possible d'ajouter de nouvelles entreprises, par exemple issues de nouvelles régions, sans toucher aux anciens champs. Ainsi, même après ajout de ces nouveaux établissements, un échantillonnage sur l'ancien périmètre renverra le même résultat.
    * Cela offre la possibilité future de compléter avec des informations d'échantillonnage directement dans la base: échantillon de test/validation/entraînement, ou validation croisée etc.
    * Un fichier .csv est facilement échangeable d'une personne à l'autre

### Reproductibilité des traitements dans R

La reproductibilité des traitements dans R est assurée par l'utilisation de suites pseudo-random et d'une _seed_.

C'est notamment le cas dans le découpage en différents échantillons, la préparation des données (ou un bruit peut être appliqué sur les données d'entraînement afin d'éviter le suréchantillonnage), ou encore dans l'entraînement de l'algorithme lorsque celui-ci dépend de composantes aléatoires.

Il est à noter que pour la constitution des échantillons d'entraînement, de test et de validation, les données sont d'abord triées, afin que le résultat ne dépende pas de leur ordre.

Cette reproducibilité est évidemment uniquement assuré en cas de paramètres identiques (pour l'algorithme, taille de l'échantillon initial, proportions dans les échantillons de validation, de test et de validation).

# Evolution de l'algorithme

TODO
