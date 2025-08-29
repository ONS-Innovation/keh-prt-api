"""This script includes tests for the database utility (utils/db.py)"""

import os
import pytest
from src.api.v0.endpoints.utils.db import get_connection_parameters

def test_get_connection_parameters_local(monkeypatch):
    monkeypatch.setenv("LOCAL", "true")
    params = get_connection_parameters()
    assert params == {
        "host": "localhost",
        "port": 5432,
        "dbname": "prt_db",
        "user": "postgres",
        "password": "postgres"
    }

def test_get_connection_parameters_lambda_success(monkeypatch):
    monkeypatch.setenv("LOCAL", "false")
    monkeypatch.setenv("DB_SECRET_NAME", "my_secret")

    class FakeSecretManager:
        def get_secret_value(self, SecretId):
            assert SecretId == "my_secret"
            return {
                "SecretString": '{"host": "remotehost", "port": 1234, "database": "remotedb", "username": "remoteuser", "password": "remotepass"}'
            }

    class FakeSession:
        def client(self, service, region_name=None):
            assert service == "secretsmanager"
            assert region_name == "eu-west-2"
            return FakeSecretManager()

    monkeypatch.setattr("boto3.session.Session", lambda: FakeSession())

    params = get_connection_parameters()
    assert params == {
        "host": "remotehost",
        "port": 1234,
        "dbname": "remotedb",
        "user": "remoteuser",
        "password": "remotepass"
    }

def test_get_connection_parameters_lambda_missing_secret_name(monkeypatch):
    monkeypatch.setenv("LOCAL", "false")
    monkeypatch.delenv("DB_SECRET_NAME", raising=False)
    with pytest.raises(ValueError, match="DB_SECRET_NAME environment variable is not set"):
        get_connection_parameters()

def test_get_connection_parameters_lambda_missing_secret_string(monkeypatch):
    monkeypatch.setenv("LOCAL", "false")
    monkeypatch.setenv("DB_SECRET_NAME", "my_secret")

    class FakeSecretManager:
        def get_secret_value(self, SecretId):
            return {}

    class FakeSession:
        def client(self, service, region_name=None):
            return FakeSecretManager()

    monkeypatch.setattr("boto3.session.Session", lambda: FakeSession())

    with pytest.raises(ValueError, match="DB credentials not found"):
        get_connection_parameters()
        