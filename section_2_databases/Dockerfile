FROM postgres:15.1

LABEL maintainer="janetvn@gmail.com"
ENV LANG en_US.utf8

COPY sql/create_tables.sql /docker-entrypoint-initdb.d/
COPY sql/fill_tables.sql /docker-entrypoint-initdb.d/