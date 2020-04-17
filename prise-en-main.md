# Prise en main

## Survol des services Web

- `nginx` sert l'application [frontal](https://github.com/signaux-faibles/signauxfaibles-web) (en vuejs) accessible aux utilisateurs
- `datapi` donne accès à certaines données de notre base de données au frontal, en respectant les droits de l'utilisateur qui les demande
- `fider` est un système externe permettant d'échanger avec les utilisateurs du frontal

## Developpement Datapi et frontal en local

### 1. Configuration

Créer le fichier `config.toml`:

```toml
bind = "127.0.0.1:3000"
postgres = "user=postgres dbname=datapi password=mysecretpassword host=localhost sslmode=disable"
keycloakHostname = "http://127.0.0.1:8080"
keycloakClientID = "signauxfaibles"
keycloakRealm = "master"
keycloakAdmin = "mykeycloak"
keycloakPassword = "mysecretpassword"
keycloakAdminRealm = "master"
```

### 2. Lancer la base de données en local avec Docker

Après avoir installé Docker, exécutez les commandes suivantes:

```sh
$ docker run \
    -d postgres:10 \
    --name sf-postgres \
    -P -p 127.0.0.1:5432:5432 \
    -e POSTGRES_PASSWORD=mysecretpassword
```

> Note: ces paramètres doivent coincider avec celles fournies dans la variable `postgres` du fichier `config.toml`.

Pour tester la connexion:

```sh
$ docker exec -it sf-postgres psql -U postgres
# => puis taper ctrl-D pour quiter
```

### 3. Initialiser la base de données locale

1. Récupérez [`db-schema.sql`](https://github.com/signaux-faibles/datapi/blob/master/db-schema.sql) depuis le dépôt de `datapi`.

2. Exécutez les commandes suivantes:

```sh
$ echo "create database datapi;" \
    | docker exec -i sf-postgres psql -U postgres
$ cat db-schema.sql \
    | docker exec -i sf-postgres psql -U postgres datapi
```

> Notes:
>
> - Vous pouvez ignorer les warnings concernant l'absence de rôles.
> - Plus tard, pensez à couper le serveur avec `docker ps`, `docker kill` puis `docker rm sf-postgres`.

### 4. Lancer keycloak (fournisseur identité oauth2) avec Docker

Exécutez les commandes suivantes:

```sh
$ docker run \
    -d jboss/keycloak \
    -p 8080:8080 \
    -e KEYCLOAK_USER=mykeycloak \
    -e KEYCLOAK_PASSWORD=mysecretpassword
```

> Notes:
>
> - Les paramètres ci-dessus doivent coincider avec les valeurs fournies dans les variables `keycloakHostname`, `keycloakAdmin` et `keycloakPassword` du fichier `config.toml`.
> - Plus tard, pensez à couper le serveur avec `docker ps`, `docker kill` puis `docker rm`.

### 5. Lancer datapi

Exécutez les commandes suivantes:

```sh
$ go get github.com/signaux-faibles/datapi
$ go build ~/go/src/github.com/signaux-faibles/datapi # compile le binaire ./datapi dans le répertoire courant
$ ./datapi -api # lance le serveur datapi sur le port 3000
```

Pour tester:

```sh
$ curl 127.0.0.1:3000 # => la requête doit s'afficher dans les logs de datapi
```

### 6. Créer un utilisateur sur Keycloak

1. ouvrir http://localhost:8080/auth/admin/master/console/#/realms/master
2. se connecter avec identifiants fournis au lancement du container keycloak
3. créer un client `signauxfaibles` (comme client ID et nom)
4. spécifier les paramètres suivants depuis l'onglet "Settings":

- Implicit Flow Enabled: `ON`
- Valid Redirect URIs: `http://localhost:8081/*`
- Base URLs: `http://localhost:8081/`
- Web Origins: `http://localhost:8081` (attention: ne pas inclure de slash en fin d'URL !)

5. Ajouter un role `urssaf`
6. Dans "Users", ouvrir le username `mykeycloak`
7. Onglet "Role Mappings": choisir le role `signaux-faibles` puis y ajouter `urssaf`

### 7. Compiler et lancer le frontal

1. Exécutez les commandes suivantes:

   ```sh
   $ git clone https://github.com/signaux-faibles/signauxfaibles-web
   $ cd signauxfaibles-web
   $ nvm use 12 # pour utiliser la version 12 de Node.js, dans la mesure du possible
   $ npm install -g yarn
   ```

2. Suivre les instructions d'installation de [signauxfaibles-web](https://github.com/signaux-faibles/signauxfaibles-web).

3. Ouvrir http://localhost:8081/ dans votre navigateur.

### 8. Paramétrer `signauxfaibles-web` pour l'usage en local

1. Replacements à effectuer dans `src/main.ts`:

   - `local = 'http://localhost/auth/'` --> `local = 'http://localhost:8080/auth/'`
   - `url: prod` --> `url: local`

2. Replacements à effectuer dans `store.ts`:

   - `baseURL = '/'` --> `baseURL = 'http://localhost:3000/'`
