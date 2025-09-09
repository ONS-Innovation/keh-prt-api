// Get ECR repository containing lambda
data "aws_ecr_repository" "api_ecr" {
  name = "${var.env_name}-${var.api_name}"
}

// Get VPC stuff from sdp-infrastructure terraform state
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.env_name}-tf-state"
    key    = "${var.env_name}-ecs-infra/terraform.tfstate"
    region = "eu-west-2"
  }
}

// Get DB Credentials secret name from prt_db terraform state
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "${var.env_name}-tf-state"
    key    = "${var.env_name}-prt-db-rds/terraform.tfstate"
    region = "eu-west-2"
  }
}