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
        - [Table des motifs de recours à l'activité partielle](#table-des-motifs-de-recours-%C3%A0-lactivit%C3%A9-partielle)
        - [Table des périmètres du chômage.](#table-des-p%C3%A9rim%C3%A8tres-du-ch%C3%B4mage)
        - [Table des codes de recours antérieurs au chômage](#table-des-codes-de-recours-ant%C3%A9rieurs-au-ch%C3%B4mage)
      - [Données de consommation d'activité partielle](#donn%C3%A9es-de-consommation-dactivit%C3%A9-partielle)
    - [Table de correspondance entre compte administratif URSSAF et siret](#table-de-correspondance-entre-compte-administratif-urssaf-et-siret)
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
    - [Données sur les CCSF](#donn%C3%A9es-sur-les-ccsf)

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
l'algorithme. 

Il en résulte un stock de 30085 établissements issues de 22665 entreprises. 
Le tableau ci-dessous donne le détail par région (certaines entreprises ont des établissements dans plusieurs régions).

|  Région                  |  Nombre d'établissements                      | Nombre d'entreprises
| ------------------------ | --------------------------------------------- | --------------------------------
| Bourgogne-Franche-Comté  | 12347                                         | 9308
| Pays de la Loire         | 17738                                         | 13807

Les établissements éventuellements absents de la base sirène (en cas de base sirène obsolète par exemple) sont filtrées en post-traitement. 

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

Données communes :

- __ID_DA__ N° de la demande
- __ETAB_SIRET__ Siret du signataire
- __ETAB_RSS__ Raison sociale du signataire
- __DEP__ Département signataire
- __REG__ Région signataire
- __ETAB_CODE_INSEE__ Code INSEE commune
- __ETAB_VILLE__ Ville
- __CODE_NAF2__ Code NAF 2008
- __CODE_NAF2_2__ Code NAF sur 88 postes (deux premiers caractères de la variable )CODE_NAF2)
- __CODE_NAF_TP__ Pseudo indicatrice entreprises  travaux publics vaut :     - TP                si travaux publics     - Autres         sinon
- __EFF_ENT__ Effectif de l'entreprise
- __EFF_ETAB__ Effectif de l'établissement

#### Données de demandes d'activité partielle

Données spécifiques aux demandes d'activité partielle.   

- __DATE_STATUT__ Date de création de la demande

- __TX_PC__ Taux de prise en charge

- __TX_PC_UNEDIC_DARES__ Taux de prise en charge pas l'Unédic

- __TX_PC_ETAT_DARES__ Taux de prise en charge par l'Etat

- __DATE_DEB__ Date de début de la période d'activité partielle, au format JJ/MM/AAAA

- __DATE_FIN__ Date de fin de la période d'activité partielle, au format JJ/MM/AAAA

- __HTA__ Nombre total d'heures autorisées. 

- __MTA__ Montant total autorisé.

- __EFF_AUTO__ Effectifs autorisés. 

- __MOTIF_RECOURS_SE__ Cause d'activité partielle. Cf table ci-dessous 
  
- __(PERIMETE_EFF) PERIMETRE_AP__ Périmètre du chômage (1 à 4). Cf table ci-dessous

- __RECOURS_ANTERIEUR__ Recours antérieurs au chômage (1 à 3) :    -  

- __AVIS_CE__ Avis du comité d’entreprise

##### Table des motifs de recours à l'activité partielle
|   Code | Libellé |
| ------ | ------- |
| 1 | Conjoncture économique.  | 
| 2 | Difficultés d’approvisionnement en matières premières ou en énergie  | 
| 3 | Sinistre ou intempéries de caractère exceptionnel  | 
| 4 | Transformation, restructuration ou modernisation des installations et des bâtiments  | 
| 5 | Autres circonstances exceptionnelles |

##### Table des périmètres du chômage.
|   Code | Libellé |
| ------ | ------- |
| 1 | Réduction horaire tout Ets   |
| 2 | Réduction horaire partie Ets |
| 3 | Fermeture tempor. Tout Ets   | 
| 4 | Fermeture tempor. Partie Ets | 

##### Table des codes de recours antérieurs au chômage
|   Code | Libellé |
| ------ | ------- |
| 1 | Aucun recours depuis 3 ans                                     | 
| 2 | Recours au chômage partiel au cours des 3 années précédentes   | 
| 3 | Non renseigné                                                  | 

#### Données de consommation d'activité partielle

- __S_HEURE_CONSOM_TOT__	Nombre total d'heures consommées
- __S_MONTANT_CONSOM_TOT__	Montant total consommé
- __S_EFF_CONSOM_TOT__	Effectifs consommés

### Table de correspondance entre compte administratif URSSAF et siret 

|                          |                               |
| ------------------------ | ----------------------------- |
| Source                   | URSSAF                        |
| Couverture               |                TODO           |
| Fréquence de mise-à-jour | Mensuellement                 |
| Délai des données        | En temps réel (parfois un mois de retard)       | 

- __Numéro de compte externe__ Compte administratif URSSAF
  
- __Etat du compte__ Compte ouvert (1) ou fermé (3) ?

- __Numéro siren__ Numéro Siren de l'entreprise

- __Numéro d'établissement__ Numéro Siret de l'établissement. Les numéros avec des Lettres sont des sirets provisoires. 

- __Date de création de l'établissement__  Date de création de l'établissement au format (A)AAMMJJ. (A)AA = AAAA - 1900. 

- __Date de disparition de l'établissement__ Date de disparition de l'établissement au format (A)AAMMJJ (cf date de création)

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


- __Compte__	Compte administratif URSSAF
- __Periode_debit__	Période en débit.	*A ne pas prendre en compte*
- __ecn__ Numéro écart négatif.
- __periode__ Période. Format AAXY, cf ci-dessus l'effectif pour l'explication du format.  
- __mer__	Cotisation mise en recouvrement, en euros.
- __enc_direct__	Cotisation encaissée directement, en euros.
- __cotis_due__	Cotisation due, I euros.	À utiliser pour calculer le montant moyen mensuel du : Somme cotisations dues / nb périodes


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

-   **Num\_Hist\_Ecn** Ordre des opérations pour un écart négatif donné. 

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

|                          |                               |
| ------------------------ | ----------------------------- |
| Source                   | URSSAF                        |
| Couverture               | Tous les délais               |
| Fréquence de mise-à-jour | Mensuellement                 |
| Délai des données        | Créations en temps réel       | 

- __Numero de compte externe__ Compte administratif URSSAF

- __Numéro de structure__ Le numéro de structure est l'identifiant d'un dossier contentieux

- __Date de création__ Date de création du délai. Format aaaa-mm-jj

- __Date d'échéance__ Date d'échéance du délai. Format aaaa-mm-jj

- __Durée délai__ Durée du délai en jours.

- __Dénomination premiére ligne__ Raison sociale de l'établissement.

- __Indic 6M__ Délai inférieur ou supérieur à 6 mois? Modalités INF et SUP.

- __année (  Date de création  )__ Année de création du délai.

- __Montant global de l'échéancier__ Montant global de l'échéancier, en euros.

- __Numéro de structure__ Champs en double, cf plus haut.

- __Code externe du stade__

- __Code externe de l'action__

### Données sur le procédures collectives

Nous avons utilisé les données fournies par Altares concernant les défaillances en Bourgogne Franche Comté (prestation payante). Comme cette base n'est pas disponible dans toutes les régions, ce seront les données de procédure collective fournies par l'URSSAF qui seront dorénavent utilisées. 

|                          |                                    |
| ------------------------ | -----------------------------      |
| Source                   | URSSAF                             |
| Couverture               | Toutes les procédures collectives  |
| Fréquence de mise-à-jour | Mensuellement                      |
| Délai des données        | Créations en temps réel ?          | 

- __Siret__ Siret de l'établissement
- __Siren__ Siren de l'entreprise
- __Dt_effet__ Date effet de la procédure collective au format JJMMMAAAA, par exemple 24FEB2014
- __Cat_v2__ ? TODO
- __Lib_actx_stdx__ Champs double: Nature procédure +  évènement. 

### Données sur les CCSF

- __Compte__ Compte administratif URSSAF
  
- __Date de traitement__ Date de début de la procédure CCSF au format (A)AAMMJJ, ou (A)AA = AAAA -1900

- __Code externe du stade__ TODO

- __Code externe de l'action__ TODO
