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

La description détaillée des variables du fichier Sirène est disponible [ici](https://static.data.gouv.fr/resources/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret-page-en-cours-de-construction/20181001-193247/description-fichier-stocketablissement.pdf).

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

- **ANNEE** Année de l'exercice

- **ARRETE_BILAN** Date de clôture de l'exercice. Format mm/jj/aaaa

- **DENOM** Raison sociale de l'entreprise

- **SECTEUR** Secteur d'activité
- **POIDS_FRNG** Poids du fonds de roulement net global sur le chiffre d'affaire. Exprimé en \%.

- **TX_MARGE** Taux de marge, rapport de l'excédent brut d'exploitation (EBE) sur la valeur ajoutée. Exprimé en \%.
  _100\*EBE / valeur ajoutee_

- **DELAI_FRS** Délai estimé de paiement des fournisseurs. Exprimé en jours.
  _360 \* dettes fournisseurs / achats HT_

- **POIDS_DFISC_SOC** Poids des dettes fiscales et sociales, par rapport à la valeur ajoutée. Exprimé en \%.
  _100 \* dettes fiscales et sociales / Valeur ajoutee_

- **POIDS_FIN_CT** Poids du financement court terme. Exprimé en \%.
  _100 \* concours bancaires courants / chiffre d'affaires HT_

- **POIDS_FRAIS_FIN** Poids des frais financiers, sur l'excedent brut d'exploitation corrigé des produits et charges hors exploitation. Exprimé en \%.
  _100 \* frais financiers / (EBE + Produits hors expl. - charges hors expl.)_

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
- **IndependanceFinanciere** Indépendance financière.
- **Endettement** Endettement.
- **AutonomieFinanciere** Autonomie financière.
- **DegreImmoCorporelle** Degré d'amortissement des immobilisations corporelles
- **FinancementActifCirculant** Financement de l'actif circulant net.
- **LiquiditeGenerale** Liquidité générale.
- **LiquiditeReduite** Liquidité réduite.

#### Gestion

- **RotationStocks** Rotation des stocks (en jours).
- **CreditClient** Crédit clients
- **CreditFournisseur** Crédit fournisseurs
- **CAparEffectif** Chiffre d'affaire par effectif (k€/personne)
- **TauxInteretFinancier** Taux d'intérêt financier.
- **TauxInteretSurCA** Intérêts sur chiffre d'affaire.
- **EndettementGlobal** Endettement global
- **TauxEndettement** Taux d'endettement.
- **CapaciteRemboursement** Capacité de remboursement.
- **CapaciteAutofinancement** Capacité d'autofinancement.
- **CouvertureCaFdr** Couverture du chiffre d'affaire par le fonds de roulement.
- **CouvertureCaBesoinFdr** Couverture du chiffre d'affaire par le besoin en fonds de roulement.
- **PoidsBFRExploitation** Poids des besoins en fonds de roulement d'exploitation.
- **Exportation** Exportation (%)

#### Productivité et rentabilité

- **EfficaciteEconomique** Efficacité économique (k€/personne)
- **ProductivitePotentielProduction** Productivité du potentiel de production
- **ProductiviteCapitalFinancier** Productivtié du capital financier.
- **ProductiviteCapitalInvesti** Productivité du capital investi.
- **TauxDInvestissementProductif** Taux d'investissement productif.
- **RentabiliteEconomique** Rentabilité économique.
- **Performance** Performance.
- **RendementBrutFondsPropres** Rendement brut des fonds propres.
- **RentabiliteNette** Rentabilité nette.
- **RendementCapitauxPropres** Rendement des capitaux propres.
- **RendementRessourcesDurables** Rendement des ressources durables.

#### Marge et valeur ajoutée

- **TauxMargeCommerciale** Taux de marge commerciale.
- **TauxValeurAjoutee** Taux de valeur ajoutée.
- **PartSalaries** Part des salariés.
- **PartEtat** Part de l'État.
- **PartPreteur** Part des prêteurs.
- **PartAutofinancement** Part de l'autofinancement.

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

- **ID_DA** N° de la demande
- **ETAB_SIRET** Siret du signataire
- **ETAB_RSS** Raison sociale du signataire
- **DEP** Département signataire
- **REG** Région signataire
- **ETAB_CODE_INSEE** Code INSEE commune
- **ETAB_VILLE** Ville
- **CODE_NAF2** Code NAF 2008
- **CODE_NAF2_2** Code NAF sur 88 postes (deux premiers caractères de la variable )CODE_NAF2)
- **CODE_NAF_TP** Pseudo indicatrice entreprises travaux publics vaut : - TP si travaux publics - Autres sinon
- **EFF_ENT** Effectif de l'entreprise
- **EFF_ETAB** Effectif de l'établissement

#### Données de demandes d'activité partielle

Données spécifiques aux demandes d'activité partielle.

- **DATE_STATUT** Date de création de la demande

- **TX_PC** Taux de prise en charge

- **TX_PC_UNEDIC_DARES** Taux de prise en charge pas l'Unédic

- **TX_PC_ETAT_DARES** Taux de prise en charge par l'Etat

- **DATE_DEB** Date de début de la période d'activité partielle, au format JJ/MM/AAAA

- **DATE_FIN** Date de fin de la période d'activité partielle, au format JJ/MM/AAAA

- **HTA** Nombre total d'heures autorisées.

- **MTA** Montant total autorisé.

- **EFF_AUTO** Effectifs autorisés.

- **MOTIF_RECOURS_SE** Cause d'activité partielle. Cf table ci-dessous

- **(PERIMETE_EFF) PERIMETRE_AP** Périmètre du chômage (1 à 4). Cf table ci-dessous

- **RECOURS_ANTERIEUR** Recours antérieurs au chômage (1 à 3) : -

- **AVIS_CE** Avis du comité d’entreprise

##### Table des motifs de recours à l'activité partielle

| Code | Libellé                                                                             |
| ---- | ----------------------------------------------------------------------------------- |
| 1    | Conjoncture économique.                                                             |
| 2    | Difficultés d’approvisionnement en matières premières ou en énergie                 |
| 3    | Sinistre ou intempéries de caractère exceptionnel                                   |
| 4    | Transformation, restructuration ou modernisation des installations et des bâtiments |
| 5    | Autres circonstances exceptionnelles                                                |

##### Table des périmètres du chômage.

| Code | Libellé                      |
| ---- | ---------------------------- |
| 1    | Réduction horaire tout Ets   |
| 2    | Réduction horaire partie Ets |
| 3    | Fermeture tempor. Tout Ets   |
| 4    | Fermeture tempor. Partie Ets |

##### Table des codes de recours antérieurs au chômage

| Code | Libellé                                                      |
| ---- | ------------------------------------------------------------ |
| 1    | Aucun recours depuis 3 ans                                   |
| 2    | Recours au chômage partiel au cours des 3 années précédentes |
| 3    | Non renseigné                                                |

#### Données de consommation d'activité partielle

- **S_HEURE_CONSOM_TOT** Nombre total d'heures consommées
- **S_MONTANT_CONSOM_TOT** Montant total consommé
- **S_EFF_CONSOM_TOT** Effectifs consommés

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
