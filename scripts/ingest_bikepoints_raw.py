import json
import os
from datetime import datetime, timezone
import requests
import psycopg


API_URL = "https://api.tfl.gov.uk/BikePoint"

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "bikepoint")
DB_USER = os.getenv("DB_USER", "bikepoint")
DB_PASSWORD = os.getenv("DB_PASSWORD", "bikepoint")


def main():
    snapshot_timestamp = datetime.now(timezone.utc)

    response = requests.get(API_URL, timeout=30)
    response.raise_for_status()
    data = response.json()

    conn_str = (
        f"host={DB_HOST} port={DB_PORT} dbname={DB_NAME} "
        f"user={DB_USER} password={DB_PASSWORD}"
    )

    with psycopg.connect(conn_str) as conn:
        with conn.cursor() as cur:
            cur.execute("CREATE SCHEMA IF NOT EXISTS bronze;")

            cur.execute("""
                CREATE TABLE IF NOT EXISTS bronze.bikepoint_raw (
                    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    snapshot_timestamp TIMESTAMPTZ NOT NULL,
                    source_url TEXT NOT NULL,
                    raw_json JSONB NOT NULL,
                    loaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                );
            """)

            cur.execute("""
                INSERT INTO bronze.bikepoint_raw (
                    snapshot_timestamp,
                    source_url,
                    raw_json
                )
                VALUES (%s, %s, %s::jsonb);
            """, (
                snapshot_timestamp,
                API_URL,
                json.dumps(data)
            ))

        conn.commit()

    print(f"Loaded raw BikePoint snapshot: {snapshot_timestamp}, stations: {len(data)}")


if __name__ == "__main__":
    main()