<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Evaluation du modèle Signaux Faibles - juin 2021](#evaluation-du-mod%C3%A8le-signaux-faibles---juin-2021)
  - [Synthèse du modèle](#synth%C3%A8se-du-mod%C3%A8le)
  - [Modèle "default"](#mod%C3%A8le-default)
    - [Seuils sélectionnés - $f_{\beta}$](#seuils-s%C3%A9lectionn%C3%A9s---f_%5Cbeta)
    - [Evaluation du modèle pré-redressements - seuils $f_{\beta}$](#evaluation-du-mod%C3%A8le-pr%C3%A9-redressements---seuils-f_%5Cbeta)
    - [Volumétrie des seuils - $f_{\beta}$](#volum%C3%A9trie-des-seuils---f_%5Cbeta)
    - [[Bonus] Seuils sélectionnés - semi-manuel](#bonus-seuils-s%C3%A9lectionn%C3%A9s---semi-manuel)
    - [[Bonus] Volumétrie des seuils - semi-manuel](#bonus-volum%C3%A9trie-des-seuils---semi-manuel)
    - [[Bonus] Evaluation du modèle pré-redressements - seuils semi-manuels](#bonus-evaluation-du-mod%C3%A8le-pr%C3%A9-redressements---seuils-semi-manuels)
  - [Modèle "small"](#mod%C3%A8le-small)
    - [Seuils sélectionnés - $f_{\beta}$](#seuils-s%C3%A9lectionn%C3%A9s---f_%5Cbeta-1)
    - [Volumétrie des seuils - $f_{\beta}$](#volum%C3%A9trie-des-seuils---f_%5Cbeta-1)
    - [Evaluation du modèle pré-redressements - seuils $f_{\beta}$](#evaluation-du-mod%C3%A8le-pr%C3%A9-redressements---seuils-f_%5Cbeta-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Evaluation du modèle Signaux Faibles - juin 2021

## Synthèse du modèle

Modèle étage 1: régression logistique

- https://github.com/signaux-faibles/predictsignauxfaibles/tree/develop/models/default pour les établissements avec données financières
- https://github.com/signaux-faibles/predictsignauxfaibles/tree/develop/models/small pour les autres établissements
  C'est cet étage qui est évalué ci-dessous.

Modèle étage 2: redressement à posteriori sur reprise du règlements des encours de dettes sociales aux Urssaf fin 2020. Par définition, cet étage ne peux être évalué

## Modèle "default"

### Seuils sélectionnés - $f_{\beta}$

Sur le dataset de test chargé depuis `/home/common/benchmark/052021_full_data_test.csv` (1.2M):<br>
Pallier "risque fort" - $\beta=0.5$ - Optimal threshold: $t_{F1}=0.817$ - $F_{0.5}=0.722$<br>
Pallier "risque modéré" - $\beta=2$ - Optimal threshold: $t_{F2}=0.179$ - $F_{2}=0.547$

### Evaluation du modèle pré-redressements - seuils $f_{\beta}$

```
> evaluate(
>     pp,
>     test,
>     beta=0.5,
>     thresh=t_F1_fb
> )

{
	'aucpr': 0.522,
    'balanced_accuracy': 0.675,
    'confusion_matrix': {
    	'tn': 479649,
    	'fp': 1201,
    	'fn': 13893,
    	'tp': 7593
    	},
    'f0.5': 0.670,
    'precision': 0.863,
    'recall': 0.353
}
```

```
> evaluate(
>     pp,
>     test,
>     beta=2,
>     thresh=t_F2_fb
> )

{
	'aucpr': 0.522,
    'balanced_accuracy': 0.740,
    'confusion_matrix': {
    	'tn': 468027,
    	'fp': 12823,
    	'fn': 10621,
    	'tp': 10865
    	},
    'f2': 0.496,
    'precision': 0.459,
    'recall': 0.506
}
```

### Volumétrie des seuils - $f_{\beta}$

Avec les seuils sélectionnés juste au-dessus par une maximisation des scores $F_{0.5}$ et $F_{2}$, respectivement:

- Pallier "risque fort" (rouge): 1929 (1.71%)
- Pallier "risque modéré" (orange): 5227 (4.65%)

### [Bonus] Seuils sélectionnés - semi-manuel

Sur le dataset de test chargé depuis `/home/common/benchmark/052021_split_data_validation.csv` (1.7M):<br>
Pallier "risque fort" - $t_{F1}=0.822$ garantit une précision de 92% pour la liste "risque fort" (rouge)<br>
Pallier "risque modéré" - $t_{F2}=0.141$ garantit un recall de 58.5% pour la liste "risque modéré" (orange)

### [Bonus] Volumétrie des seuils - semi-manuel

Avec les seuils sélectionnés juste au-dessus par une sélection semi-manuelle:

- Pallier "risque fort" (rouge): 1914 (1.7%)
- Pallier "risque modéré" (orange): 8496 (7.55%)

### [Bonus] Evaluation du modèle pré-redressements - seuils semi-manuels

```
> evaluate(
>     pp,
>     test,
>     beta=0.5,
>     thresh=t_F1_cond
> )

{
	'aucpr': 0.522,
	'balanced_accuracy': 0.675,
	'confusion_matrix': {
		'tn': 479693,
		'fp': 1157,
		'fn': 13914,
		'tp': 7572
		},
	'f0.5': 0.671,
	'precision': 0.867,
	'recall': 0.352
}
```

```
> evaluate(
>     pp,
>     test,
>     beta=2,
>     thresh=t_F2_cond
> )

{
	'aucpr': 0.522,
	'balanced_accuracy': 0.746,
	'confusion_matrix': {
		'tn': 455683,
		'fp': 25167,
		'fn': 9752,
		'tp': 11734
		},
	'f2': 0.478,
	'precision': 0.318,
	'recall': 0.546
}
```

## Modèle "small"

Pour le modèle "small“, sur le dataset de test chargé depuis `/home/common/benchmark/052021_full_data_test.csv`, la courbe précision/recall est trop "bruitée" pour une sélection de seuil semi-manuelle.

### Seuils sélectionnés - $f_{\beta}$

Sur le dataset de test chargé depuis `/home/common/benchmark/052021_full_data_test.csv` (1.2M):<br>
Pallier "risque fort" - $\beta=0.5$ - Optimal threshold: $t_{F1}=0.667$ - $f_{0.5}=0.724$<br>
Pallier "risque modéré" - $\beta=2$ - Optimal threshold: $t_{F2}=0.134$ - $f_{2}=0.563$

### Volumétrie des seuils - $f_{\beta}$

Avec les seuils sélectionnés juste au-dessus par une maximisation des scores $f_{0.5}$ et $f_{2}$, respectivement:

- Pallier "risque fort" (rouge): 1896 (1.69%)
- Pallier "risque modéré" (orange): 3237 (2.88%)

### Evaluation du modèle pré-redressements - seuils $f_{\beta}$

```
> evaluate(
>     pp,
>     test,
>     beta=0.5,
>     thresh=t_F1_fb
> )

{
	'aucpr': 0.482,
	'balanced_accuracy': 0.672,
	'confusion_matrix': {
		'tn': 479730,
		'fp': 1120,
		'fn': 14008,
		'tp': 7478
		},
	'f0.5': 0.669,
	'precision': 0.870,
	'recall': 0.348
}
```

```
> evaluate(
>     pp,
>     test,
>     beta=2,
>     thresh=t_F2_fb
> )

{
	'aucpr': 0.482,
	'balanced_accuracy': 0.745,
	'confusion_matrix': {
		'tn': 471130,
		'fp': 9720,
		'fn': 10533,
		'tp': 10953
		},
	'f2': 0.514,
	'precision': 0.530,
	'recall': 0.510
}
```