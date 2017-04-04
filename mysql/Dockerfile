FROM mysql:latest

COPY setup_users.sql /docker-entrypoint-initdb.d/
COPY volume_users_schema.sql /docker-entrypoint-initdb.d/
COPY z_populate.sql /docker-entrypoint-initdb.d/
