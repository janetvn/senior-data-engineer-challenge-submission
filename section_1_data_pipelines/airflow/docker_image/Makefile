AIRFLOW_VERSION=2.5.1-python3.10
DOCKER_CLI=$(shell which docker)

build:
	${DOCKER_CLI} build --platform=linux/amd64 -t custom_airflow:${AIRFLOW_VERSION} .
