from fastapi import APIRouter

from app.api.routes import utils
from app.core.config import settings
from app.membership_service.routes import login, private, users
from app.todo_service.routes import items

api_router = APIRouter()
api_router.include_router(login.router)
api_router.include_router(users.router)
api_router.include_router(items.router)
api_router.include_router(utils.router)

if settings.ENVIRONMENT == "local":
    api_router.include_router(private.router)
