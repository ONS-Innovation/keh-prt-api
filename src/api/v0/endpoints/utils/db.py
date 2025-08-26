import boto3
import os
import json

def get_connection_parameters() -> dict[str, str]:
    """Get database connection parameters.

    Returns:
        dict: A dictionary containing the database connection parameters.
    """
    if os.getenv("LOCAL", "false").lower() == "true":
        return {
            "host": "localhost",
            "port": 5432,
            "dbname": "prt_db",
            "user": "postgres",
            "password": "postgres"
        }
    
    # If local is False, running on Lambda
    # Need to get the credentials from Secret Manager

    secret_name = os.getenv("DB_SECRET_NAME")

    if not secret_name:
        raise ValueError("DB_SECRET_NAME environment variable is not set")

    session = boto3.session.Session()
    secret_manager = session.client("secretsmanager", region_name="eu-west-2")

    db_credentials = secret_manager.get_secret_value(SecretId=secret_name)

    if "SecretString" not in db_credentials:
        raise ValueError("DB credentials not found")
    
    secret_string = json.loads(db_credentials["SecretString"])

    return {
        "host": secret_string["host"],
        "port": secret_string["port"],
        "dbname": secret_string["database"],
        "user": secret_string["username"],
        "password": secret_string["password"]
    }
