import os

import psycopg


def get_connection():
    return psycopg.connect(
        host=os.getenv("DB_HOST", "learning-postgres"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME", "healthdb"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD"),
    )


def save_health_log(
    status,
    cpu_usage,
    memory_used_mb,
    memory_available_mb,
    disk_usage_percent,
):
    with get_connection() as conn, conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO health_logs (
                    status,
                    cpu_usage,
                    memory_used_mb,
                    memory_available_mb,
                    disk_usage_percent
                )
                VALUES (%s, %s, %s, %s, %s)
                """,
                (
                    status,
                    cpu_usage,
                    memory_used_mb,
                    memory_available_mb,
                    disk_usage_percent,
                ),
            )

