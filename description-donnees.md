Description des données
=======================

- [Description des données](#description-des-donn%C3%A9es)
  - [Préambule](#pr%C3%A9ambule)
  - [Périmètre des données](#p%C3%A9rim%C3%A8tre-des-donn%C3%A9es)
    - [Nombre d'établissements](#nombre-d%C3%A9tablissements)
    - [Taux de couverture des données](#taux-de-couverture-des-donn%C3%A9es)
  - [Données importées](#donn%C3%A9es-import%C3%A9es)
    - [Données sirene](#donn%C3%A9es-sirene)
    - [Données financières de la Banque de France](#donn%C3%A9es-financi%C3%A8res-de-la-banque-de-france)
    - [Données financières issues des bilans déposés au greffe de tribunaux de commerce](#donn%C3%A9es-financi%C3%A8res-issues-des-bilans-d%C3%A9pos%C3%A9s-au-greffe-de-tribunaux-de-commerce)
    - [Données sur l'activité partielle](#donn%C3%A9es-sur-lactivit%C3%A9-partielle)
      - [Données de demandes d'activité partielle](#donn%C3%A9es-de-demandes-dactivit%C3%A9-partielle)
      - [Données de consommation d'activité partielle](#donn%C3%A9es-de-consommation-dactivit%C3%A9-partielle)
    - [Données sur l'effectif](#donn%C3%A9es-sur-leffectif)
    - [Données sur les cotisations sociales et les débits](#donn%C3%A9es-sur-les-cotisations-sociales-et-les-d%C3%A9bits)
      - [Fichier sur les cotisations](#fichier-sur-les-cotisations)
      - [Fichiers sur les débits](#fichiers-sur-les-d%C3%A9bits)
        - [Codes état du compte](#codes-%C3%A9tat-du-compte)
        - [Codes procédure collective](#codes-proc%C3%A9dure-collective)
        - [Codes opération historique](#codes-op%C3%A9ration-historique)
        - [Code motif de l'écart négatif](#code-motif-de-l%C3%A9cart-n%C3%A9gatif)
    - [Données sur les délais](#donn%C3%A9es-sur-les-d%C3%A9lais)
    - [Données sur le procédures collectives](#donn%C3%A9es-sur-le-proc%C3%A9dures-collectives)

Préambule
---------

Ce dossier technique décrite les données utilisées dans le projet signaux-faibles. Avec l'évolution du projet, celles-ci vont naturellement être amenées à évoluer.

Les données utilisées proviennent de plusieurs sources:

-   **Données Sirene** Raison sociale, adresse, code APE, date de création etc.\
-   **Données Altarès** Données de défaillance, permet la définition de l'objectif d'apprentissage
-   **Données DIRECCTE** Autorisations et consommations d'activité partielle, recours à l'intérim, déclaration des mouvements de main-d'oeuvre
-   **Données URSSAF** Montant des cotisations, montant des dettes (part patronale, part ouvrière), demandes de délais de paiement, demandes préalables à l'embauche
-   **Données Banque de France** 6 ratios financiers
-   **Données Diane** Bilans et comptes de résultats. Permet d'enrichir les données financières de la Banque de France

Les sections ci-dessous détaillent la nature des données importées, et la nature des traitements qui leurs sont appliqués.

Périmètre des données
---------------------

### Nombre d'établissements  

L'algorithme tourne actuellement sur les données de la
Bourgogne-Franche-Comté et de Pays de la Loire. L'unité de base est
l'établissement. Les établissements de moins de 10 salariés ou dont
l'effectif est inconnu ne sont pas intégrés à l'entraînement de
l'algorithme. Il en résulte un stock d'environ 30000 établissements. 

Les établissements absents de la base sirène sont filtrées en post-traitement. 

### Taux de couverture des données 

TODO
 Rédaction en cours. 

Données importées
-----------------

### Données sirene

TODO en cours

### Données financières de la Banque de France  

  Les données financières de la Banque de France couvrent à ce jour uniquement la région Bourgogne Franche Comté. Elles consistent en 6 ratios financiers détaillées ci-dessous. 

|                          |                                               |
| ------------------------ | --------------------------------------------- |
| Source                   | Banque de France                              |
| Nombre de siren          | TODO                                          |
| Couverture siret         | TODO                                          |
| Fréquence de mise-à-jour | annuelle                                      |
| Délai des données        | Exercice n obtenu en septembre de l'année n+1 |

* __SIREN__ Siren de l'entreprise

* __ANNEE__ Année de l'exercice

* __ARRETE_BILAN__  Date de clôture de l'exercice. Format mm/jj/aaaa

* __DENOM__ Raison sociale de l'entreprise 

* __SECTEUR__ Secteur d'activité
           
* __POIDS_FRNG__ Poids du fonds de roulement net global sur le chiffre d'affaire. Exprimé en \%. 

* __TX_MARGE__  Taux de marge, rapport de l'excédent brut d'exploitation (EBE) sur la valeur ajoutée. Exprimé en \%. 
_100*EBE / valeur ajoutee_

* __DELAI_FRS__ Délai estimé de paiement des fournisseurs. Exprimé en jours. 
_360 * dettes fournisseurs / achats HT_

* __POIDS_DFISC_SOC__  Poids des dettes fiscales et sociales, par rapport à la valeur ajoutée. Exprimé en \%. 
_100 * dettes fiscales et sociales / Valeur ajoutee_

* __POIDS_FIN_CT__ Poids du financement court terme. Exprimé en \%. 
_100 * concours bancaires courants / chiffre d'affaires HT_

* __POIDS_FRAIS_FIN__ Poids des frais financiers, sur l'excedent brut d'exploitation corrigé des produits et charges hors exploitation. Exprimé en \%. 
_100 * frais financiers / (EBE + Produits hors expl. - charges hors expl.)_

### Données financières issues des bilans déposés au greffe de tribunaux de commerce

En cours de rédaction

### Données sur l'activité partielle

Deux fichiers: demandes d'activité partielle, et consommations d'activité partielles

|                              |                                            |
| ---------------------------- | ------------------------------------------ |
| Source                       | DARES                                      |
| Couverture                   | Toutes les demandes et consommations       |
| Fréquence de mise-à-jour     | Mensuelle, export base complète            |
| Délai des données (conso)    | Mois précédent, à quelques exceptions près |
| Délai des données (demandes) | Temps réel                                 |

#### Données de demandes d'activité partielle

TODO en cours

#### Données de consommation d'activité partielle

TODO en cours

### Données sur l'effectif

|                          |                               |
| ------------------------ | ----------------------------- |
| Source                   | URSSAF                        |
| Couverture               | TODO                          |
| Fréquence de mise-à-jour | Variable, tous les 3 à 6 mois |
| Délai des données        | 0 à 6 mois selon mise-à-jour  |


-   **Siret** Siret de l'établissement

-   **Compte** Compte administratif URSSAF

-   **Rais\_soc** Raison sociale

-   **Ur\_emet** Urssaf en charge de la gestion du compte

-   **Dep** Département 

-   **effAAAAXY** effectif du mois AAAAXY. AAAA = année. X = trimestre. Y = N° du mois dans le trimestre (ex: 201631 vaut juillet 2016)


### Données sur les cotisations sociales et les débits

Deux fichiers: cotisations, et débits sur les cotisations sociales

|                                 |                                         |
| ------------------------------- | --------------------------------------- |
| Source                          | URSSAF                                  |
| Couverture                      | TODO                                    |
| Fréquence de mise-à-jour        | mensuelle (autour du 20 de chaque mois) |
| Délai des données (cotisations) | cotisations du mois précédent           |
| Délai des données (débits)      | débits sur les cot. du mois précédent   |

#### Fichier sur les cotisations

#### Fichiers sur les débits

-   **num\_cpte** Compte administratif URSSAF

-   **Siren** Siren de l'entreprise

-   **Dt\_immat** Date d'immatriculation du compte à l'Urssaf

-   **Etat\_cpte** Code état du compte. Cf la table ci-dessous.

-   **Cd\_pro\_col** Code qui indique si le compte fait l'objet d'une procédure 
collective. Cf la table ci-dessous. 

-   **Periode** Période au format AAAAXY. Cf effectif pour l'explication. 

-   **Num\_Ecn** L'écart négatif (ecn) correspond à une période en débit. Pour 
une même période, plusieurs débits peuvent être créés. On leur attribue un 
numéro d'ordre. Par exemple, 101, 201, 301 etc.; ou 101, 102, 201 etc. 
correspondent respectivement au 1er, 2ème et 3ème ecn de la période considérée. 

-   **Num\_Hist\_Ecn**

-   **Dt\_trt\_ecn** Date de comptabilisation de l'évènement (mise en 
recouvrement, paiement etc..). Format (A)AAMMJJ, ou (A)AA correspond à l'année 
à laquelle a été soustrait 1900. Exemple: 1160318 vaut 18 mars 2016, 
990612	vaut 12 juin 1999. 

-   **Mt\_PO** Montant des débits sur la part ouvrières **en centimes**. Sont 
exclues les pénalités et les majorations de retard. 

-   **Mt\_PP** Montant des débits sur la part patronale **en centimes**. Sont 
exclues les pénalités et les majorations de retard. 

-   **Cd\_op\_ecn** Code opération historique de l'écart négatif. Cf table 
ci-dessous.

-   **Motif\_ecn** Code motif de l'écart négatif. Cf table ci-dessous

##### Codes état du compte
| Code | Description |
| ---- | ----------- |
| 1    | Actif       |
| 2    | Suspendu    |
| 3    | Radié       |

##### Codes procédure collective

| Code           | Description                             |
| -------------- | --------------------------------------- |
| 0, blanc, null | Pas de pro col                          |
| 1              | Pro col en cours                        |
| 2              | Pro col - plan de redressement en cours |
| 9              | Pro col sans dette à l'Urssaf           |


##### Codes opération historique
| Code | Description                               |
| ---- | ----------------------------------------- |
| 1    | Mise en recouvrement                      |
| 2    | Paiement                                  |
| 3    | Admission en non valeur                   |
| 4    | Remise de majoration de retard            |
| 5    | Abandon de solde debiteur                 |
| 11   | Annulation de mise en recouvrement        |
| 12   | Annulation paiement                       |
| 13   | Annulation a-n-v                          |
| 14   | Annulation de remise de majoration retard |
| 15   | Annulation abandon solde debiteur         |



##### Code motif de l'écart négatif
| Code | Description                                                                                |
| ---- | ------------------------------------------------------------------------------------------ |
| 0    | Cde motif inconnu                                                                          |
| 1    | Retard dans le versement                                                                   |
| 2    | Absence ou insuffisance de versement                                                       |
| 3    | Taxation provisionelle. Déclarations non fournies                                          |
| 4    | Majorations de retard complémentaires Article R243-18 du code de la sécurité sociale       |
| 5    | Contrôle,chefs de redressement notifiés le JJ/MM/AA Article R243-59 de la Securité Sociale |
| 6    | Fourniture tardive des déclarations                                                        |
| 7    | Bases déclarées supérieures à Taxation provisionnelle                                      |
| 8    | Retard dans le versement et fourniture tardive des déclarations                            |
| 9    | Absence ou insuffisance de versement et fourniture tardive des déclarations                |
| 10   | Rappel sur contrôle et fourniture tardive des déclarations                                 |
| 11   | Régularisation d'une taxation provisionnelle                                               |
| 12   | Régularisation annuelle                                                                    |
| 13   | Rejet du titre de paiement par la banque .                                                 |
| 14   | Modification d'affectation d'un crédit                                                     |
| 15   | Annulation d'un crédit                                                                     |
| 16   | Régularisation suite à modification du Taux Accident du Travail                            |
| 17   | Régularisation suite à assujettissement au transport (origine débit sur PJ=4)              |
| 18   | Majorations pour non respect de paiement par moyen dématérialisé Article L243-14           |
| 19   | Rapprochement TR/BRC sous réserve de vérification ultérieure                               |
| 20   | Cotisations complémentaires suite modification des revenus déclarés                        |
| 21   | Cotisations complémentaires suite à non fourniture du contrat d'exonération                |
| 22   | Contrôle. Chefs de redressement notifiés le JJ/MM/AA. Article L324.9 du code du travail    |
| 23   | Cotisations complémentaires suite conditions d'exonération non remplies                    |
| 24   | Absence de versement                                                                       |
| 25   | Insuffisance de versement                                                                  |
| 26   | Absence de versement et fourniture tardive des déclarations                                |
| 27   | Insuffisance de versement et fourniture tardive des déclarations                           |

### Données sur les délais

### Données sur le procédures collectives
