# Projects, Repositories and Technologies API (prt_api)

A FastAPI application used to access PRT_DB, built on top of AWS Serverless architecture.
This API integrates with [PRT_DB](https://github.com/ONS-Innovation/keh-prt-db).

## Contents

- [Projects, Repositories and Technologies API (prt\_api)](#projects-repositories-and-technologies-api-prt_api)
  - [Contents](#contents)
  - [Project Structure](#project-structure)
  - [Local Development](#local-development)
    - [Contributing](#contributing)
    - [Prerequisites](#prerequisites)
    - [Getting Started](#getting-started)
  - [Deployment to AWS](#deployment-to-aws)
    - [Push Docker Image to ECR](#push-docker-image-to-ecr)
    - [Terraform](#terraform)
  - [IP Whitelisting to Access API Gateway Locally](#ip-whitelisting-to-access-api-gateway-locally)
  - [Documentation](#documentation)
    - [Documentation Deployment](#documentation-deployment)
  - [Linting and Formatting](#linting-and-formatting)
    - [Python Linting](#python-linting)
    - [Markdown Linting](#markdown-linting)
    - [Megalinter](#megalinter)
    - [Linting GitHub Actions](#linting-github-actions)
  - [Testing](#testing)
    - [Unit Testing](#unit-testing)

## Project Structure

The project is structured as follows:

```bash
keh-prt-api/
├── src/                              # Source code for the FastAPI application
│   ├── main.py                       # Entry point for the FastAPI application
│   └── api/                          # Contains API routes and logic
│       └── v0/                       # Versioned API routes
│           ├── api.py                # Main API router
│           └── endpoints/            # Individual API endpoint definitions
│               ├── <endpoint>.py     # Endpoint module (e.g., projects.py for project endpoints)
│               └── utils/            # Shared utility functions for endpoints
│                   └── <utility>.py  # Utility module (e.g., db.py for database utilities)
└── terraform/                        # Terraform configuration files for AWS infrastructure
    ├── api_gateway/                  # API Gateway configuration
    │   └── ...
    ├── lambda/                       # Lambda function configuration
    │   └── ...
    └── ...                           # Other Terraform configurations and modules
```

## Local Development

### Contributing

Contributions to this project are welcome. Please read the [CONTRIBUTING](./.github/CONTRIBUTING.md) file for more information on how to contribute and the standards we expect.

### Prerequisites

- Python 3.12 or higher
- [Poetry](https://python-poetry.org/) for dependency management
  - Must use Poetry v2.1 or higher (this can be checked using `poetry --version`)

### Getting Started

To get started with the API, follow these steps:

1. Create and activate a Python virtual environment.

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

2. Install the required dependencies.

    ```bash
    poetry install --only main
    ```

3. Run the FastAPI application.

    ```bash
    uvicorn src.main:app --reload
    ```

4. Open your browser and navigate to `http://localhost:8000/docs` to view the API documentation and test the endpoints.

## Deployment to AWS

### Push Docker Image to ECR

To deploy the API to AWS, we need to first build a Docker image and push it to Amazon Elastic Container Registry (ECR).

**Note:** These commands can be found within AWS ECR's console under the "View push commands" section.

1. Login to AWS ECR:

    ```bash
    aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
    ```

    **Note:** This requires the AWS CLI to be installed and configured with your AWS credentials. You can export them using:

    ```bash
    export AWS_ACCESS_KEY_ID=<your-access-key-id>
    export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
    ```

2. Build the Docker image:

    ```bash
    docker build -t <your-image-name> .
    ```

3. Tag the Docker image:

    ```bash
    docker tag <your-image-name>:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<repository-name>:<tag>
    ```

4. Push the Docker image to ECR:

    ```bash
    docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<repository-name>:<tag>
    ```

### Terraform

Terraform is used to manage the AWS infrastructure required to resource the API. A guide on using Terraform can be found within [./terraform/README.md](./terraform/README.md).

## IP Whitelisting to Access API Gateway Locally

Once the terraform configuration has been applied, you will need to whitelist your IP address to access the API Gateway.

This is enforced using an AWS WAF rule that allows access only from specific IP addresses. If you try to access the API Gateway without whitelisting your IP, you will receive a `403 Forbidden` error.

Within the AWS console, navigate to `WAF & Shield` > `IP sets` > `<env_name>-<api_name>-ip-set` and add your IP address to the set.

Once your IP address is added, you should be able to access the API.

## Documentation

This repository uses MkDocs for documentation.

The documentation is located in the `docs/` directory and can be served locally using the following:

1. Create and activate a virtual environment:

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

2. Install dependencies

    ```bash
    poetry install --only docs
    ```

3. Serve the documentation

    ```bash
    mkdocs serve
    ```

This will start a local development server and you can view the documentation at `http://localhost:8000`.

### Documentation Deployment

This repository hosts its documentation using GitHub Pages. The documentation is built and deployed using a GitHub Action that is triggered on every push to the `main` branch.

This is available within [`.github/workflows/deploy_mkdocs.yml`](.github/workflows/deploy_mkdocs.yml).

## Linting and Formatting

Before linting or formatting, ensure you have the development dependencies installed:

```bash
poetry install --only dev
```

Or if you want to install all dependencies (including main and docs):

```bash
poetry install
```

### Python Linting

This repository uses the following linters for Python:

- [Black](https://github.com/psf/black) : Code formatting
- [Ruff](https://github.com/astral-sh/ruff) : Linting + Code formatting (this should eventually replace Black)
- [MyPy](https://github.com/python/mypy) : Static type checking

Run the linter using the following commands:

```bash
make py_lint # Run all Python linters
```

```bash
make py_fix # Run all Python linters and fix issues
```

### Markdown Linting

This repository uses [Markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) for linting Markdown files.

Run the linter using the following commands:

```bash
make md_lint # Run Markdown linter
```

```bash
make md_fix # Run Markdown linter and fix issues
```

### Megalinter

This repository also makes use of [Megalinter](https://github.com/oxsecurity/megalinter) as a "catch all" linter.
This will deal with any linting issues that are not covered by the other linters.

Run the linter using the following commands:

```bash
make megalint
```

### Linting GitHub Actions

All linters are run automatically via GitHub Actions on every push and pull request to the `main` branch.

These workflows can be found in the `.github/workflows/` directory.

## Testing

### Unit Testing

This repository uses Pytest for unit testing.

To run the tests, use the following command:

```bash
make test
```

These tests also get run automatically via GitHub Actions on every push and pull request to the `main` branch.
If the test coverage is below 80%, the GitHub Action will fail, indicating that additional tests are needed to meet the coverage requirement.
