import os
from fastapi.testclient import TestClient
from src.main import app
from src.main import handler
from mangum import Mangum
from importlib import reload

def test_app_root_path():
    env = os.getenv("ENVIRONMENT", "dev")
    assert app.root_path == f"/{env}"

def test_cors_middleware():
    # Check that CORS middleware is present
    middlewares = [middleware.cls.__name__ for middleware in app.user_middleware]
    assert "CORSMiddleware" in middlewares

def test_api_v0_router_included():
    # Check that the router is included with correct prefix
    prefixes = [route.path for route in app.routes]
    assert any(path.startswith("/api/v0") for path in prefixes)

def test_app_responds_to_root():
    client = TestClient(app)
    response = client.get("/api/v0/")
    # The response status code may vary depending on the router implementation
    # Here we check that it does not return 404 (router exists)
    assert response.status_code != 404
    def test_handler_is_mangum_instance():
        # Ensure the handler is an instance of Mangum
        assert isinstance(handler, Mangum)
        