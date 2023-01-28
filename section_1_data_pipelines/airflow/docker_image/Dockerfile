FROM apache/airflow:2.5.1-python3.10

LABEL maintainer="mai.nguyen@coinhako.com"

USER root

USER airflow

# Install Python packages
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt