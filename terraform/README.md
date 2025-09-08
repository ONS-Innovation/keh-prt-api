# Terraform

Terraform is used to manage the AWS infrastructure required to resource the API.

The project makes use of Terraform modules to manage infrastructure, with separate modules for the lambda function and API Gateway.

## Variables

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

2. Initialise Terraform:

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

## Cleanup

To clean up the resources created by Terraform, you can run:

```bash
terraform destroy -var-file="env/<env>/<env>.tfvars"
```