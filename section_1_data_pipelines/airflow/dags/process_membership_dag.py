import glob
import logging
import os
import hashlib
from datetime import date, timedelta, datetime

import pandas as pd
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.utils.dates import days_ago
from pandas import DataFrame

DAG_NAME = "process_membership"
CONCURRENCY_LIMIT = 1

logger = logging.getLogger(__name__)

cwd = os.path.abspath(os.getcwd())

default_args = {
    "start_date": days_ago(1),
    "depends_on_past": False,
    "provide_context": True,
    "retries": 0,
    "retry_delay": timedelta(minutes=5),
}


def read_datasets(input_dir_path):
    """
    Read all datasets from the input directory path into a single dataframe
    :param input_dir_path: input directory path
    :return: dataframe
    """
    # print(input_dir_path)
    res = os.listdir(input_dir_path)
    print(res)
    df = pd.concat(
        map(
            pd.read_csv,
            glob.glob(os.path.join(input_dir_path, "applications_dataset_*.csv")),
        )
    )
    return df


def validate_checks(dataframe: DataFrame):
    """
    Perform validate checks to consolidate successful and unsuccessful applications.
    An application is successful if:
        - Application mobile number is 8 digits
        - Applicant is over 18 years old as of 1 Jan 2022
        - Applicant has a valid email (email ends with @emailprovider.com or @emailprovider.net)
    :param dataframe:
    """

    def calculate_age(born):
        """Calculate the age as of 1 Jan 2022"""
        today = date(2022, 1, 1)
        age = (
                today.year - born.year - ((today.month, today.day) < (born.month, born.day))
        )
        return age > 18

    # split name
    dataframe["first_name"] = dataframe["name"].apply(
        lambda name: None if name is None else name.split(" ")[0]
    )
    dataframe["last_name"] = dataframe["name"].apply(
        lambda name: None if name is None else name.split(" ")[1]
    )

    # number of digits in the mobile number
    dataframe["digits"] = dataframe["mobile_no"].astype(str).map(len)

    # convert date of birth to datetime dtype
    dataframe["date_of_birth"] = pd.to_datetime(
        dataframe["date_of_birth"], infer_datetime_format=True
    )
    # calculate applicant age as of 1 Jan 2022
    dataframe["above_18"] = dataframe["date_of_birth"].apply(calculate_age)
    dataframe["date_of_birth"] = dataframe["date_of_birth"].dt.strftime("%Y%m%d")
    # valid_df ending
    dataframe["email_ending"] = dataframe["email"].apply(lambda e: e.split("@")[-1])

    dataframe.head(20)

    columns = ["first_name", "last_name", "email", "date_of_birth", "above_18"]

    # filter applications
    first_invalid_df = dataframe[dataframe["name"].isnull()]
    remaining_df = dataframe[dataframe["name"].notnull()]

    valid_query = "digits == 8 & above_18 == True & email_ending == 'emailprovider'"
    valid_df = remaining_df.query(valid_query)[columns]

    invalid_query = "digits != 8 | above_18 != True | email_ending != 'emailprovider'"
    second_invalid_df = remaining_df.query(invalid_query)[columns]
    invalid_df = pd.concat([first_invalid_df[columns], second_invalid_df])

    return invalid_df, valid_df


def create_membership_ids(valid_dataframe: DataFrame):
    """
    Create membership ID for successful applications. Membership IDs for successful applications will the user's last
    name, followed by a SHA256 hash of the applicant's birthday, truncated to first 5 digits of hash
    (i.e <last_name>_<hash(YYYYMMDD)>)
    :param valid_dataframe: DataFrame of the successful applications
    """

    def hash_birthday(birthday: str):
        hashed_string = hashlib.sha256(birthday.encode("utf-8")).hexdigest()
        return hashed_string[:5]

    valid_dataframe["birthday_string"] = valid_dataframe["date_of_birth"].astype(str)
    valid_dataframe["hashed_birthday"] = valid_dataframe["birthday_string"].apply(hash_birthday)
    valid_dataframe["membership_id"] = valid_dataframe["last_name"] + valid_dataframe["hashed_birthday"]

    # drop columns
    valid_dataframe = valid_dataframe.drop(["birthday_string", "hashed_birthday"], axis=1)

    return valid_dataframe


def process_applications(input_dir_path):
    # Read datasets
    logger.info(f"Read datasets from path {input_dir_path}")
    df = read_datasets(input_dir_path)

    # Perform validation checks
    logger.info("Perform validation checks")
    invalid_df, valid_df = validate_checks(df)

    # Create membership IDs for successful applications
    logger.info("Create membership IDs for successful applications")
    valid_df = create_membership_ids(valid_df)

    # Write unsuccessful applications dataframe
    now = datetime.now()
    invalid_path = cwd + "/dags/output/unsuccessful_applications/unsuccessful_applications_{}.csv".format(now.strftime("%Y%m%d.%H%M"))
    valid_path = cwd + "/dags/output/successful_applications/successful_applications_{}.csv".format(now.strftime("%Y%m%d.%H%M"))

    logger.info(f"Write unsuccessful applications to path {invalid_path}")
    invalid_df.to_csv(invalid_path, index=False)
    logger.info(f"Write successful applications to path {valid_path}")
    valid_df.to_csv(valid_path, index=False)


with DAG(
    DAG_NAME,
    description="Process the membership applications submitted by users on an hourly interval",
    concurrency=CONCURRENCY_LIMIT,
    max_active_tasks=CONCURRENCY_LIMIT,
    schedule_interval="@hourly",
    default_args=default_args,
    max_active_runs=1,
    catchup=False,
    tags=["membership applications"],
) as dag:

    start = DummyOperator(task_id="start")

    process_membership = PythonOperator(
        task_id="process_membership",
        python_callable=process_applications,
        op_kwargs={
            "input_dir_path": cwd + "/dags/input/",
        },
    )

    end = DummyOperator(task_id="end")

    start >> process_membership >> end
