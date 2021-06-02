# Le modèle et son évaluation

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Objectif et historique du modèle](#objectif-et-historique-du-mod%C3%A8le)
- [Modèle "à deux étages" de Mars 2021](#mod%C3%A8le-%C3%A0-deux-%C3%A9tages-de-mars-2021)
- [Premièr étage : L'apprentissage supervisé pré-crise](#premi%C3%A8r-%C3%A9tage--lapprentissage-supervis%C3%A9-pr%C3%A9-crise)
  - [_Objectif d'apprentissage_](#_objectif-dapprentissage_)
  - [_Périmètre_](#_p%C3%A9rim%C3%A8tre_)
  - [_Modèle_](#_mod%C3%A8le_)
  - [_Features_](#_features_)
  - [Seuils de détection :construction_worker:](#seuils-de-d%C3%A9tection-construction_worker)
- [Deuxième étage: Corrections liées à la crise :construction_worker: :building_construction:](#deuxi%C3%A8me-%C3%A9tage-corrections-li%C3%A9es-%C3%A0-la-crise-construction_worker-building_construction)
- [Évaluation du modèle](#%C3%A9valuation-du-mod%C3%A8le)
  - [Évaluation du modèle par validation croisée](#%C3%A9valuation-du-mod%C3%A8le-par-validation-crois%C3%A9e)
  - [Choix de la métrique](#choix-de-la-m%C3%A9trique)
  - [Reproductibilité de l'évaluation.](#reproductibilit%C3%A9-de-l%C3%A9valuation)
    - [Import des données dans Python](#import-des-donn%C3%A9es-dans-python)
    - [Reproductibilité des traitements dans Python](#reproductibilit%C3%A9-des-traitements-dans-python)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Objectif et historique du modèle

Le modèle Signaux Faibles vise à identifier de nouvelles entreprises en situation de fragilité, passées inaperçues auprès des administrations, alors que des dispositifs d'aide pourraient leur être proposés. Pour cela, il est important d'anticiper suffisamment les défaillances pour avoir le temps de mettre en œuvre ces dispositifs.

Un modèle d'apprentissage supervisé a été initialement développé avant la crise, a été étendu à la France entière en décembre 2019, mais a été mis à l'arrêt depuis le début du confinement de Mars 2020, car inapte à traiter la situation spécifique à la crise.

En octobre 2020, un nouveau modèle tenant compte de l'impact de la crise a été proposé. Le modèle qui a été retenu à cet effet est un modèle d'apprentissage automatique ("machine-learning") transparent, qui permet la définition de variables latentes explicatives, qui a été fortement inspiré par [ce modèle](http://dukedatasciencefico.cs.duke.edu/). Son périmètre a été provisoirement réduit aux entreprises industrielles et dont on connaît les informations financières, mais le même modèle a vocation a être étendu à tous les secteurs d'activité. La documentation relative à ce modèle peut-être retrouvée [ici](ab6de5f).

## Modèle "à deux étages" de Mars 2021

La crise économique liée au Covid-19 est un contexte nouveau, pour lequel l'apprentissage automatique est mis en défaut, du fait que le crise modifie en profondeur la conjoncture économique et le comportement des entreprises. Afin d'adapter au mieux notre algorithme à la situation économique liée à la crise Covid et de rapprocher nos listes de détection des préoccupations de nos utilisateurs, il a été décidé de faire évoluer le modèle vers une approche à "deux étages", qui permet de séparer le contexte en entrée de crise et l'impact de la crise sur chaque entreprise.

Les prédictions sont obtenues en deux étapes:

- D'abord, un **modèle _simple_ et _explicable_** (une régression logistique) est utilisé afin de prédire la situation d'un établissement _juste avant la crise_ (à Février 2020). Cette prédiction est transformée en trois catégories : niveau d'alerte rouge (risque de défaillance élevé), orange (risque de défaillance modéré) ou verte (pas de signal de risque).
- Ensuite, des corrections liées à la crise sont apportées via des **règles expertes** transparentes et co-construites avec nos utilisateurs afin de permettre au modèle de capter des réalités terrain liées à un contexte sans précédent et qu'un modèle d'apprentissage automatisé n'aurait — par définition — pas pu apprendre. Ces règles peuvent faire passer certaines entreprises dans un niveau d'alerte plus élevé.

La prédiction finale du modèle est donc complétement transparente et explicable — étant la superposition d'une [régression logistique](https://fr.wikipedia.org/wiki/R%C3%A9gression_logistique) et d'une règle experte ayant la forme d'un arbre de décision.

Le modèle de Mars 2021 est détaillé dans ce qui suit :

## Premièr étage : L'apprentissage supervisé pré-crise

### _Objectif d'apprentissage_

> anticiper de 18 mois l'entrée en procédure collective (liquidation redressement judiciaires, et sauvegarde) ou 3 mois consécutifs de cotisations sociales impayées.

Cet objectif d'apprentissage est imparfait : des entreprises en difficulté peuvent ne pas avoir de défaillance dans les 18 mois, mais seraient pertinentes à être détectées. C'est le cas par exemple d'entreprises financièrement solides mais dont l'activité ne leur permet pas d'être profitable. Inversement, certaines défaillances sont dues à des évènements non encore identifiables avec 18 mois d'anticipation (accidents, etc.), qui ne pourront donc être détectés que plus tard.

De plus, de nombreuses entreprises ont bénéficié de reports de charges pendant le premier confinement et entrent donc mécaniquement dans notre cible d'apprentissage, n'ayant pas payé de cotisations sociales pendant 3 mois. Pour éviter que ce très fort biais dans notre cible d'apprentissage à partir de Décembre 2018 (Mai 2020 - 18 mois) n'impacte l'entrainement de notre modèle, nous avons restreint cet entrainement à la période allant de Janvier 2016 à Novembre 2018.

:construction_worker: nous travaillons actuellement à la redéfinition de cette cible d'apprentissage, en concertation avec nos partenaires.

A noter que la cible d'apprentissage est très déséquilibrée: statistiquement, environ 5.5% des établissements observés aujourd'hui feront défaillance dans les 18 mois à venir. Ce chiffre a chuté lors au début de la crise Covid-19, du fait des dispositifs de soutien aux entreprises ayant permis de maintenir "à flot" une part des entreprises éligibles. Qui plus est, une part de ces 5.5% sont des établissements pour lequel on dispose d'un "signal fort" (voir ci-dessous).

### _Périmètre_

- Établissements de 10 salariés et plus.
- France métropolitaine entière
- A l'exception des établissements de l'administration publique (code APE O) et de l'enseignement (code APE P).

### _Modèle_

Le modèle utilisé est une régression logistique, à ce stade sans interactions. Elle est aujourd'hui entrainée sur de la donnée allant de janvier 2016 à novembre 2018 (pous les raisons évoquées plus haut) et produit une prédiction à Février 2020 qui peut etre interprétée comme la situation pré-crise Covid de l'etablissement.

### _Features_

Le modèle est entrainé sur les variables d'apprentissage suivantes:

- `apart_heures_consommees_cumulees` (en base)
- `apart_heures_consommees` (en base)
- `ratio_dette` (en base)
- `avg_delta_dette_par_effectif` (calculé: évolution moyenne de la dette sociale sur effectif sur les 3 derniers mois)
- `paydex_group` (calculé: retard de paiement moyen de l'entreprise — groupes : [0, 15, 30, 60, 90+[)
- `paydex_yoy` (calculé: évolution sur 12 mois du retard de paiement moyen de l'entreprise)
- `financier_court_terme` (en base)
- `interets` (en base)
- `ca` (en base)
- `equilibre_financier` (en base)
- `endettement` (en base)
- `degre_immo_corporelle` (en base)
- `liquidite_reduite` (en base)
- `poids_bfr_exploitation` (en base)
- `productivite_capital_investi` (en base)
- `rentabilite_economique` (en base)
- `rentabilite_nette"` (en base)

Voir [ce document](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/js/reduce.algo2/docs/variables.json) pour la définition et la source des champs présents en base.

### Seuils de détection :construction_worker:

Les seuils ont pour l'instant été arbitrairement fixés pour garantir des volumes raisonnables d'entreprises détéctées. Il serait pertinent d'améliorer cette méthode, notamment en trouvant les seuils qui maximisent notre critère d'évaluation.

## Deuxième étage: Corrections liées à la crise :construction_worker: :building_construction:

Des corrections "expertes" sont réalisées après l'apprentissage supervisé:

- Une correction "Dette Sociale" qui vise à détecter les entreprises qui n'ont pas repris le paiement de leur dette URSSAF depuis l'été 2020 (date à laquelle les reports de charges consentis pendant le premier confinement se sont terminés).

- :construction_worker: D'autres corrections encore en cours de co-construction avec nos utilisateurs autour notamment :
  - du recours à l'activité partielle longue durée
  - de papiers de recherche (institutionnels ou académiques) sur l'impact de la crise Covid par secteur d'activité

## Evaluation du modèle - Méthodologie

Uniquement la partie "apprentissage supervisée" du modèle peut être évaluée proprement, dans la mesure où la crise n'a pas produit tous ses effets économiques et que nous ne disposons pas de visibilité sur les défaillances futures pour évaluer la performance des corrections apportées.

### Évaluation du modèle par validation croisée

Afin que l'évaluation représente le mieux possible la mesure de la capacité de généralisation à la situation réelle d'utilisation du modèle, il faut veiller aux éléments suivants:

- Plusieurs observations d'un même établissement ou les établissements de la même entreprise doivent se retrouver dans le même échantillon, sous peine d'avoir une fuite d'information de l'échantillon d'entraînement vers l'échantillon de test (la performance biaisée du modèle favoriserait le sur-apprentissage au niveau de l'entreprise).
- L'évaluation ne doit pas tenir compte des entreprises déjà défaillantes (des "signaux forts"), pour lesquelles le modèle n'est pas utilisé en pratique.

### Choix de la métrique

Après retrait des "signaux forts" (cf paragraphe précédent), la cible à détecter représente à peine 3% de l'échantillon d'entreprise. Il s'agit donc d'un échantillon très biaisé.

Dans le contexte de Signaux Faibles, les faux positifs (un doute est émis sur une entreprise en réalité bien portante) est beaucoup plus acceptable qu'un faux négatif (une entreprise en difficulté n'a pas été détectée).

Ainsi, la **précision moyenne** (average accuracy) se prête bien à l'évaluation de notre algorithme. Nous utilisons également un **score F-beta** avec une valeur de beta proche de 2 afin de pénaliser plus fortement les faux négatifs.

L'**aire sous la courbe précision-rappel** (AUCPR) est également une métrique adaptée à ce contexte.

### Benchmark
Un benchmark est actuellement réalisé par l'équipe data science de Signaux Faibles, à la fois pour évaluer la performance de notre modèle relativement à d'autres modèles, et en prospective de modèles pouvant être intégrés à l'avenir. Voir: https://drive.google.com/file/d/1S7FymmDT1Ml_vccHXv2FTDvJde931YuO/view?usp=sharing

### Reproductibilité de l'évaluation.

Des mesures ont été prises pour que l'évaluation soit reproductibile, c'est-à-dire que sous réserve de faire les mêmes requêtes en base pour charger les données, la performance mesurée sera identique.

Les paragraphes suivants indiquent de quelle manière cette reproductibilité est
assurée.

#### Import des données dans Python

D'abord, l'échantillonnage des données importées depuis la base mongodb sous python doit être reproductible. Pour cela, un nombre aléatoire est sauvegardé à même la base de données, sous l'intitulé "random_order". La requête utilisera ce nombre aléatoire pour ordonner les observations, et prendre les `N` premières, où `N` est le nombre d'observations à échantillonner.

#### Reproductibilité des traitements dans Python

La reproductibilité des traitements dans python est assurée par l'utilisation du décorateur `is_random` pour les fonctions avec une composante aléatoire. Toutes ces fonctions peuvent alors être "seedée" via la variable d'environnement `RANDOM_SEED`.

La même procédure peut être appliquée aux modèles qui ont un entraînement avec une composante aléatoire.

## Evaluation du modèle - Métriques à juin 2021
Voir [evaluation-modele-juin2021.md](evaluation-modele-juin2021.md)

