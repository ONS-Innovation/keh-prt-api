from fastapi import APIRouter
import psycopg
import logging

from .utils.db import get_connection_parameters

router = APIRouter(prefix="/health", tags=["health"])

@router.get("")
async def health_check() -> dict[str, str]:
    """Health check endpoint.

    Returns:
        dict: A dictionary containing the health status.
    """
    return {"status": "healthy"}

@router.get("/database")
async def database_health_check() -> dict[str, str]:
    """Database health check endpoint.

    Returns:
        dict: A dictionary containing the database health status.
    """

    # try:
    #     conn = psycopg.connect(**get_connection_parameters())
    # except psycopg.OperationalError:
    #     print("Database connection failed")
    #     return {"status": "unhealthy"}

    try:
        conn = psycopg.connect(
            **get_connection_parameters(),
            keepalives=1,
            keepalives_idle=60,
            keepalives_interval=10,
            keepalives_count=5,
        )
    except Exception as e:
        print(f"Database connection failed: {e}")
        logging.error(f"Database connection failed: {e}")
        return {"status": "unhealthy"}

    with conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")

            if not cur.fetchone():
                print("Database query failed")
                return {"status": "unhealthy"}

    return {"status": "healthy"}
