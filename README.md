# Projects, Repositories and Technologies API (prt_api)

A FastAPI application used to access PRT_DB, built on top of AWS Serverless architecture.
This API integrates with [PRT_DB](https://github.com/ONS-Innovation/keh-prt-db).

## Contents

- [Projects, Repositories and Technologies API (prt\_api)](#projects-repositories-and-technologies-api-prt_api)
  - [Contents](#contents)
  - [Project Structure](#project-structure)
  - [Local Development](#local-development)
    - [Contributing](#contributing)
    - [Getting Started](#getting-started)
  - [Deployment to AWS](#deployment-to-aws)
    - [Push Docker Image to ECR](#push-docker-image-to-ecr)
    - [Terraform](#terraform)
      - [Variables](#variables)
      - [Applying Terraform Configuration](#applying-terraform-configuration)
      - [Cleanup](#cleanup)
  - [IP Whitelisting to Access API Gateway Locally](#ip-whitelisting-to-access-api-gateway-locally)
  - [Documentation](#documentation)
    - [Documentation Deployment](#documentation-deployment)
  - [Linting and Formatting](#linting-and-formatting)
    - [Python Linting](#python-linting)
    - [Markdown Linting](#markdown-linting)
    - [Megalinter](#megalinter)
    - [Linting GitHub Actions](#linting-github-actions)

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

### Getting Started

To get started with the API, follow these steps:

1. Create and activate a Python virtual environment.

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

2. Install the required dependencies.

    ```bash
    poetry install
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

Terraform is used to manage the AWS infrastructure required to resource the API. This can be found within the `terraform/` directory.

The project makes use of Terraform modules to manage infrastructure, with separate modules for the lambda function and API Gateway.

#### Variables

The following Terraform variables are used to configure the API deployment:

- `env_name`: The environment name (i.e. `sdp-dev` or `sdp-prod`)
- `image_tag`: The tag of the Docker image to be deployed (i.e. `v0.0.1`)
- `api_name`: The name of the API
  - This is also used to find the correct ECR repository using the following pattern:
    `<env-name>-<api-name>`

    (i.e. `sdp-dev-prt-api`)
- `stage`: The deployment stage (e.g. `dev`, `prod`)
- `service_subdomain`: The subdomain for the API Gateway
- `domain`: The domain name for the API

A full list of variables can be found within the `variables.tf` file at the root of the terraform directory.

These variables can be configured using a `.tfvars` file. See `/env/dev/dev.tfvars.txt` for an example.

**Note:** `.tfvars` files should *never* be committed to version control. Take extra care when handling these files.

#### Applying Terraform Configuration

Now that the Docker image is in ECR, we can use Terraform to resource the necessary AWS infrastructure to run the API.

1. Change to the `terraform/` directory:

    ```bash
    cd terraform/
    ```

2. Initialize Terraform:

    ```bash
    terraform init -backend-config="env/<env>/backend-<env>.tfbackend" -reconfigure
    ```

3. Refresh the Terraform state:

    ```bash
    terraform refresh -var-file="env/<env>/<env>.tfvars"
    ```

4. Plan the Terraform deployment:

    ```bash
    terraform plan -var-file="env/<env>/<env>.tfvars"
    ```

5. Apply the Terraform deployment:

    ```bash
    terraform apply -var-file="env/<env>/<env>.tfvars"
    ```

6. Once the deployment is complete, you can access the API using the URL provided in the output of the `terraform apply` command.

#### Cleanup

To clean up the resources created by Terraform, you can run:

```bash
terraform destroy -var-file="env/<env>/<env>.tfvars"
```

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
