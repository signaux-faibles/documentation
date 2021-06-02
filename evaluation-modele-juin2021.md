Evaluation du modèle Signaux Faibles - juin 2021
=== 

## Synthèse du modèle

Modèle étage 1: régression logistique
- https://github.com/signaux-faibles/predictsignauxfaibles/tree/develop/models/default pour les établissements avec données financières
- https://github.com/signaux-faibles/predictsignauxfaibles/tree/develop/models/small pour les autres établissements
C'est cet étage qui est évalué ci-dessous.

Modèle étage 2: redressement à posteriori sur reprise du règlements des encours de dettes sociales aux Urssaf fin 2020. Par définition, cet étage ne peux être évalué

## Modèle "default"

### Seuils sélectionnés - $f_{\beta}$

Sur le dataset de test chargé depuis `/home/common/benchmark/052021_full_data_test.csv` (1.2M):<br>
F1 - $\beta=0.5$ - Optimal threshold: $t_{F1,fb}=0.868$ - $f_{0.5}=0.672$<br>
F2 - $\beta=2$ - Optimal threshold: $t_{F2,fb}=0.183$ - $f_{2}=0.495$

### Evaluation du modèle pré-redressements - seuils $f_{\beta}$
```
> evaluate(
>     pp,
>     test,
>     beta=0.5,
>     thresh=t_F1_fb
> )

{
    'balanced_accuracy': 0.6682117091492364,
    'confusion_matrix': {
    	'tn': 479986,
    	'fp': 864,
    	'fn': 14219,
    	'tp': 7267
    	},
    'f0.5': 0.672745787817071,
    'precision': 0.8937400073791661,
    'recall': 0.3382202364330262
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
    'balanced_accuracy': 0.7390538988314339,
    'confusion_matrix': {
    	'tn': 468488,
    	'fp': 12362,
    	'fn': 10661,
    	'tp': 10825
    	},
    'f2': 0.4959635667225627,
    'precision': 0.46685642817095785,
    'recall': 0.5038164386111886
}
```

### Volumétrie des seuils - $f_{\beta}$
Avec les seuils sélectionnés juste au-dessus par une maximisation des f_0.5 et f_2 scores, respectivement:
- 8131 risque fort (1.62%)
- 15056 risque modéré (3.0%)


### [Bonus] Seuils sélectionnés - semi-manuel
Sur le dataset de test chargé depuis `/home/common/benchmark/052021_full_data_test.csv` (1.2M):<br>
F1 - $t_{F1}=0.904$ garantit une précision de 91% pour la liste F1 (rouge)<br>
F2 - $t_{F2}=0.134$ garantit un recall de 58.5% pour la liste F2 (orange)

### [Bonus] Volumétrie des seuils - semi-manuel
Avec les seuils sélectionnés juste au-dessus par une sélection semi-manuelle:
- 7662 risque fort (1.53%)
- 35913 risque modéré (7.15%)

### [Bonus] Evaluation du modèle pré-redressements - seuils semi-manuels
```
> evaluate(
>     pp,
>     test,
>     beta=0.5,
>     thresh=t_F1_cond
> )

{
	'balanced_accuracy': 0.6615752852059438,
	'confusion_matrix': {
		'tn': 480161,
		'fp': 689,
		'fn': 14512,
		'tp': 6974
		},
	'f0.5': 0.6688020253941463,
	'precision': 0.9100874331201879,
	'recall': 0.32458344968816905
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
	'balanced_accuracy': 0.7620499212745868,
	'confusion_matrix': {
		'tn': 449917,
		'fp': 30933,
		'fn': 8843,
		'tp': 12643
		},
	'f2': 0.48807134033353927,
	'precision': 0.29013677253534054,
	'recall': 0.5884296751372987
}
```



## Modèle "small"

Pour le modèle "small“, sur le dataset de test chargé depuis `/home/common/benchmark/052021_full_data_test.csv`, la courbe précision/recall est trop "bruitée" pour une sélection de seuil semi-manuelle.

### Seuils sélectionnés - $f_{\beta}$

Sur le dataset de test chargé depuis `/home/common/benchmark/052021_full_data_test.csv` (1.2M):<br>
F1 - $\beta=0.5$ - Optimal threshold: $t_{F1}=0.684$ - $f_{0.5}=0.670$<br>
F2 - $\beta=2$ - Optimal threshold: $t_{F2}=0.127$ - $f_{2}=0.514$

### Volumétrie des seuils - $f_{\beta}$
Avec les seuils sélectionnés juste au-dessus par une maximisation des f_0.5 et f_2 scores, respectivement:
- 8425 risque fort (1.68%)
- 13640 risque modéré (2.72%)

### Evaluation du modèle pré-redressements - seuils $f_{\beta}$
```
> evaluate(
>     pp,
>     test,
>     beta=0.5,
>     thresh=t_F1_fb
> )

{
	'balanced_accuracy': 0.6709448495646309,
	'confusion_matrix': {
		'tn': 479817,
		'fp': 1033,
		'fn': 14094,
		'tp': 7392
		},
	'f0.5': 0.6697350777371072,
	'precision': 0.8773887240356083,
	'recall': 0.34403797821837473
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
	'balanced_accuracy': 0.7469789831298288,
	'confusion_matrix': {
		'tn': 469888,
		'fp': 10962,
		'fn': 10383,
		'tp': 11103
		},
	'f2': 0.5139849456989694,
	'precision': 0.5031951053704963,
	'recall': 0.5167550963418039
}
```