#! /usr/bin/env bash

# https://hub.docker.com/_/postgres/
# explains why it's better using bash script instead of sql script to initialize database


# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail

psql --variable ON_ERROR_STOP=1  --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
     CREATE USER keycloak WITH ENCRYPTED PASSWORD 'password';
     CREATE DATABASE keycloak WITH encoding 'UTF8';
     GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
     CREATE USER datapi WITH PASSWORD 'password';
     CREATE DATABASE datapi WITH encoding 'UTF8';
     GRANT ALL PRIVILEGES ON DATABASE datapi TO datapi;
EOSQL

zcat /docker-entrypoint-initdb.d/testData.sql |psql --variable ON_ERROR_STOP=1  --username "$POSTGRES_USER" --dbname datapi