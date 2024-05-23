# Le modèle et son évaluation

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Objectif et historique du modèle](#objectif-et-historique-du-mod%C3%A8le)
- [Description du modèle d'apprentissage supervisé](#description-du-mod%C3%A8le-dapprentissage-supervis%C3%A9)
  - [Cible d'apprentissage](#cible-dapprentissage)
  - [Périmètre](#p%C3%A9rim%C3%A8tre)
  - [Modèle statistique et jeux de données](#mod%C3%A8le-statistique-et-jeux-de-donn%C3%A9es)
  - [Variables d'apprentissage](#variables-dapprentissage)
- [Prédictions](#pr%C3%A9dictions)
  - [Seuils de détection](#seuils-de-d%C3%A9tection)
  - [Explication des prédictions](#explication-des-pr%C3%A9dictions)
- [Évaluation du modèle](#%C3%89valuation-du-mod%C3%A8le)
  - [Lexique](#lexique)
  - [Jeu de test indépendant](#jeu-de-test-ind%C3%A9pendant)
  - [Choix des métriques](#choix-des-m%C3%A9triques)
  - [Performances mesurées](#performances-mesur%C3%A9es)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Objectif et historique du modèle

Le modèle Signaux Faibles vise à identifier des signes de fragilité des entreprises françaises, afin de permettre aux administrations de prendre contact avec ces entreprises et, le cas échéant, mettre en œuvre des dispositifs d'aide. Pour cela, il est important d'anticiper suffisamment en amont les difficultés afin que ces dispositifs soient efficaces.

Un modèle d'apprentissage supervisé a été initialement développé en 2018. Il a ensuite été étendu à la France entière en décembre 2019, puis mis à l'arrêt en mars 2020 au début de la crise économique et sociale induite par le COVID-19. Le modèle s'est, à cette époque, révélé inapte à traiter la situation spécifique à la crise. Entre octobre 2020 et fin 2023, de nouveaux modèles tenant compte de l'impact de la crise ont été proposés, notamment à travers la combinaison d’une prédiction par apprentissage supervisé et de règles « métier ». Ce type de modèle est décrit en détail dans les précédentes versions de ce document (depuis github.com, cliquer sur le bouton « ⟲ Historique » en haut à droite). Depuis début 2024, la profondeur d’historique acquise et la relative stabilité des indicateurs employés depuis l’épisode pandémique permettent de produire une prédiction de nouveau basée entièrement sur un apprentissage supervisé.

Le modèle et ses composants sont détaillés dans les paragraphes qui suivent. Le code implémentant ce modèle est ouvert et consultable [ici](https://github.com/signaux-faibles/sf-datalake-mirror).

## Description du modèle d'apprentissage supervisé

### Cible d'apprentissage

Nous posons le problème de classification binaire suivant :

> Le modèle cherche à prédire l'entrée en procédure collective (redressement ou liquidation judiciaire, sauvegarde, etc.) à 18 mois.

Cette cible d'apprentissage est imparfaite : des entreprises en difficulté peuvent ne pas connaître de défaillance dans les 18 mois, mais il serait pertinent de les détecter. C'est le cas par exemple d'entreprises financièrement solides mais dont l'activité ne leur permet pas d'être profitables. Inversement, certaines défaillances sont dues à des évènements non identifiables avec 18 mois d'anticipation (accidents, etc.), qui ne pourront donc être que potentiellement détectés plus tard.

Il est à noter que la cible d'apprentissage est très déséquilibrée : historiquement, environ 5% des entreprises en activité connaissent une défaillance chaque année. Ce chiffre a sensiblement diminué au début de la crise sanitaire liée au Covid-19, du fait des dispositifs de soutien aux entreprises ayant permis de maintenir « à flot » une part des entreprises éligibles. Voir, p.ex. le [suivi](https://www.banque-france.fr/statistiques/chiffres-cles-france-et-etranger/defaillances-dentreprises/suivi-mensuel-des-defaillances) des défaillances par la banque de France. Cette dynamique impacte fortement le processus d'apprentissage puisqu'une proportion importante d'entreprises sortent _de facto_ de la cible d'apprentissage, alors même qu'elles se seraient probablement trouvées particulièrement en difficulté en l'absence d'aides de l'État.

### Périmètre

Pour nourrir le modèle de détection, on se restreint aux données des entreprises répondant aux critères suivant :

- employer (ou avoir déjà employé) 10 salariés ou plus ;
- être immatriculé auprès de l'INSEE et avoir un numéro de SIREN.

On exclut du périmètre les entreprises :

- faisant partie de l'administration publique (code APE O) et de l'enseignement (code APE P).
- dont la [catégorie juridique](https://www.insee.fr/fr/information/2028129) fait partie de la liste ci-dessous :

  - Autre personne morale de droit administratif.
  - Établissement public des cultes d’Alsace-Lorraine.
  - Groupement de coopération sanitaire à gestion publique.
  - Groupement d’intérêt public (GIP).
  - (Autre) Établissement public administratif local.
  - Communauté d’agglomération.
  - Communauté de communes.
  - Commune et commune nouvelle.
  - Département.
  - Établissement public local à caractère industriel ou commercial.
  - Établissement public local culturel.
  - Établissement public local social et médico-social.
  - Établissement public national à caractère administratif.
  - Établissement public national à caractère industriel ou commercial doté d''un comptable public.
  - Établissement public national à caractère industriel ou commercial non doté d''un comptable public.
  - Établissement public national à caractère scientifique culturel et professionnel.
  - Institution Banque de France.
  - Autre établissement public national administratif à compétence territoriale limitée.

### Modèle statistique et jeux de données

Le modèle employé est une forêt aléatoire (implémentation [pyspark](https://spark.apache.org/docs/latest/api/python/reference/api/pyspark.ml.classification.RandomForestClassifier.html)) pour la classification, avec les paramètres spécifiques suivants : `{"maxDepth": 9, "numTrees": 100, "featureSubsetStrategy": "sqrt"}`.

L'entraînement (ou l’évaluation) a lieu sur un jeu de données localisées entre janvier 2016 et une date à laquelle le statut de défaillance à 18 mois est connu pour l’ensemble des entreprises considérées — ceci étant une condition nécessaire à la construction de la cible d’apprentissage en tout point du jeu. Un échantillon est défini comme un vecteur $X \in \mathbf{R}^n$ de $n$ caractéristiques rassemblant un certain nombre d’informations concernant une entreprise à un instant donné. Formellement, chaque ligne du jeu est associée à un couple `(SIREN, période)` distinct, le pas de temps entre deux échantillons d’une même entreprise étant le mois.

La prédiction produit, pour un échantillon associé à un couple `(SIREN, période)`, une prédiction pour les 18 mois suivant la période choisie.

### Variables d'apprentissage

Le modèle est entraîné sur les variables d'apprentissage (aussi nommées **caractéristiques**) décrites ci-dessous. Certaines des données utilisées sont définies à l’échelle de l’établissement (SIRET) et sont donc d’abord agrégées à l’échelle de l’entreprise (SIREN).

Caractéristiques financières :

- Ratio dette nette / capacité d’auto-financement ;
- Ratio dette à terme / capitaux propres ;
- Ratio EBE / chiffre d’affaires ;
- Ratio valeur ajoutée / effectif ;
- Ratio charges de personnel / valeur ajoutée ;
- Ratio stocks / chiffre d’affaires ;
- Liquidité absolue ;
- Liquidité réduite ;
- Ratio délai de paiement / délai d’encaissement ;
- Ratio capitaux propres / capital social ;
- Ratio BFR / capitaux propres ;
- Taux d’investissement ;
- Rentabilité économique ;
- Solidité financière.

Cotisations sociales :

- Cotisations sociales appelées ;
- Part salariale de la dette sociale ;
- Part patronale de la dette sociale ;
- Dette sociale rapportée à la cotisation annuelle moyenne ;
- Dette sociale rapportée à l’effectif de l’entreprise.

Activité partielle :

- Consommation d’activité partielle.

Comportements de paiement :

- Paydex : encours pondérés des retards de paiement fournisseurs ;
- FPI 30 : part des paiements fournisseurs ayant plus de 30 jours de retard ;
- FPI 90 : part des paiements fournisseurs ayant plus de 90 jours de retard.

Chaque échantillon contient des données associées à un couple `(SIREN, période)` qui sont donc contemporaines à l’horodatage `période`, mais il embarque également de l’information concernant les périodes passées (à travers des moyennes glissantes, des variables retard, etc.). Se reporter au [dossier](https://github.com/signaux-faibles/sf-datalake-mirror/blob/develop/src/sf_datalake/configuration/) de configuration dans l’implémentation pour une description détaillée.

## Prédictions

### Seuils de détection

Le modèle Signaux Faibles résout un problème de classification binaire (l’entrée ou non en procédure collective à 18 mois), qui produit pour chaque échantillon évalué une probabilité estimée de défaut à 18 mois. Cette probabilité est un nombre réel entre 0 et 1, nous devons choisir à partir de quel seuil une entreprise est portée à la connaissance des agents pour les alerter d’une potentielle fragilité. Afin de permettre aux agents de prioriser leur action, nous définissons deux seuils en probabilités qui séparent les prédictions en trois catégories :

- un niveau « risque fort » 🔴 où la précision est plus élevée, c'est-à-dire que les entreprises identifiées comme à risque fort le sont effectivement, quitte à ne pas détecter certaines entreprises qui feront effectivement défaut ;
- un niveau « risque modéré » 🟠 construit de sorte à capturer un maximum d'entreprises à risque, quitte à produire plus de faux positifs, c'est-à-dire détecter des entreprises qui ne feront en réalité pas défaut dans les 18 mois ;
- un niveau « aucune alerte » 🟢, pour toutes les entreprises pour lesquelles la probabilité estimée est plus basse que le seuil « risque modéré ». Ce niveau comprend donc toutes les entreprises de notre périmètre n'entrant pas dans les deux catégories ci-dessus.

Les deux seuils sont déterminés comme les points de l’intervalle $\[0 ; 1\]$ qui maximisent la valeur de scores $F_{\beta}$ lorsque les échantillons sont classifiés autour de la valeur de seuil choisie. Plus précisément :

- le seuil du palier « risque fort » est choisi pour maximiser le $F_{0.5}$, une métrique qui favorise deux fois plus la précision que le rappel.
- le seuil du palier « risque modéré » est choisi pour maximiser le score $F_2$, qui favorise deux fois plus le rappel que la précision.

Plus de précisions sur les métriques mentionnées sont fournies dans la section concernant l’[évaluation](#%C3%89valuation-du-mod%C3%A8le) du modèle.

### Explication des prédictions

Chaque prédiction « positive » (niveau de risque fort ou modéré) est accompagnée d'explications sur les raisons qui ont mené à ce résultat. Ces explications sont produites à deux niveaux de granularité :

- au niveau de chaque caractéristique utilisée par ce modèle de prédiction ;
- à un niveau agrégé, par groupes « thématiques » de variables exposés plus haut :

  - santé financière ;
  - cotisations sociales aux URSSAF ;
  - les comportements de paiement fournisseur ;
  - le recours à l'activité partielle.

Ainsi, chacune des variables prédictives du modèle appartient à un groupe thématique. Pour une prédiction donnée, l'influence unitaire d'une caractéristiques est fournie par l’intermédiaire de valeurs de Shapley, grâce à l’outil [SHAP](https://github.com/shap/shap). Pour fournir l'influence d'un groupe thématique, on somme l'ensemble des contributions unitaires des caractéristiques appartenant au groupe thématique choisi.

Plusieurs indicateurs explicatifs sont ainsi présentés aux agents :

- des explications textuelles précisant les variables ayant la plus forte contribution unitaire en faveur d'une détection.
- un « diagramme radar » dont la longueur des branches représente l’influence de chaque groupe thématique, telle que calculée dans le paragraphe précédent. Quelques exemples pour comprendre ce qu'affiche ce radar :

  - un indicateur « Santé financière » dans le vert indique que l'entreprise a une situation financière excellente dans l'ensemble, ou plutôt qui contribue très fortement à la considérer comme une entreprise sans risque de défaut ;
  - un indicateur « Dette URSSAF » dans le rouge indiquerait un historique d'encours de dette aux Urssaf contribuant à un score de risque élevé.

Des illustrations sont proposées dans le [guide d’information](https://signaux-faibles.gitbook.io/guide-dutilisation-et-f.a.q.-de-signaux-faibles/les-listes-de-detection/explication-du-modele-de-detection) « Signaux Faibles ».

## Évaluation du modèle

### Lexique

Par convention, nous choisissons pour la classification d'attribuer l’étiquette `1` aux échantillons qui répondent à la cible d’apprentissage, et `0` aux autres. En conséquence, nous définissons les termes suivante :

- **Vrai positif** : une entreprise que notre algorithme prédit comme à risque de défaillance dans les 18 mois et connaissant effectivement (au moins) une défaillance durant cette période.
- **Vrai négatif** : une entreprise pour laquelle aucune défaillance n'est prédite, et qui ne connaît pas de défaillance.
- **Faux positif** : une entreprise pour laquelle une défaillance est prédite, mais qui ne connaît pas de défaillance effective.
- **Faux négatif** : une entreprise pour laquelle aucune défaillance n'est prédite, mais qui connaît effectivement une défaillance.

À partir de ces définitions, on utilisera les métriques usuelles d'évaluation d'un algorithme d'apprentissage automatique :

- **Précision** : la part d'entreprises prédites positives étant effectivement positives
- **Rappel** : la part d'entreprises effectivement positives étant prédites positives.
- **Score** $F_\beta$ : une métrique d'évaluation prenant à la fois la précision et le rappel en compte, et accordant une importante relative $\beta$ fois plus importante au rappel qu'à la précision.
- **Score AUCPR** : l'aire sous la courbe rappel-précision (Area Under Curve, for Precision-Recall curve). Celle-ci permet d'étudier la performance du modèle et l'équilibre s'établissant entre ces deux scores en fonction du seuil de classification choisi.
- **Exactitude** : la proportion de prédictions correctes (à la fois vraies positives et vraies négatives) parmi le nombre total de cas examinés.

Pour plus d'informations sur ces métriques, voir les liens ci-dessous :

- [Précision et rappel](https://fr.wikipedia.org/wiki/Pr%C3%A9cision_et_rappel)
- [Matrice de confusion](https://fr.wikipedia.org/wiki/Matrice_de_confusion)
- [F-mesure](https://fr.wikipedia.org/wiki/F-mesure)
- [Score AUCPR](<https://en.wikipedia.org/wiki/Evaluation_measures_(information_retrieval)#Average_precision>)
- [Exactitude](https://fr.wikipedia.org/wiki/Exactitude_et_pr%C3%A9cision#Classification_binaire)

### Jeu de test indépendant

Afin que l'évaluation mesure le mieux possible la performance réelle du modèle, nous faisons en sorte que des observations associées à une entreprise donnée ne se retrouvent pas à la fois dans le jeu d'entraînement et le jeu de test. La corrélation entre plusieurs observations successives d'une série temporelle associées à une entreprise étant importante, une fuite d'information du jeu d'entraînement vers le jeu de test est probable et fait courir le risque de biais dans la performance mesurée ou le réglage des hyper-paramètres du modèle par validation croisée.

### Choix des métriques

Si l’on retire des jeux de test les cas des entreprises pour lesquelles une défaillance est déjà connue au moment où une prédiction pour les 18 mois à venir est prononcée (signaux « forts »), les échantillons positifs représentent un pourcentage extrêmement faibles de l'ensemble des échantillons traités ; on parle de cible très déséquilibrée.

Dans le contexte de Signaux Faibles, les faux positifs est beaucoup plus acceptable qu'un faux négatif. Ainsi, l’**exactitude rééquilibrée** ([balanced accuracy](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.balanced_accuracy_score.html)) et le **score AUCPR** ([average precision](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.average_precision_score.html)) se prêtent bien à l'évaluation de notre algorithme au global. On pourra regarder les $F_\beta$ associés à chacun des seuils :

- $F_{0.5}$ et la précision pour le niveau d’alerte « risque fort » ;
- $F_{2}$ et le rappel pour le niveau d’alerte « risque modéré »

### Performances mesurées

Au cours du temps, l’ensemble des éléments suivants sont naturellement amenés à évoluer, entraînant des évolutions dans la performance mesurée du modèle :

- caractéristiques en entrée du modèle exploitées ;
- contenu des jeux d’entraînement et de prédiction, au fur et à mesure des mises à jour des données brutes et de l’évolution de la conjoncture ;
- le type de modèle (et les hyper-paramètres associés) utilisé.

Les pages suivantes permettent un suivi de l’évolution du modèle d’apprentissage au fil de ces évolutions :

- [Métriques à juin 2021](evaluation-modele/juin2021.md).
- [Métriques entre septembre 2021 et décembre 2023](evaluation-modele/sept2021.md). Le modèle d'apprentissage supervisé n'ayant pas subi de mise à jour durant cette période les métriques restent identiques. Des règles expertes venaient directement moduler les niveaux d’alertes issue du modèle d’apprentissage, en fonction de données contemporaines (voir précédentes versions de ce document).
- [Métriques à mars 2024](evaluation-modele/mars2024.md).
