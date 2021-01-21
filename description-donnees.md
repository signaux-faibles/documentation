# Description des données

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Préambule](#pr%C3%A9ambule)
- [Périmètre des données](#p%C3%A9rim%C3%A8tre-des-donn%C3%A9es)
  - [Nombre d'établissements](#nombre-d%C3%A9tablissements)
  - [Taux de couverture des données](#taux-de-couverture-des-donn%C3%A9es)
- [Données importées](#donn%C3%A9es-import%C3%A9es)
  - [Données sirene](#donn%C3%A9es-sirene)
  - [Données financières de la Banque de France](#donn%C3%A9es-financi%C3%A8res-de-la-banque-de-france)
  - [Données financières issues des bilans déposés au greffe de tribunaux de commerce](#donn%C3%A9es-financi%C3%A8res-issues-des-bilans-d%C3%A9pos%C3%A9s-au-greffe-de-tribunaux-de-commerce)
    - [Structure et liquidité](#structure-et-liquidit%C3%A9)
    - [Gestion](#gestion)
    - [Productivité et rentabilité](#productivit%C3%A9-et-rentabilit%C3%A9)
    - [Marge et valeur ajoutée](#marge-et-valeur-ajout%C3%A9e)
    - [Compte de résultat](#compte-de-r%C3%A9sultat)
  - [Données sur l'activité partielle](#donn%C3%A9es-sur-lactivit%C3%A9-partielle)
    - [Données de demandes d'activité partielle](#donn%C3%A9es-de-demandes-dactivit%C3%A9-partielle)
      - [Table des motifs de recours à l'activité partielle](#table-des-motifs-de-recours-%C3%A0-lactivit%C3%A9-partielle)
      - [Table des périmètres du chômage](#table-des-p%C3%A9rim%C3%A8tres-du-ch%C3%B4mage)
      - [Table des recours antérieurs au chômage](#table-des-recours-ant%C3%A9rieurs-au-ch%C3%B4mage)
      - [Table des avis du CE](#table-des-avis-du-ce)
    - [Données de consommations d'activité partielle](#donn%C3%A9es-de-consommations-dactivit%C3%A9-partielle)
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

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Préambule

Ce dossier technique décrite les données utilisées dans le projet signaux-faibles. Avec l'évolution du projet, celles-ci vont naturellement être amenées à évoluer.

Les données utilisées proviennent de plusieurs sources:

- **Données Sirene** Raison sociale, adresse, code APE, date de création etc.\
- **Données Altarès** Données de défaillance, permet la définition de l'objectif d'apprentissage
- **Données DIRECCTE** Autorisations et consommations d'activité partielle, recours à l'intérim, déclaration des mouvements de main-d'oeuvre
- **Données URSSAF** Montant des cotisations, montant des dettes (part patronale, part ouvrière), demandes de délais de paiement, demandes préalables à l'embauche
- **Données Banque de France** 6 ratios financiers
- **Données Diane** Bilans et comptes de résultats. Permet d'enrichir les données financières de la Banque de France

Les sections ci-dessous détaillent la nature des données importées, et la nature des traitements qui leurs sont appliqués.

## Périmètre des données

### Nombre d'établissements

L'algorithme tourne désormais sur la France entière. L'unité de base est
l'établissement. Les établissements de moins de 10 salariés ou dont
l'effectif est inconnu ne sont pas intégrés à l'entraînement de
l'algorithme.

Il en résulte un stock d'environ 350000 établissements issues de 250000 entreprises.
Les établissements éventuellement absents de la base sirène (en cas de base sirène obsolète par exemple) sont filtrés en post-traitement.

### Taux de couverture des données

TODO
Rédaction en cours.

## Données importées

### Données sirene

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
On intègre pour l'algorithme également des données supplémentaires:
date de création de l'établissement, présence ou non
d'activité saisonnière.

La description détaillée des variables du fichier Sirène est téléchargeable depuis le site Internet de la [Base Sirene des entreprises et de leurs établissements (SIREN, SIRET) - data.gouv.fr](https://www.data.gouv.fr/en/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/#_).

### Données financières de la Banque de France

Les données financières de la Banque de France couvrent à ce jour uniquement la région Bourgogne Franche Comté. Elles consistent en 6 ratios financiers détaillées ci-dessous.

|                          |                                               |
| ------------------------ | --------------------------------------------- |
| Source                   | Banque de France                              |
| Unité                    | siren                                         |
| Disponibilité            | 2014-2018                                     |
| Couverture siren         | 70% en 2015                                   |
| Fréquence de mise-à-jour | annuelle                                      |
| Délai des données        | Exercice n obtenu en septembre de l'année n+1 |

- **SIREN** Siren de l'entreprise

- **ANNEE** Année de l'exercice.

  Intitulé dans la base: "annee_bdf".

- **ARRETE_BILAN** Date de clôture de l'exercice. Format mm/jj/aaaa

  Intitulé dans la base: "arrete_bilan_bdf".

- **DENOM** Raison sociale de l'entreprise.

  Intitulé dans la base: "raison_sociale".

- **SECTEUR** Secteur d'activité.

  Intitulé dans la base: "secteur".

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

### Données financières issues des bilans déposés au greffe de tribunaux de commerce

|                          |                                               |
| ------------------------ | --------------------------------------------- |
| Source                   | [Diane](https://diane.bvdinfo.com/)           |
| Unité                    | siren                                         |
| Disponibilité            | 2014-2018                                     |
| Couverture siren         | 76% en 2015, 61% en 2016                      |
| Fréquence de mise-à-jour | Annuelle                                      |
| Délai des données        | Exercice n obtenu en septembre de l'année n+1 |

- **Annee** Année de l'exercice
- **NomEntreprise** Raison sociale
- **NumeroSiren** Numéro siren
- **StatutJuridique** Statut juridique
- **ProcedureCollective** Présence d'une procédure collective en cours
- **EffectifConsolide** Effectif consolidé à l'entreprise
- **DetteFiscaleEtSociale** Dette fiscale et sociale
- **FraisDeRetD** Frais de Recherche et Développement
- **ConcesBrevEtDroitsSim** Concessions, brevets, et droits similaires
- **NotePreface** Note Diane "Préface" entre 0 et 10.
- **NombreEtabSecondaire** Nombre d'établissements secondaires de l'entreprise, en plus du siège.
- **NombreFiliale** Nombre de filiales de l'entreprise. Dans la base de données des liens capitalistiques, le concept de filiale ne fait aucune référence au pourcentage d’appartenance entre le parent et la fille. Dans ce sens, si l'entreprise A est enregistrée comme ayant des intérêts dans l'entreprise B avec un très petit, ou même un pourcentage de participation inconnu, l'entreprise B sera considérée filiale de l'entreprise A.
- **TailleCompoGroupe** Nombre d'entreprises dans le groupe (groupe défini par les liens capitalistique d'au moins 50,01\%)
- **ArreteBilan** Date d'arrêté du bilan
- **NombreMois** Durée de l'exercice en mois.
- **ConcoursBancaireCourant** Concours bancaires courants. (Pour recalculer les frais financiers court terme de la Banque de France)

#### Structure et liquidité

- **EquilibreFinancier** Équilibre financier.  
  _Ressources durables / Emplois stables_

- **IndependanceFinanciere** Indépendance financière. Exprimé en \%.  
  _Fonds propres / Ressources durables \* 100_

- **Endettement** Endettement. Exprimé en \%.  
  _Dettes de caractère financier / Ressources durables \* 100_

- **AutonomieFinanciere** Autonomie financière. Exprimé en \%.  
  _Fonds propres / Total bilan \* 100_

- **DegreImmoCorporelle** Degré d'amortissement des immobilisations corporelles. Exprimé en \%.  
  _Amortissements des immobilisations corporelles / Immobilisation corporelles brutes \* 100_

- **FinancementActifCirculant** Financement de l'actif circulant net.  
  _Fonds de roulement net global / Actif circulant net_

- **LiquiditeGenerale** Liquidité générale.  
  _Actif circulant net / Dettes à court terme_

- **LiquiditeReduite** Liquidité réduite.  
  _Actif circulant net hors stocks / Dettes à court terme_

#### Gestion

- **RotationStocks** Rotation des stocks. Exprimé en jours.  
  _Stock / Chiffre d'affaires net \* 360_  
  Selon la nomenclature NAF Rév. 2 pour les secteurs d'activité 45, 46, 47, 95 (sauf 9511Z) ainsi que pour les codes d'activités 2319Z, 3831Z et 3832Z :
  _Marchandises / (Achats de marchandises + Variation de stock) \* 360_

- **CreditClient** Crédit clients. Exprimé en jours.  
  _(Clients + Effets portés à l'escompte et non échus) / Chiffre d'affaires TTC \* 360_

- **CreditFournisseur** Crédit fournisseurs. Exprimé en jours.  
  _Fournisseurs / Achats TTC \* 360_

- **CAparEffectif** Chiffre d'affaire par effectif. Exprimé en k€/emploi.  
  _Chiffre d'affaires net / Effectif \* 1000_

- **TauxInteretFinancier** Taux d'intérêt financier. Exprimé en \%.  
  _Intérêts / Chiffre d'affaires net \* 100_

- **TauxInteretSurCA** Intérêts sur chiffre d'affaire. Exprimé en \%.  
  _Total des charges financières / Chiffre d'affaires net \* 100_

- **EndettementGlobal** Endettement global. Exprimé en jours.  
  _(Dettes + Effets portés à l'escompte et non échus) / Chiffre d'affaires net \* 360_

- **TauxEndettement** Taux d'endettement. Exprimé en \%.  
  _Dettes de caractère financier / (Capitaux propres + autres fonds propres) \* 100_

- **CapaciteRemboursement** Capacité de remboursement.  
  _Dettes de caractère financier / Capacité d'autofinancement avant répartition_

- **CapaciteAutofinancement** Capacité d'autofinancement. Exprimé en \%.  
  _Capacité d'autofinancement avant répartition / (Chiffre d'affaires net + Subvention d'exploitation) \* 100_

- **CouvertureCaFdr** Couverture du chiffre d'affaire par le fonds de roulement. Exprimé en jours.  
  _Fonds de roulement net global / Chiffre d'affaires net \* 360_

- **CouvertureCaBesoinFdr** Couverture du chiffre d'affaire par le besoin en fonds de roulement. Exprimé en jours.  
  _Besoins en fonds de roulement / Chiffre d'affaires net \* 360_

- **PoidsBFRExploitation** Poids des besoins en fonds de roulement d'exploitation. Exprimé en \%.  
  _Besoins en fonds de roulement d'exploitation / Chiffre d'affaires net \* 100_

- **Exportation** Exportation. Exprimé en \%.  
  _(Chiffre d'affaires net - Chiffre d'affaires net en France) / Chiffre d'affaires net \* 100_

#### Productivité et rentabilité

- **EfficaciteEconomique** Efficacité économique. Exprimé en k€/emploi.  
  _Valeur ajoutée / Effectif \* 1000_

- **ProductivitePotentielProduction** Productivité du potentiel de production.  
  _Valeur ajoutée / Immobilisations corporelles et incorporelles brutes_

- **ProductiviteCapitalFinancier** Productivtié du capital financier.  
  _Valeur ajoutée / Actif circulant net + Effets portés à l'escompte et non échus_

- **ProductiviteCapitalInvesti** Productivité du capital investi.  
  _Valeur ajoutée / Total de l'actif + Effets portés à l'escompte et non échus_

- **TauxDInvestissementProductif** Taux d'investissement productif. Exprimé en \%.  
  _Immobilisations à valeur d'acquisition / Valeur ajoutée \* 100_

- **RentabiliteEconomique** Rentabilité économique. Exprimé en \%.  
  _Excédent brut d'exploitation / Chiffre d'affaires net + Subventions d'exploitation \* 100_

- **Performance** Performance. Exprimé en \%.  
  _Résultat courant avant impôt / Chiffre d'affaires net + Subventions d'exploitation \* 100_

- **RendementBrutFondsPropres** Rendement brut des fonds propres. Exprimé en \%.  
  _Résultat courant avant impôt / Fonds propres nets \* 100_

- **RentabiliteNette** Rentabilité nette. Exprimé en \%.  
  _Bénéfice ou perte / Chiffre d'affaires net + Subventions d'exploitation \* 100_

- **RendementCapitauxPropres** Rendement des capitaux propres. Exprimé en \%.  
  _Bénéfice ou perte / Capitaux propres nets \* 100_

- **RendementRessourcesDurables** Rendement des ressources durables. Exprimé en \%.  
  _Résultat courant avant impôts + Intérêts et charges assimilées / Ressources durables nettes \* 100_

#### Marge et valeur ajoutée

- **TauxMargeCommerciale** Taux de marge commerciale. Exprimé en \%.  
  _Marge commerciale / Vente de marchandises \* 100_

- **TauxValeurAjoutee** Taux de valeur ajoutée. Exprimé en \%.  
  _Valeur ajoutée / Chiffre d'affaires net \* 100_

- **PartSalaries** Part des salariés. Exprimé en \%.  
  _(Charges de personnel + Participation des salariés aux résultats) / Valeur ajoutée \* 100_

- **PartEtat** Part de l'État. Exprimé en \%.  
  _Impôts et taxes / Valeur ajoutée \* 100_

- **PartPreteur** Part des prêteurs. Exprimé en \%.  
  _Intérêts / Valeur ajoutée \* 100_

- **PartAutofinancement** Part de l'autofinancement. Exprimé en \%.  
  _Capacité d'autofinancement avant répartition / Valeur ajoutée \* 100_

#### Compte de résultat

- **CA** Chiffre d'affaires
- **CAExportation** Chiffre d'affaires à l'exportation
- **AchatMarchandises** Achats de marchandises
- **AchatMatieresPremieres** Achats de matières premières et autres approvisionnement.
- **Production** Production de l'exercice.
- **MargeCommerciale** Marge commerciale.
- **Consommation** Consommation de l'exercice.
- **AutresAchatsChargesExternes** Autres achats et charges externes.
- **ValeurAjoutee** Valeur ajoutée.
- **ChargePersonnel** Charges de personnel.
- **ImpotsTaxes** Impôts, taxes et versements assimilés.
- **SubventionsDExploitation** Subventions d'exploitation.
- **ExcedentBrutDExploitation** Excédent brut d'exploitation.
- **AutresProduitsChargesReprises** Autres produits, charges et reprises.
- **DotationAmortissement** Dotation d'exploitation aux amortissements et aux provisions.
- **ResultatExpl** Résultat d'exploitation.
- **OperationsCommun** Opérations en commun.
- **ProduitsFinanciers** Produits financiers.
- **ChargesFinancieres** Charges financières.
- **Interets** Intérêts et charges assimilées.
- **ResultatAvantImpot** Résultat courant avant impôts.
- **ProduitExceptionnel** Produits exceptionnels.
- **ChargeExceptionnelle** Charges exceptionnelles.
- **ParticipationSalaries** Participation des salariés aux résultats.
- **ImpotBenefice** Impôts sur les bénéfices et impôts différés.
- **BeneficeOuPerte** Bénéfice ou perte.

### Données sur l'activité partielle

Deux fichiers: demandes d'activité partielle, et consommations d'activité partielles

|                              |                                            |
| ---------------------------- | ------------------------------------------ |
| Source                       | DGEFP                                      |
| Unité                        | siret                                      |
| Couverture                   | Toutes les demandes et consommations       |
| Fréquence de mise-à-jour     | Mensuelle, export base complète            |
| Délai des données (conso)    | Mois précédent, à quelques exceptions près |
| Délai des données (demandes) | Temps réel                                 |

Données communes :

- **ID_DA** Numéro de la demande (11 caractères principalement des chiffres)
- **ETAB_SIRET** Numéro de SIRET de l'établissement (14 chiffres)
- **CODE_NAF2_2** Division sur 88 postes (2 premiers caractères de la variable CODE_NAF2, par exemple : `25`)
- **EFF_ENT** Effectif de l'entreprise (nombre entier)
- **EFF_ETAB** Effectif de l'établissement (nombre entier)
- **SOURCE** Source de la donnée (`SINAPSE` ou `EXTRANET`)
- **CODENAF2** et/ou **CODE_NAF2** Code NAF sur 5 positions (en majuscules, par exemple : `2573A`)
- **CODE_NAF_21** Section A...U sur 21 postes
- **CODE_NAF_TP** Pseudo indicatrice entreprises travaux publics vaut : `TP` si travaux publics, `AUTRES` sinon
- **EFF_ENT_TR_TDB** Effectif de l'entreprise par tranche (découpage Dares) : `1. Moins de 20 salariés`, `2. Entre 20 et 49 salariés`, `3. Entre 50 et 249 salariés`, `4. Entre 250 et +`

#### Données de demandes d'activité partielle

Données spécifiques aux demandes d'activité partielle :

- **EFF_ENT_TR** Effectif de l'entreprise par tranche (découpage DGEFP) : `1. Moins de 20 salariés`, `2. Entre 20 et 49 salariés`, `3. Entre 50 et 249 salariés`, `4. Entre 250 et 499 salariés`, `5. Entre 500 et 999 salariés`, `6. Plus de 1000 salariés`
- **ETAB_RSS** Dénomination (raison sociale) de l'établissement
- **ETAB_CODE_INSEE** Code INSEE de la commune de l'établissement
- **ETAB_VILLE** Ville de l'établissement
- **DATE_STATUT** Date du statut - création ou mise à jour de la demande - au format JJ/MM/AA
- **TX_PC** Taux horaire d'indemnisation (nombre avec 2 chiffres après la virgule)
- **TX_PC_ETAT_DARES** Taux de prise en charge par l'Etat (nombre avec 2 chiffres après la virgule)
- **TX_PC_UNEDIC_DARES** Taux de prise en charge pas l'Unédic (nombre avec 2 chiffres après la virgule)
- **DATE_DEB** Date de début de la période de chômage déterminée au format JJ/MM/AA
- **DATE_FIN** Date de fin de la période de chômage déterminée au format JJ/MM/AA
- **HTA** Nombre total d'heures autorisées (nombre décimal avec point)
- **MTA** Montant total autorisé (nombre décimal avec virgule)
- **EFF_AUTO** Effectifs autorisés (nombre entier)
- **PROD_HTA_EFF** ?
- **MOTIF_RECOURS_SE** Motif de recours à l'activité partielle (de `1` à `5`)
- **PERIMETRE_AP** Périmètre du chômage (de `1` à `4`)
- **RECOURS_ANTERIEUR** Activité partielle au cours des 36 derniers mois (3 ans) avant la demande (de `1` à `3`)
- **AVIS_CE** Avis du CE (de `0` à `3`)
- **S_HEURE_CONSOM_TOT** Nombre total d'heures consommées (nombre décimal avec point)
- **S_MONTANT_CONSOM_TOT** Montant total consommé (nombre décimal avec virgule)
- **S_EFF_CONSOM_TOT** (nombre entier)
- **CPT** ?
- **Date_Statut_Annee** Année du statut au format AAAA
- **Date_Statut_Mois** MOis du statut au format M
- **Date_Statut_Annee_Mois** Année et mois du statut au format AAAA_MM
- **Date_Statut_Annee_Trim** Année et trimestre du statut au format AAAA_T

##### Table des motifs de recours à l'activité partielle

| Code | Libellé                                                                             |
| ---- | ----------------------------------------------------------------------------------- |
| 1    | Conjoncture économique.                                                             |
| 2    | Difficultés d’approvisionnement en matières premières ou en énergie                 |
| 3    | Sinistre ou intempéries de caractère exceptionnel                                   |
| 4    | Transformation, restructuration ou modernisation des installations et des bâtiments |
| 5    | Autres circonstances exceptionnelles                                                |

##### Table des périmètres du chômage

| Code | Libellé                      |
| ---- | ---------------------------- |
| 1    | Réduction horaire tout Ets   |
| 2    | Réduction horaire partie Ets |
| 3    | Fermeture tempor. Tout Ets   |
| 4    | Fermeture tempor. Partie Ets |

##### Table des recours antérieurs au chômage

| Code | Libellé                                                      |
| ---- | ------------------------------------------------------------ |
| 1    | Aucun recours depuis 3 ans                                   |
| 2    | Recours au chômage partiel au cours des 3 années précédentes |
| 3    | Non renseigné                                                |

##### Table des avis du CE

| Code | Libellé       |
| ---- | ------------- |
| 0    | Non renseigné |
| 1    | Favorable     |
| 2    | Défavorable   |
| 3    | Sans objet    |

#### Données de consommations d'activité partielle

- **DEP** Code département sur 3 chiffres (par exemple : `073`)
- **REG** Code région sur 2 chiffres (par exemple : `23`)
- **MOIS** Mois au format MM/AAAA
- **HEURES** Heures consommées (chômées) dans le mois (nombre décimal avec point)
- **MONTANTS** Montants consommés dans le mois (nombre décimal avec virgule)
- **EFFECTIFS** Nombre de salariés en activité partielle dans le mois (nombre entier)
- **Date_Payement_Annee** Année de paiement au format AAAA
- **Date_Payement_Mois** Mois de paiement au format M
- **Date_Payement_Annee_Mois** Année et mois de paiement au format AAAA_MM
- **Date_Payement_Annee_Trim** Année et trimestre de paiement au format AAAA_T
- **Naf5_code** Code grand secteur
- **Naf5_libelle** Libellé du grand secteur
- **Naf38_code** Code NACE 38
- **Naf38_libelle** Libellé NACE 38

Les consommations affichées sur le frontend sont, depuis la mise en place de la nouvelle version de datapi, les consommations mensuelles issues des fichiers spécifiques livrés par la DGEFP.  
Le valeur indiquée est le nombre d'équivalents temps plein correspondant à l'activité partielle (calculé à partir du volume d'heure mensuel **HEURES** sur la base d'une durée légale de 151,67 h).  
Dans le cas où figurent différentes consommations mensuelles rattachées à différentes demandes concomitantes alors la valeur correspond à la somme des consommations.

### Table de correspondance entre compte administratif URSSAF et siret

|                          |                                           |
| ------------------------ | ----------------------------------------- |
| Source                   | URSSAF                                    |
| Couverture               | TODO                                      |
| Fréquence de mise-à-jour | Mensuellement                             |
| Délai des données        | En temps réel (parfois un mois de retard) |

- **Numéro de compte externe** Compte administratif URSSAF

- **Etat du compte** Compte ouvert (1) ou fermé (3) ?

- **Numéro siren** Numéro Siren de l'entreprise

- **Numéro d'établissement** Numéro Siret de l'établissement. Les numéros avec des Lettres sont des sirets provisoires.

- **Date de création de l'établissement** Date de création de l'établissement au format (A)AAMMJJ. (A)AA = AAAA - 1900.

- **Date de disparition de l'établissement** Date de disparition de l'établissement au format (A)AAMMJJ (cf date de création)

### Données sur l'effectif

|                          |                               |
| ------------------------ | ----------------------------- |
| Source                   | URSSAF                        |
| Couverture               | TODO                          |
| Fréquence de mise-à-jour | Variable, tous les 3 à 6 mois |
| Délai des données        | 0 à 6 mois selon mise-à-jour  |

- **Siret** Siret de l'établissement

- **Compte** Compte administratif URSSAF

- **Rais_soc** Raison sociale

- **Ur_emet** Urssaf en charge de la gestion du compte

- **Dep** Département

- **effAAAAXY** effectif du mois AAAAXY. AAAA = année. X = trimestre. Y = N° du mois dans le trimestre (ex: 201631 vaut juillet 2016)

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

- **Compte** Compte administratif URSSAF
- **Periode_debit** Période en débit. _A ne pas prendre en compte_
- **ecn** Numéro écart négatif.
- **periode** Période. Format AAXY, cf ci-dessus l'effectif pour l'explication du format.
- **mer** Cotisation mise en recouvrement, en euros.
- **enc_direct** Cotisation encaissée directement, en euros.
- **cotis_due** Cotisation due, I euros. À utiliser pour calculer le montant moyen mensuel du : Somme cotisations dues / nb périodes

#### Fichiers sur les débits

- **num_cpte** Compte administratif URSSAF

- **Siren** Siren de l'entreprise

- **Dt_immat** Date d'immatriculation du compte à l'Urssaf

- **Etat_cpte** Code état du compte. Cf la table ci-dessous.

- **Cd_pro_col** Code qui indique si le compte fait l'objet d'une procédure
  collective. Cf la table ci-dessous.

- **Periode** Période au format AAAAXY. Cf effectif pour l'explication.

- **Num_Ecn** L'écart négatif (ecn) correspond à une période en débit. Pour
  une même période, plusieurs débits peuvent être créés. On leur attribue un
  numéro d'ordre. Par exemple, 101, 201, 301 etc.; ou 101, 102, 201 etc.
  correspondent respectivement au 1er, 2ème et 3ème ecn de la période considérée.

- **Num_Hist_Ecn** Ordre des opérations pour un écart négatif donné.

- **Dt_trt_ecn** Date de comptabilisation de l'évènement (mise en
  recouvrement, paiement etc..). Format (A)AAMMJJ, ou (A)AA correspond à l'année
  à laquelle a été soustrait 1900. Exemple: 1160318 vaut 18 mars 2016,
  990612 vaut 12 juin 1999.

- **Mt_PO** Montant des débits sur la part ouvrières **en centimes**. Sont
  exclues les pénalités et les majorations de retard.

- **Mt_PP** Montant des débits sur la part patronale **en centimes**. Sont
  exclues les pénalités et les majorations de retard.

- **Cd_op_ecn** Code opération historique de l'écart négatif. Cf table
  ci-dessous.

- **Motif_ecn** Code motif de l'écart négatif. Cf table ci-dessous

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

|                          |                         |
| ------------------------ | ----------------------- |
| Source                   | URSSAF                  |
| Couverture               | Tous les délais         |
| Fréquence de mise-à-jour | Mensuellement           |
| Délai des données        | Créations en temps réel |

- **Numero de compte externe** Compte administratif URSSAF

- **Numéro de structure** Le numéro de structure est l'identifiant d'un dossier contentieux

- **Date de création** Date de création du délai. Format aaaa-mm-jj

- **Date d'échéance** Date d'échéance du délai. Format aaaa-mm-jj

- **Durée délai** Durée du délai en jours.

- **Dénomination premiére ligne** Raison sociale de l'établissement.

- **Indic 6M** Délai inférieur ou supérieur à 6 mois? Modalités INF et SUP.

- **année ( Date de création )** Année de création du délai.

- **Montant global de l'échéancier** Montant global de l'échéancier, en euros.

- **Numéro de structure** Champs en double, cf plus haut.

- **Code externe du stade**

- **Code externe de l'action**

### Données sur le procédures collectives

Nous avons utilisé les données fournies par Altares concernant les défaillances en Bourgogne Franche Comté (prestation payante). Comme cette base n'est pas disponible dans toutes les régions, ce seront les données de procédure collective fournies par l'URSSAF qui seront dorénavent utilisées.

|                          |                                   |
| ------------------------ | --------------------------------- |
| Source                   | URSSAF                            |
| Couverture               | Toutes les procédures collectives |
| Fréquence de mise-à-jour | Mensuellement                     |
| Délai des données        | Créations en temps réel ?         |

- **Siret** Siret de l'établissement
- **Siren** Siren de l'entreprise
- **Dt_effet** Date effet de la procédure collective au format JJMMMAAAA, par exemple 24FEB2014
- **Cat_v2** ? TODO
- **Lib_actx_stdx** Champs double: Nature procédure + évènement.

### Données sur les CCSF

- **Compte** Compte administratif URSSAF

- **Date de traitement** Date de début de la procédure CCSF au format (A)AAMMJJ, ou (A)AA = AAAA -1900

- **Code externe du stade** TODO

- **Code externe de l'action** TODO
