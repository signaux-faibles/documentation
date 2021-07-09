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
  - [Explication des scores de prédiction](#explication-des-scores-de-pr%C3%A9diction)
    - [Diagramme radar](#diagramme-radar)
    - [Explications textuelles](#explications-textuelles)
  - [_Evaluation du modèle: lexique_](#_evaluation-du-mod%C3%A8le-lexique_)
  - [_Seuils de détection_](#_seuils-de-d%C3%A9tection_)
- [Deuxième étage: Corrections liées à la crise :construction_worker: :building_construction:](#deuxi%C3%A8me-%C3%A9tage-corrections-li%C3%A9es-%C3%A0-la-crise-construction_worker-building_construction)
- [Evaluation du modèle - Méthodologie](#evaluation-du-mod%C3%A8le---m%C3%A9thodologie)
  - [Évaluation du modèle par validation croisée](#%C3%A9valuation-du-mod%C3%A8le-par-validation-crois%C3%A9e)
  - [Choix de la métrique](#choix-de-la-m%C3%A9trique)
  - [Benchmark](#benchmark)
  - [Reproductibilité de l'évaluation.](#reproductibilit%C3%A9-de-l%C3%A9valuation)
    - [Import des données dans Python](#import-des-donn%C3%A9es-dans-python)
    - [Reproductibilité des traitements dans Python](#reproductibilit%C3%A9-des-traitements-dans-python)
- [Evaluation du modèle - Métriques à juin 2021](#evaluation-du-mod%C3%A8le---m%C3%A9triques-%C3%A0-juin-2021)

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

### Explication des scores de prédiction

Nos listes d'entreprises en difficulté sont accompagnées d'explication sur les raisons de la présence ou de l'abscence de chaque établissement.
Ces explications sont produites sur la bases des variables utilisées par notre "premier étage algorithmique", et à deux niveaux de granularité:

- au niveau de chaque variable utilisée par ce modèle de prédiction
- à un niveau plus aggrégé, par groupe de variables de même thème. Parmi ces groupes de variables, on trouve les variables de santé financière, les variables de dette sur cotisations sociales aux URSSAF, le recours à l'activité partielle, et les retards de paiement aux fournisseurs.
  _A noter que, à juin 2021, les méthodes d'explication implémentées dans Signaux Faibles ne fonctionnent que pour un modèle de régression logistique._

Plusieurs indicateurs explicatifs sont ainsi interfacés dans l'application web.

#### Diagramme radar

Tout d'abord, un diagramme radar affichant, pour chaque groupe, un score de risque lié au groupe de variable. Cet indicateur est relatif à la situation de l'établissement en question par rapport à l'ensemble des établissements considérés par Signaux Faibles. Quelques exemples pour comprendre ce qu'affiche ce radar:

- un indicateur "Santé financière" dans le vert indique que l'établissement a une situation financière excellente dans l'ensemble, ou plutôt qui contribue très positivement à la considérer comme une entreprise sans risque.
- un indicateur "Retards fournisseurs" indique que l'établissement a un comportement en terme de retards de paiement qui n'influence pas spécifiquement notre score de risque. Ici, les variables de retards de paiements feraient donc, au moins en moyenne, assez peu pencher la balance vers un risque faible ou fort.
- un indicateur "Dette Urssaf" dans le rouge indiquerait un historique d'encours de dette aux Urssaf particulièrement inquiétant, contribuant à un score de risque élevé.

Pour une documentation technique des scores d'explication de la régression logistique, consulter la [documentation technique des scores d'explication](./modele-explications-doc-technique.pdf).

#### Explications textuelles

Sur les fiches établissement dans l'application Signaux Faibles, une liste de variables inquiétantes est fournie pour justifier un niveau de risque fort ou modéré. Il s'agit de variables qui, chacune individuellement, peuvent contribuer à un niveau de risque de 30%. A noter qu'il s'agit d'une capacité de contribution théorique maximale. Dans la pratique, ces variables contribuent ensemble à un niveau de risque fort, et leur contribution individuelle est moins élevée. Ceci est due au modèle employé. Pour plus de détail, voir la [documentation technique des scores d'explication](./modele-explications-doc-technique.pdf).

### _Evaluation du modèle: lexique_

Pour notre problème, nous choisissons d'attribuer un score de 1 aux entreprises ayant un risque maximal de défaillance, et 0 aux entreprises ayant un risque minimal de défaillance. En conséquence, nous avons les définitions suivantes:

Défaillance
: une entrée en procédure collective, ou une dette urssaf maintenue plus de 3 mois

Elément/établissement positif
: un établissement connaissant effectivement une défaillance à au moins un moment sur les 18 prochains mois

Elément/établissement négatif
: le contraire d'un établissement positif

Elément/établissement prédit positif
: un établissement que notre algorithme identifie comme à risque de défaillance (fort ou modéré) sur les 18 prochains mois

Elément/établissement prédit négatif
: le contraire d'un établissement prédit positif

Elément/établissement faux positif
: un établissement pour lequel une défaillance est prédite, mais qui ne connaît pas de défaillance effective

Elément/établissement faux négatif
: un établissement pour lequel aucune défaillance n'est prédite, mais qui connaît effectivement une défaillance

A partir de ces définitions, on dérive les métriques usuelles d'évaluation d'un algorithme d'apprentissage automatique:

Précision
: la part d'établissements prédits positifs étant effectivement positifs

Rappel
: la part d'établissements effectivement positifs étant prédits positifs

Score F*beta
: une métrique d'évaluation prenant à la fois la précision et le rappel en compte, et accordant une importante relative \_beta* fois plus importante au rappel qu'à la précision

Seuil de classification
: le modèle Signaux Faibles produit un score de risque entre 0 et 1 produit par notre algorithme. Hors, il faut décider à quel pallier de risque appartient chaque établissement à partir de ce score de risque. Pour ce faire, et au vu du modèle et de la cible d'apprentissage actuelle, il est nécessaire de définir un premier seuil sur le score de risque au-delà duquel l'établissement est à considérer "à risque modéré" de défaillance, et un second seuil, plus élevé que le premier, au-delà duquel l'établissement est à considérer "à risque fort" de défaillance. La méthodologie pour déterminer ces seuils est détaillée ci-dessous

Score AUCPR
: l'aire sous la courbe rappel-précision (Area Under Curve, for Precision-Recall curve). C'est une courbe obtenue à partir du rappel en abscisse, et de la précision en ordonnée, et qui permet d'étudier la performance du modèle en fonction du seuil de classification choisi

Pour plus d'informations sur ces métriques, voir les liens ci-dessous:

- [Précision et rappel](https://fr.wikipedia.org/wiki/Pr%C3%A9cision_et_rappel)
- [Matrice de confusion](https://fr.wikipedia.org/wiki/Matrice_de_confusion)
- [Score F_beta](https://en.wikipedia.org/wiki/F-score)

### _Seuils de détection_

Le premier étage algorithmique produit un score de risque de défaillance, compris entre 0 (aucun signal de risque) et 1 (risque fort détecté).
A partir de ces scores de risque, une liste d'entreprise à risque est construite, avec trois palliers de risques:

- un niveau "risque fort" :red_circle: où la précision est élevée, c'est-à-dire que les entreprises identifiées comme à risque fort le sont effectivement, quitte à manquer quelques entreprises qui font défaillance
- un niveau "risque modéré" :orange_circle: est construite de sorte à capturer un maximum d'entreprises à risque, quitte à avoir dans cette liste plus de faux positifs, c'est-à-dire d'établissements qui sont en réalité en bonne santé.
- un niveau "aucun signal de risque" :green_circle:, comprenant tous les établissements de notre périmètre n'entrant pas dans les deux palliers ci-dessus.

Ces seuils sont déterminés par la maximisation du score F\_{\beta}, une métrique permettant de prendre en compte à la fois les faux positifs et les faux négatifs.
Plus particulièrement:

- le seuil du pallier "risque fort" est choisi pour maximiser le F\_{0.5}, une métrique qui favorise deux fois plus la précision que le rappel. Ce score favorise ainsi une précision élevée, et donc l'exclusivité d'établissements effectivement en défaillance dans le pallier "risque fort".
- le seuil du pallier "risque modéré" est choisi pour maximiser le score F_2, qui favorise deux fois plus le rappel que la précision. La maximisation de cette métrique vise à obtenir un pallier "risqe modéré" qui capture un maximum d'établissements effectivement en défaillance, quitte à capturer "par erreur" des faux positifs, c'est-à-dire quitte à viser trop large et lister des entreprises qui n'entreront pas en défaillance.

La volumétrie des listes pour juin 2021 est donnée dans [evaluation-modele-juin2021.md](evaluation-modele-juin2021.md).

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
