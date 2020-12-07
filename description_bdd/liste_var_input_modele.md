# Description des données Signaux faibles pour le futur modèle  

## Objectif de ce document

L'objectif est de présenter de manière plus détaillée les données utilisées dans l'algorithme Signaux faibles (jusqu'à récemment) et amenées à être utilisées dans le cadre du futur modèle DGFIP-Signaux faibles. 

## Récapitulatif des différentes sources de données 

Les données utilisées proviennent de plusieurs sources:

- **Données Sirene** Raison sociale, adresse, code APE, date de création etc.\
- **Données Altarès** Données de défaillance, permet la définition de l'objectif d'apprentissage
- **Données DIRECCTE** Autorisations et consommations d'activité partielle, recours à l'intérim, déclaration des mouvements de main-d'oeuvre
- **Données URSSAF** Montant des cotisations, montant des dettes (part patronale, part ouvrière), demandes de délais de paiement, demandes préalables à l'embauche
- **Données Banque de France** 6 ratios financiers
- **Données Diane** Bilans et comptes de résultats. Permet d'enrichir les données financières de la Banque de France

Dans la suite de ce document, les données Diane ne seront pas détaillées ici car elles se recoupent avec d'autres données plus riches qui vont bientôt arriver.  

## Données sirene

|                          |                                                                                   |
| ------------------------ | --------------------------------------------------------------------------------- |
| Source                   | [Géo-sirene](http://data.cquest.org/geo_sirene/), open source                     |
| Unité                    | siret                                                                             |
| Couverture siret         | Tout établissement actif                                                          |
| Fréquence de mise-à-jour | Source mise à jour quotidiennement mais intégration mensuelle (voire bimensuelle) |

Le fichier sirene est utilisé comme fichier de référence pour les
établissements actifs. On s'en sert pour la raison sociale, le
code naf, l'adresse (y compris région et
département qui permettent d'ouvrir les droits de consultation sur
le terrain). \\
\vfill
Il est possible d'intégrer pour l'algorithme également des données supplémentaires:
date de création de l'établissement, présence ou non
d'activité saisonnière.


## Données financières de la Banque de France

Elles consistent en 6 ratios financiers détaillées ci-dessous.

|                          |                                               |
| ------------------------ | --------------------------------------------- |
| Source                   | Banque de France                              |
| Unité                    | siren                                         |
| Disponibilité            | 2014-2018                                     |
| Couverture siren         | 70% en 2015                                   |
| Fréquence de mise-à-jour | annuelle                                      |
| Délai des données        | Exercice n obtenu en septembre de l'année n+1 |


- **POIDS_FRNG** Poids du fonds de roulement net global sur le chiffre d'affaire. Exprimé en \%.

  Intitulé dans la base: "poids_frng".

- **TX_MARGE** Taux de marge, rapport de l'excédent brut d'exploitation (EBE) sur la valeur ajoutée. Exprimé en \%.
  _100\*EBE / valeur ajoutee_

  Intitulé dans la base: "taux_marge".

- **DELAI_FRS** Délai estimé de paiement des fournisseurs. Exprimé en jours.
  _360 \* dettes fournisseurs / achats HT_

  Intitulé dans la base: "delai_fournisseur".

- **POIDS_DFISC_SOC** Poids des dettes fiscales et sociales, par rapport à la valeur ajoutée. Exprimé en \%.
  _100 \* dettes fiscales et sociales / Valeur ajoutee_

  Intitulé dans la base: "dette_fiscale"

- **POIDS_FIN_CT** Poids du financement court terme. Exprimé en \%.
  _100 \* concours bancaires courants / chiffre d'affaires HT_

  Intitulé dans la base: "financier_court_terme"

- **POIDS_FRAIS_FIN** Poids des frais financiers, sur l'excedent brut d'exploitation corrigé des produits et charges hors exploitation. Exprimé en \%.
  _100 \* frais financiers / (EBE + Produits hors expl. - charges hors expl.)_

  Intitulé dans la base: "frais_financier".


## Données sur l'activité partielle

Deux fichiers: demandes d'activité partielle, et consommations d'activité partielles

|                              |                                            |
| ---------------------------- | ------------------------------------------ |
| Source                       | DGEFP                                      |
| Unité                        | siret                                      |
| Couverture                   | Toutes les demandes et consommations       |
| Fréquence de mise-à-jour     | Mensuelle, export base complète            |
| Délai des données (conso)    | Mois précédent, à quelques exceptions près |
| Délai des données (demandes) | Temps réel                                 |

HTA : Nombre total d'heure d'activité partiellle autorisées (intitulé dans la base apart_heures_autorisees)
S_HEURE_CONSOM_TOT: Nombre total d'heures consommées (intitulé dans la base apart_heures_consommees)


## Données sur l'effectif

|                          |                               |
| ------------------------ | ----------------------------- |
| Source                   | URSSAF                        |
| Couverture               | TODO                          |
| Fréquence de mise-à-jour | Variable, tous les 3 à 6 mois |
| Délai des données        | 0 à 6 mois selon mise-à-jour  |

- **effAAAAXY** effectif du mois pour un établissement donné AAAAXY. AAAA = année. X = trimestre. Y = N° du mois dans le trimestre (ex: 201631 vaut juillet 2016) (variable intitulée effectif dans la base).
A partir de cette information, l'effectif au niveau de l'entreprise est également calculé (intitulée effectif_ent dans la base).

## Données sur les cotisations sociales et les débits

Deux fichiers: cotisations, et débits sur les cotisations sociales

|                                 |                                         |
| ------------------------------- | --------------------------------------- |
| Source                          | URSSAF                                  |
| Couverture                      | TODO                                    |
| Fréquence de mise-à-jour        | mensuelle (autour du 20 de chaque mois) |
| Délai des données (cotisations) | cotisations du mois précédent           |
| Délai des données (débits)      | débits sur les cot. du mois précédent   |

### Fichier sur les cotisations

- **enc_direct** Cotisation encaissée directement, en euros.
- **cotis_due** Cotisation due, I euros. Elle est utilisée pour calculer **cotisation_moy_12mois** : montant moyen (moyenne glissante sur les 12 derniers mois) de la somme des cotisations sociales dues (part patronale et ouvrière). 

#### Fichiers sur les débits

- **Mt_PO** Montant des débits sur la part ouvrières **en centimes**. Sont
  exclues les pénalités et les majorations de retard (intitulée montant_part_ouvriere dans la base)

- **Mt_PP** Montant des débits sur la part patronale **en centimes**. Sont
  exclues les pénalités et les majorations de retard (intitulée montant_part_patronale dans la base). 

--> A partir de ces 2 variables est calculée **ratio_dette** : (montant_part_patronale + montant_part_ouvrière)/cotisation_moy_12mois. Cela mesure mois par mois la dette auprès de l'URSSAF. 

- **duree_delai** : durée de délai en jours. Un délai correspond à une période de report de paiement des charges sociales acceptée par l'URSSAF. 

-**montant_echeancier**: volume en euros qui bénéficie d'un délai. 

-**delai**: nombre de mois restants du délai accordé par l'URSSAF. 



