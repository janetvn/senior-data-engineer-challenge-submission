# SECTION 1: DATA PIPELINES

## **Prerequisites:**
- Install Docker Desktop 
- Install `make` program using Homebrew (https://formulae.brew.sh/formula/make)

## **Set up Airflow:**
1. Navigate to folder `airflow`
2. Make the Bash script `setup_airflow.sh` executable by running the following command:

```
chmod +x setup_airflow.sh
```

3. Run the bash script `setup_airflow.sh`:
``
./setup_airflow.sh
``
4. After the script finishes running, navigate to Airflow Web UI at https://localhost:8080 and login with the following credentials:
```
username: airflow
password: airflow
```

## **Run pipeline:**
Unpause and run the Airflow DAG called ``process_membership``
