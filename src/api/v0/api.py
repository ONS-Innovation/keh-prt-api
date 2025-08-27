from fastapi import APIRouter

from .endpoints import health

router = APIRouter()


@router.get("")
async def root():
    return {
        "message": "Welcome to the PRT API v0.",
    }


# Include the endpoints in the router
router.include_router(health.router)
