#! /bin/bash

# Build Airflow Image
cd docker_image
make
docker images custom_airflow

# Start Airflow Container
docker-compose up airflow-init
docker-compose up -d