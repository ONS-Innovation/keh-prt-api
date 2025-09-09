import psycopg
from fastapi import APIRouter, Response, status

from .utils.db import get_connection_parameters

router = APIRouter(prefix="/health", tags=["health"])


@router.get("", status_code=status.HTTP_200_OK)
async def health_check() -> dict[str, str]:
    """Health check endpoint.

    Returns:
        dict: A dictionary containing the health status.
    """
    return {"status": "healthy"}


@router.get("/database", status_code=status.HTTP_200_OK)
async def database_health_check(response: Response) -> dict[str, str]:
    """Database health check endpoint.

    Args:
        response (Response): The FastAPI response object. This carries a response code if it is anything other than the default.

    Returns:
        dict: A dictionary containing the database health status.
    """
    try:
        conn = psycopg.connect(**get_connection_parameters())
    except psycopg.OperationalError:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {"status": "unhealthy"}

    with conn, conn.cursor() as cur:
        cur.execute("SELECT 1")

        if not cur.fetchone():
            response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
            return {"status": "unhealthy"}

    return {"status": "healthy"}
