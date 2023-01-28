#! /bin/bash

# Build PostgreSQL Image
docker build --platform=linux/amd64 -t custom_postgresql:15.1 .
docker images custom_postgresql

# Start PostgreSQL
docker-compose up