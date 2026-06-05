from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="bikepoint_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="*/5 * * * *",
    catchup=False,
    tags=["bikepoint", "tfl", "dbt"],
) as dag:

    ingest_raw = BashOperator(
        task_id="ingest_raw",
        bash_command="python /opt/airflow/scripts/ingest_bikepoints_raw.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="cd /opt/airflow/dbt/london_bikepoint && dbt run",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="cd /opt/airflow/dbt/london_bikepoint && dbt test",
    )

    ingest_raw >> dbt_run >> dbt_test