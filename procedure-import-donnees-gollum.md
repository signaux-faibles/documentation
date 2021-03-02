<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Procédure pour importer les données mensuelles](#proc%C3%A9dure-pour-importer-les-donn%C3%A9es-mensuelles)
  - [Structure des fichiers](#structure-des-fichiers)
  - [Mettre à jour les outils](#mettre-%C3%A0-jour-les-outils)
  - [Mettre les nouveaux fichiers dans un répertoire spécifique](#mettre-les-nouveaux-fichiers-dans-un-r%C3%A9pertoire-sp%C3%A9cifique)
  - [Télécharger le fichier Siren](#t%C3%A9l%C3%A9charger-le-fichier-siren)
  - [Créer un objet admin pour l'intégration des données](#cr%C3%A9er-un-objet-admin-pour-lint%C3%A9gration-des-donn%C3%A9es)
  - [Mettre à jour la commande `sfdata` (optionnel)](#mettre-%C3%A0-jour-la-commande-sfdata-optionnel)
  - [Lancer l'import](#lancer-limport)
  - [Lancer le compactage](#lancer-le-compactage)
  - [Maintenance: nettoyage des données hors périmètre](#maintenance-nettoyage-des-donn%C3%A9es-hors-p%C3%A9rim%C3%A8tre)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<!-- importé depuis https://github.com/signaux-faibles/documentation/blob/master/procedure-import-donnees.md -->

# Procédure pour importer les données mensuelles

La plupart de ces opérations sont menées sur `stockage`, serveur sur lequel sont reçus et conservés les fichiers régulièrement transmis par nos partenaires.

Procédure: [Procédure pour importer les données mensuelles](https://github.com/signaux-faibles/documentation/blob/master/procedure-import-donnees.md#proc%C3%A9dure-pour-importer-les-donn%C3%A9es-mensuelles).

## Structure des fichiers

La génération de _batch_ ou _sous-batch_ est effectuée depuis le répertoire `/var/lib/goup_base/public` du serveur `stockage`.

Procédure: [Structure des fichiers](https://github.com/signaux-faibles/documentation/blob/master/procedure-import-donnees.md#structure-des-fichiers)

## Mettre à jour les outils

Depuis `ssh stockage -R 1080` (pour se connecter à `stockage` en partageant la connexion internet de l'hôte via le port `1080`):

```sh
curl google.com --proxy socks5h://127.0.0.1:1080 # pour tester le bon fonctionnement du proxy http
git config --global http.proxy 'socks5h://127.0.0.1:1080' # si nécéssaire: pour que git utilise le proxy
```

Reste de la procédure: [Mettre à jour les outils](https://github.com/signaux-faibles/documentation/blob/master/procedure-import-donnees.md#mettre-%C3%A0-jour-les-outils).

## Mettre les nouveaux fichiers dans un répertoire spécifique

Procédure: [Mettre les nouveaux fichiers dans un répertoire spécifique](#mettre-les-nouveaux-fichiers-dans-un-r%C3%A9pertoire-sp%C3%A9cifique) à suivre depuis `ssh stockage`.

## Télécharger le fichier Siren

Procédure: [Télécharger le fichier Siren](#t%C3%A9l%C3%A9charger-le-fichier-siren) à suivre depuis le répertoire `/var/lib/goup_base/public/_<batch>_` de `ssh stockage`.

## Créer un objet admin pour l'intégration des données

Procédure: [Créer un objet admin pour l'intégration des données](#cr%C3%A9er-un-objet-admin-pour-lint%C3%A9gration-des-donn%C3%A9es) à suivre depuis le répertoire `/var/lib/goup_base/public` de `ssh stockage`.

## Mettre à jour la commande `sfdata` (optionnel)

Depuis un environnement de développement ayant accès à internet:

```sh
cd opensignauxfaibles
git checkout master            # sélectionne la branche principale de sfdata
git pull                       # met à jour le code source de sfdata
make build-prod                # compile sfdata
scp sfdata centos@labtenant:~  # copie sfdata dans l'environnement de production
```

Depuis `ssh centos@labtenant`:

```sh
./sfdata --help                # vérifie que la commande fonctionne
mv sfdata ~/opensignauxfaibles/sfdata/
```

## Lancer l'import

Procédure: [Lancer l'import](#lancer-limport) à suivre depuis le répertoire `~/opensignauxfaibles/sfdata/` de `ssh centos@labtenant`.

## Lancer le compactage

Procédure: [Lancer le compactage](#lancer-le-compactage) à suivre depuis le répertoire `~/opensignauxfaibles/sfdata/` de `ssh centos@labtenant`.

## Maintenance: nettoyage des données hors périmètre

Procédure: [Nettoyage des données hors périmètre](#maintenance-nettoyage-des-donn%C3%A9es-hors-p%C3%A9rim%C3%A8tre) à suivre depuis le répertoire `~/opensignauxfaibles/sfdata/` de `ssh centos@labtenant`.
