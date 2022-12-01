# Le modèle et son évaluation

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Objectif et historique du modèle](#objectif-et-historique-du-mod%C3%A8le)
- [Modèle à « deux étages »](#mod%C3%A8le-%C3%A0-%C2%AB-deux-%C3%A9tages-%C2%BB)
- [Premier étage : apprentissage supervisé pré-crise](#premier-%C3%A9tage--apprentissage-supervis%C3%A9-pr%C3%A9-crise)
  - [Cible d'apprentissage](#cible-dapprentissage)
  - [Périmètre](#p%C3%A9rim%C3%A8tre)
  - [Modèle](#mod%C3%A8le)
  - [Variables d'apprentissage](#variables-dapprentissage)
    - [Variables financières (source DGFiP)](#variables-financi%C3%A8res-source-dgfip)
    - [Autres variables (sources URSSAF, ministère du travail, paydex)](#autres-variables-sources-urssaf-minist%C3%A8re-du-travail-paydex)
  - [Explication des scores de prédiction](#explication-des-scores-de-pr%C3%A9diction)
    - [Diagramme radar](#diagramme-radar)
    - [Explications textuelles](#explications-textuelles)
  - [Évaluation du modèle : lexique](#%C3%A9valuation-du-mod%C3%A8le--lexique)
  - [Seuils de détection](#seuils-de-d%C3%A9tection)
- [Deuxième étage : corrections liées à la crise :construction_worker: (septembre 2022)](#deuxi%C3%A8me-%C3%A9tage--corrections-li%C3%A9es-%C3%A0-la-crise-construction_worker-septembre-2022)
  - [URSSAF](#urssaf)
    - [Signal favorable](#signal-favorable)
    - [Signal défavorable](#signal-d%C3%A9favorable)
  - [Activité Partielle](#activit%C3%A9-partielle)
  - [Données financières](#donn%C3%A9es-financi%C3%A8res)
- [Evaluation du modèle : méthodologie](#evaluation-du-mod%C3%A8le--m%C3%A9thodologie)
  - [Jeu de test indépendant](#jeu-de-test-ind%C3%A9pendant)
  - [Choix de la métrique](#choix-de-la-m%C3%A9trique)
- [Évaluation du modèle : scores](#%C3%A9valuation-du-mod%C3%A8le--scores)
  - [Métriques à juin 2021](#m%C3%A9triques-%C3%A0-juin-2021)
  - [Métriques à septembre 2021](#m%C3%A9triques-%C3%A0-septembre-2021)
  - [Métriques à décembre 2022](#m%C3%A9triques-%C3%A0-d%C3%A9cembre-2022)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Objectif et historique du modèle

Le modèle Signaux Faibles vise à identifier de nouvelles entreprises en situation de fragilité, passées inaperçues auprès des administrations, alors que des dispositifs d'aide pourraient leur être proposés. Pour cela, il est important d'anticiper suffisamment les défaillances pour avoir le temps de mettre en œuvre ces dispositifs.

Un modèle d'apprentissage supervisé a été initialement développé avant la crise, a été étendu à la France entière en décembre 2019, mais a été mis à l'arrêt depuis le début du confinement de Mars 2020, car inapte à traiter la situation spécifique à la crise.

Depuis octobre 2020, de nouveaux modèles tenant compte de l'impact de la crise ont été proposés. Le dernier en date consiste en un modèle à « deux étages » qui est décrit ci-dessous.

## Modèle à « deux étages »

La crise économique liée au Covid-19 est un contexte nouveau, pour lequel l'apprentissage automatique est mis en défaut, du fait que le crise modifie en profondeur la conjoncture économique, le comportement des entreprises, ainsi que les critères d'entrée en procédures collectives. Afin d'adapter au mieux notre algorithme à la situation économique liée à la crise Covid et de rapprocher nos listes de détection des préoccupations de nos utilisateurs, il a été décidé de faire évoluer le modèle vers une approche à « deux étages », qui permet de séparer le contexte en entrée de crise et l'impact de la crise sur chaque entreprise.

Les prédictions sont obtenues en deux étapes :

1. D'abord, un **modèle _simple_ et _explicable_** (une régression logistique) est utilisé afin de prédire la situation d'un entreprise _juste avant la crise_ (à Février 2020). Cette prédiction est transformée en trois catégories :
   niveau d'alerte rouge (risque de défaillance estimé élevé), orange (risque de défaillance estimé modéré) ou verte (pas de facteur de risque identifié).
2. Ensuite, des corrections liées à la crise sont apportées via des **règles expertes** transparentes et co-construites avec nos utilisateurs afin de permettre au modèle de capter des réalités terrain liées à un contexte sans précédent et qu'un modèle d'apprentissage automatisé n'aurait — par définition — pas pu apprendre. Ces règles peuvent augmenter le niveau d'alerte initialement produit par le modèle.

La prédiction finale du modèle est donc complétement transparente et explicable — étant la superposition d'une [régression logistique](https://fr.wikipedia.org/wiki/R%C3%A9gression_logistique) et de critères experts prenant la forme d'un arbre de décision (voir [paragraphe](#deuxi%C3%A8me-%C3%A9tage--corrections-li%C3%A9es-%C3%A0-la-crise-construction_worker) _infra_ concernant ces critères experts).

Le modèle est détaillé dans ce qui suit.

## Premier étage : apprentissage supervisé pré-crise

### Cible d'apprentissage

> Le modèle cherche à prédire l'entrée en procédure collective (liquidation et redressement judiciaires, sauvegarde, etc.) à 18 mois.

Cette cible d'apprentissage est imparfaite : des entreprises en difficulté peuvent ne pas avoir de défaillance dans les 18 mois, mais il serait pertinent de les détecter. C'est le cas par exemple d'entreprises financièrement solides mais dont l'activité ne leur permet pas d'être profitable. Inversement, certaines défaillances sont dues à des évènements non encore identifiables avec 18 mois d'anticipation (accidents, etc.), qui ne pourront donc être détectés que plus tard.

Il est à noter que la cible d'apprentissage est très déséquilibrée : historiquement, environ 5% des entreprises en activité connaissent une défaillance chaque année. Ce chiffre a sensiblement diminué au début de la crise sanitaire liée au Covid-19, du fait des dispositifs de soutien aux entreprises ayant permis de maintenir « à flot » une part des entreprises éligibles. Voir, p.ex. le [suivi](https://www.banque-france.fr/statistiques/chiffres-cles-france-et-etranger/defaillances-dentreprises/suivi-mensuel-des-defaillances) des défaillances par la banque de France. Cette dynamique impacte fortement le processus d'apprentissage puisqu'une proportion importante d'entreprises sortent _de facto_ de la cible d'apprentissage, alors même qu'elles se seraient probablement trouvées particulièrement en difficulté en l'absence d'aides de l'État.

### Périmètre

On considère l'ensemble des entreprises :

- de 10 salariés et plus ;
- étant immatriculé auprès de l'INSEE et ayant un numéro de SIREN ;

On exclut du périmètre les entreprises :

- faisant partie de l'administration publique (code APE O) et de l'enseignement (code APE P).
- dont la [catégorie juridique](https://www.insee.fr/fr/information/2028129) faisant partie de la liste ci-dessous.

```
- 'Autre personne morale de droit administratif'
- 'Établissement public des cultes d''Alsace-Lorraine'
- 'Groupement de coopération sanitaire à gestion publique'
- 'Groupement d''intérêt public (GIP)'
- '(Autre) Établissement public administratif local'
- 'Communauté d''agglomération'
- 'Communauté de communes'
- 'Commune et commune nouvelle'
- 'Département'
- 'Établissement public local à caractère industriel ou commercial'
- 'Établissement public local culturel'
- 'Établissement public local social et médico-social'
- 'Établissement public national à caractère administratif'
- 'Établissement public national à caractère industriel ou commercial doté d''un comptable public'
- 'Établissement public national à caractère industriel ou commercial non doté d''un comptable public'
- 'Établissement public national à caractère scientifique culturel et professionnel'
- 'Institution Banque de France'
- 'Autre établissement public national administratif à compétence territoriale limitée'
```

### Modèle

Le modèle utilisé est une régression logistique. L'entraînement a lieu sur des données s'étalant de janvier 2016 à novembre 2018 (18 mois avant la crise Covid et la diminution des entrées en procédures collectives), et produit une prédiction à février 2020 qui peut être interprétée comme le risque pré-crise estimé de l’entreprise.

### Variables d'apprentissage

Le modèle est entraîné sur les variables d'apprentissage suivantes.

#### Variables financières (source DGFiP)

```
- Chiffre d'affaire
- Excédent brut d'exploitation retraité
- Trésorerie
- Ratio Rentabilité / Marge brute d'exploitation
- Besoin en fondes de roulement
- Fonds de roulement net global
- Rentabilité
- Solidité financière
- Ratio Investissements / CA
```

#### Autres variables (sources URSSAF, ministère du travail, paydex)

Les variables issues de la base Signaux Faibles sont définies au niveau SIRET (établissement) agrégées au niveau du SIREN (entreprise) :

```
- "cotisation" # cotisation mensuelle URSSAF
- "cotisation_moy12m", # moyenne glissante sur 12 mois des cotisations URSSAF
- "montant_part_ouvriere", # montant de la part salariale de la dette URSSAF
- "montant_part_patronale", # montant de la part patronale de la dette URSSAF
- "montant_part_ouvriere_lag1m",
- "montant_part_ouvriere_lag2m",
- "montant_part_ouvriere_lag3m",
- "montant_part_ouvriere_lag6m",
- "montant_part_ouvriere_lag12m",
- "montant_part_patronale_lag1m",
- "montant_part_patronale_lag2m",
- "montant_part_patronale_lag3m",
- "montant_part_patronale_lag6m",
- "montant_part_patronale_lag12m",
- "effectif", # effectif de l'entreprise
- "apart_heures_consommees", # consommation d'activité partielle
- "apart_heures_consommees_cumulees", # somme cumulée de la consommation d'activité partielle
- "ratio_dette", # dette sociale / (somme des moyennes annuelles des cotisations de chaque établissement d'une entreprise
- "ratio_dette_moy12m" # moyenne glissante sur 12 mois (à l'échelle du SIREN= de la variable précédente
- "dette_par_effectif_slope3m", # évolution de la dette sociale par effectif sur 3 mois
```

Voir [ce document](https://github.com/signaux-faibles/opensignauxfaibles/blob/master/js/reduce.algo2/docs/variables.json) pour la définition et la source des champs pré-calculés.

N. B. : la pertinence du jeu de variables a été remise en cause par le partenariat, la prochaine version du modèle d'apprentissage utilisera très probablement d'autres variables financières sur base d'une sélection de variables préalable.

### Explication des scores de prédiction

Nos listes d'entreprises en difficulté sont accompagnées d'explications sur les raisons de la présence ou l'absence de chaque entreprise dans ces listes.

Ces explications sont produites sur la base des variables utilisées par notre « premier étage » algorithmique, et à deux niveaux de granularité :

- au niveau de chaque variable utilisée par ce modèle de prédiction ;
- à un niveau plus agrégé, par groupe de variables de même « thématique ». Parmi ces groupes de variables, on trouve :
  - les variables de santé financière ;
  - les variables de dette sur cotisations sociales aux URSSAF ;
  - les comportements de paiement « paydex » (lorsque cette donnée est disponible)
  - le recours à l'activité partielle.

Ainsi, chacune des variables prédictives du modèle appartient à un groupe thématique. Pour une entreprise donnée, l'influence unitaire d'une variable associée à un indice `i` est le produit `w_i * x_i`, où `w` désigne le vecteur de poids issu de la phase d'apprentissage de la régression logistique, `x` le vecteur des caractéristiques de l'entreprise étudiée au moment de la prédiction. Pour obtenir l'influence d'un groupe thématique, il suffit de sommer l'ensemble des contributions unitaires des variables appartenant au groupe thématique choisi.

Plusieurs indicateurs explicatifs sont ainsi présentés dans l'interface web :

- des explications textuelles précisant les variables ayant la plus forte contribution unitaire en faveur d'une détection.
- un « diagramme radar » dont la longueur des différentes branches est déterminée en normalisant chacune des composantes, calculées comme précisé dans le paragraphe précédent, par le produit scalaire `<w, x>`.

#### Diagramme radar

Un diagramme radar affiche un score de risque associé à chacun des groupes de variables. Cet indicateur est relatif à la situation de l'entreprise en question par rapport à l'ensemble des entreprises considérées par Signaux Faibles. Quelques exemples pour comprendre ce qu'affiche ce radar :

- un indicateur « Santé financière » dans le vert indique que l'entreprise a une situation financière excellente dans l'ensemble, ou plutôt qui contribue très positivement à la considérer comme une entreprise sans risque.
- un indicateur « Dette Urssaf » dans le rouge indiquerait un historique d'encours de dette aux Urssaf particulièrement inquiétant, contribuant à un score de risque élevé.

#### Explications textuelles

Sur les fiches établissement de l'application Signaux Faibles, une liste de variables préoccupantes est fournie pour justifier un niveau de risque fort ou modéré.

### Évaluation du modèle : lexique

Par convention, nous choisissons d'attribuer un score de 1 aux entreprises ayant un risque maximal de défaillance, et 0 aux entreprises ayant un risque minimal de défaillance. En conséquence, nous avons les définitions suivantes :

- **Défaillance** : une entrée en procédure collective.
- **Vrai positif** : une entreprise que notre algorithme prédit comme à risque de défaillance dans les 18 mois et connaissant effectivement une défaillance à au moins un moment sur les 18 prochains mois.
- **Vrai négatif** : une entreprise pour laquelle aucune défaillance n'est prédite, et qui ne connaît pas de défaillance dans la période considérée.
- **Faux positif** : une entreprise pour laquelle une défaillance est prédite, mais qui ne connaît pas de défaillance effective.
- **Faux négatif** : une entreprise pour laquelle aucune défaillance n'est prédite, mais qui connaît effectivement une défaillance.

À partir de ces définitions, on définit les métriques usuelles d'évaluation d'un algorithme d'apprentissage automatique :

- **Précision** : la part d'entreprises prédites positives étant effectivement positives
- **Rappel** : la part d'entreprises effectivement positives étant prédites positives.
- **Score F-beta** : une métrique d'évaluation prenant à la fois la précision et le rappel en compte, et accordant une importante relative `beta` fois plus importante au rappel qu'à la précision.
- **Score AUCPR** : l'aire sous la courbe rappel-précision (Area Under Curve, for Precision-Recall curve). Celle-ci permet d'étudier la performance du modèle et l'équilibre s'établissant entre ces deux scores en fonction du seuil de classification choisi.

Pour plus d'informations sur ces métriques, voir les liens ci-dessous :

- [Précision et rappel](https://fr.wikipedia.org/wiki/Pr%C3%A9cision_et_rappel)
- [Matrice de confusion](https://fr.wikipedia.org/wiki/Matrice_de_confusion)
- [Score F_beta](https://en.wikipedia.org/wiki/F-score)

### Seuils de détection

Le modèle Signaux Faibles produit un score de risque entre 0 et 1. Or, il faut décider à quel pallier de risque appartient chaque entreprise à partir de ce score de risque. Pour ce faire, et au vu du modèle et de la cible d'apprentissage actuels, il est nécessaire de définir un premier seuil sur le score de risque au-delà duquel l'entreprise est à considérer « à risque modéré » de défaillance, et un second seuil — plus élevé que le premier — au-delà duquel l'entreprise est à considérer « à risque fort » de défaillance. La méthodologie pour déterminer ces seuils est détaillée ci-dessous.

A partir de ces scores de risque, une liste d'entreprises à risque est construite, avec trois palliers de risques:

- un niveau « risque fort » :red_circle: où la précision est élevée, c'est-à-dire que les entreprises identifiées comme à risque fort le sont effectivement, quitte à manquer quelques entreprises qui font défaillance
- un niveau « risque modéré » :orange_circle: est construite de sorte à capturer un maximum d'entreprises à risque, quitte à avoir dans cette liste plus de faux positifs, c'est-à-dire d'entreprises qui sont en réalité en bonne santé.
- un niveau « aucun signal » de risque :green_circle:, comprenant toutes les entreprises de notre périmètre n'entrant pas dans les deux palliers ci-dessus.

Ces seuils sont déterminés par la maximisation du score F-beta, une métrique permettant de « sanctionner » de manière pondérée les faux positifs et les faux négatifs produits par le modèle.

Plus particulièrement:

- le seuil du pallier « risque fort » est choisi pour maximiser le F\_{0.5}, une métrique qui favorise deux fois plus la précision que le rappel. Ce score favorise ainsi une précision élevée, et donc l'exclusivité d'entreprises effectivement en défaillance dans le pallier « risque fort ».
- le seuil du pallier « risque modéré » est choisi pour maximiser le score F_2, qui favorise deux fois plus le rappel que la précision. La maximisation de cette métrique vise à obtenir un pallier « risque modéré » qui capture un maximum d'entreprises effectivement en défaillance, quitte à capturer « par erreur » des faux positifs, c'est-à-dire quitte à viser trop large et lister des entreprises qui n'entreront pas en défaillance.

## Deuxième étage : corrections liées à la crise :construction_worker: (septembre 2022)

Afin de tenir compte des évènements ultérieurs au début de la crise sanitaire susceptibles d'infléchir le niveau d'alerte initialement calculé par le modèle d'apprentissage automatique, on étudie certaines situations jugées plutôt favorables ou défavorables à la santé de l'entreprise, et se traduisant concrètement en terme d'évolution des variables d'intérêt pour le modèle prédictif. L’occurrence ou la non-occurrence d'un ensemble de situations (signaux) est ainsi évaluée pour l'ensemble des entreprises du périmètre « Signaux Faibles », puis des règles expertes sont établies en fonction des valeurs associées à chacune des situations.

L'algorithme de ces correctifs peut être résumé comme suit : un compteur de risque est initialisé à zéro ; lorsqu'une condition favorable est réalisée, on diminue la valeur de ce compteur, lorsqu'une condition défavorable est réalisée, on augment la valeur de ce compteur. La valeur finale de ce compteur est ensuite limitée à l'intervalle (entier) [[-1; 1]]. Si le compteur est égal à 1 (resp. -1) à la fin de la procédure, le niveau d'alerte est augmenté (resp. diminué) d'un niveau, lorsque cela est possible dans la limite des trois niveaux d'alertes initialement définis (voir [seuils de détection](#seuils-de-d%C3%A9tection)).

Nous détaillons ci-dessous, par catégorie de variables, quelles combinaisons ainsi formées peuvent donnent lieu à une hausse ou à une baisse de ce compteur, pour ensuite éventuellement augmenter ou diminuer le niveau d'alerte présenté dans la liste de prédictions.

### URSSAF

#### Signal favorable

On descend la valeur du compteur de 1 si :

- On observe une dette significative entre mars 2020 et sept 2021, significative signifiant supérieure à 10% de la cotisation annuelle moyenne (sur l'ensemble des établissements) appelée.
- On observe une diminution relative de cette dette — qui devait être apurée en septembre 2021 — en c'est-à-dire que `(minimum(dette_récente) / maximum(dette_ancienne)) < 10%` à l'échelle de l'entreprise, où :
    - `dette_récente` représente les données de dette sociale mensuelle postérieures à septembre 2021 ;
    - `dette_ancienne` les données de dette sociale mensuelle entre mars 2020 et septembre 2021.

#### Signal défavorable

On augmente la valeur du compteur de 1 si :

- On observe une augmentation de la dette récente (définie comme précédemment).
- La détection par apprentissage statistique ne mentionnait pas les données URSSAF comme raison principale de détection.

### Activité Partielle

On considère la demande d'activité partielle effectuée entre juillet et décembre 2022.

Deux conditions sont testées :

- La demande a été supérieure à 240 jours. Ces 8 mois, correspondent au 8e percentile supérieur du nombre de jours demandés sur la période considérée, et dépassent de deux mois le niveau de demande maximum nominal (hors dérogation), d'après [cette FAQ](https://travail-emploi.gouv.fr/emploi-et-insertion/accompagnement-des-mutations-economiques/activite-partielle-chomage-partiel/faq-chomage-partiel-activite-partielle#duree-max) du ministère du travail.
- La demande concerne plus de la moitié du personnel. Cette condition est mise en place car la demande pourrait, pour un effectif plus réduit, n'être qu'un effet d'aubaine du dispositif mis en place ; on tente ainsi d'écarter ce genre de situations.

Si les deux conditions sont remplies, la valeur du compteur est augmentée de 1.

### Données financières

On calcule la valeur de vérité des trois conditions suivantes :

- Le ratio `endettement à terme / CAF` est supérieur ou égal à 4.
- L'EBE est négatif à la clôture du dernier exercice connu et le chiffre d'affaires réalisé de janvier au dernier mois connu sur l'exercice 2022 est supérieur ou égal à 80% du CA 2019 sur la même période. L'objectif est d'exclure les entreprises dont le rebond économique n'est pas avéré (activité réduite avec perte de marché) pour cibler les entreprise que les utilisateurs de signaux faibles peuvent le plus aider.
- Les capitaux propres de l'entreprise sont négatifs.

Si deux des trois conditions précédentes sont remplies, la valeur du compteur est augmentée de 1.
Si les trois conditions précédentes sont remplies, la valeur du compteur est augmentée de 2.

## Evaluation du modèle : méthodologie

Seule la partie « apprentissage supervisé » du modèle peut être évaluée de manière rigoureuse et exhaustive, dans la mesure où la crise n'a probablement pas encore produit tous ses effets et que nous ne disposons pas de visibilité sur les défaillances futures pour évaluer la performance des corrections expertes (« deuxième étage ») apportées.

### Jeu de test indépendant

Afin que l'évaluation mesure le mieux possible la performance réelle du modèle, nous faisons en sorte que les observations associées à une même entreprise ne se retrouvent pas à la fois dans le jeu d'entraînement et le jeu de test. La corrélation entre plusieurs observations successives d'une série temporelle associées à une entreprise étant importante, une fuite d'information du jeu d'entraînement vers le jeu de test est probable et fait courir le risque de biais dans la performance mesurée ou le réglage des hyper-paramètres du modèle par validation croisée.

### Choix de la métrique

Après retrait des « signaux forts » (cf. paragraphe précédent), la cible à détecter représente à peine 1% de l'échantillon d'entreprise. Il s'agit donc d'un échantillon très biaisé.

Dans le contexte de Signaux Faibles, les faux positifs (un doute est émis sur une entreprise en réalité bien portante) est beaucoup plus acceptable qu'un faux négatif (une entreprise en difficulté n'a pas été détectée).

Ainsi, la **justesse rééquilibrée** ([balanced accuracy](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.balanced_accuracy_score.html)) et le **score AUCPR** ([average precision](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.average_precision_score.html)) se prêtent bien à l'évaluation de notre algorithme. Nous utilisons également un **score F-beta** avec une valeur de Beta proche de 2 afin de pénaliser plus fortement les faux négatifs. Plus de détails sont disponibles dans les documents dédiés spécifiquement à l'évaluation des modèles successifs : voir sections ci-dessous.

## Évaluation du modèle : scores

### Métriques à juin 2021

Voir [évaluation du modèle - juin 2021](evaluation-modele/juin2021.md).

### Métriques à septembre 2021

Voir [évaluation du modèle - septembre 2021](evaluation-modele/sept2021.md).

### Métriques à décembre 2022

Les métriques sont identiques aux métriques précédentes, le modèle d'apprentissage supervisé n'ayant pas subi de mise à jour.
