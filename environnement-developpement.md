# Environnement de développement avec Docker compose

En tout premier lieu, vérifiez que vous avez bien installé et configuré Docker pour votre système d'exploitation. Si besoin, se réferrer à la [documentation officielle](https://docs.docker.com/get-docker/).

## A quoi sert docker-compose dans ce projet

Mettre en place de façon rapide et souple les outils annexes nécessaires au développement du projet SignauxFaible indifféremment du système d'exploitation de chacun des contributeurs. Les langages et framework utilisés restent à installer par le contributeur afin de manipuler le code source. Ce fichier ne fournit que les éléments de support (bases de données, documentation, gestion des utilisateurs...).

## Détails des outils mis à disposition

Le fichier `docker-compose.yml` que vous retrouverez à la racine de ce projet exécute l'ensemble des outils utilisés par le projet SignauxFaibles. Ces outils sont les suivants :

- MongoDB (v4.0) - Base de données orientée documents - port 27017
- PostgreSQL (v10.0) - Base de donnée relationnelle - port 5432
- Keycloak (v12.0.4) - Gestion des comptes et droits utilisateurs - port 8081
- Wekan (latest) - Création et gestion de Kanban - port 8080
- Gollum (latest) - Génération de la présente documentation sous forme web - port 4567

Les données des deux bases de données (Mongo et Postgres) sont enfin stockées dans des [volumes](https://docs.docker.com/storage/volumes/) afin d'assurer une persistence entre les différents lancements de Docker au cours du développement.

## Elements à vérifier avant l'execution

Ce fichier nécessite :

- Un script d'alimentation SQL pour PostgreSQL (ici `./data/testData.sql`)
- Le chemin vers la documentation (ici `./wiki`)

Veillez à indiquer les chemins de ces fichiers (relatifs ou absolus) qui correspondent à votre environnement de développement.

## Exécution

Une fois les éléments ci-dessus vérifiés, vous pouvez lancer la stack avec la commande `docker compose up` depuis le dossier où se trouve votre fichier `docker-compose.yml`.
