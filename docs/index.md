# PRT API Documentation

## Overview

PRT API is a FastAPI application designed to provide a set of REST endpoints to our services allowing database interactions through a central API layer.

Using this service alongside our database ([PRT DB](https://github.com/ONS-Innovation/keh-prt-db)) ensures that our services access data in a consistent and centralised manner.

## Infrastructure

The API is built using FastAPI, which gets deployed to AWS using Terraform. The API makes use of AWS Lambda and API Gateway to provide a serverless architecture that can scale automatically with demand.

For more information on the infrastructure and its integration with other services and the database, please see the [Infrastructure section](./infrastructure.md).

## Authentication + Access Controls (TBC)

The API uses AWS IAM users to manage access to the API endpoints. Each service requiring access to the API must authenticate using AWS credentials, which are then validated by the API Gateway. This model follows a pattern where each service will have its own IAM user with specific permissions to access the API endpoints it needs. This ensures that services only have access to the data and functionality they require, following the principle of least privilege.

For more information on authentication and access controls, please see the [Authentication + Access Controls section](./authentication.md).

**Note:** The specifics of this approach will be added once confirmed during rollout of the API. Documentation will be added detailing where and how IAM policies are provisioned and managed.
