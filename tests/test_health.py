import pytest
from fastapi.testclient import TestClient
from src.api.v0.endpoints.health import router

client = TestClient(router)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_database_health_check_healthy(monkeypatch):
    class DummyConn:
        def __enter__(self): return self
        def __exit__(self, exc_type, exc_val, exc_tb): pass
        def cursor(self): return self
        def execute(self, query): pass
        def fetchone(self): return (1,)
        def close(self): pass

    monkeypatch.setenv("LOCAL", "true")

    monkeypatch.setattr("src.api.v0.endpoints.health.psycopg.connect", lambda **kwargs: DummyConn())
    response = client.get("/health/database")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_database_health_check_unhealthy_connection(monkeypatch):
    class DummyOperationalError(Exception): 
        pass

    monkeypatch.setattr("src.api.v0.endpoints.health.psycopg.OperationalError", DummyOperationalError)
    
    def raise_error(**kwargs): 
        raise DummyOperationalError()

    monkeypatch.setenv("LOCAL", "true")

    monkeypatch.setattr("src.api.v0.endpoints.health.psycopg.connect", raise_error)
    response = client.get("/health/database")
    assert response.status_code == 503
    assert response.json() == {"status": "unhealthy"}

def test_database_health_check_unhealthy_query(monkeypatch):
    class DummyConn:
        def __enter__(self): return self
        def __exit__(self, exc_type, exc_val, exc_tb): pass
        def cursor(self): return self
        def execute(self, query): pass
        def fetchone(self): return None
        def close(self): pass

    monkeypatch.setenv("LOCAL", "true")

    monkeypatch.setattr("src.api.v0.endpoints.health.psycopg.connect", lambda **kwargs: DummyConn())
    response = client.get("/health/database")
    assert response.status_code == 503
    assert response.json() == {"status": "unhealthy"}