terraform {
  backend "s3" {
    # Controlled within .tfbackend file
  }

  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.2.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "Project"       = var.project_tag
      "TeamOwner"     = var.team_owner_tag
      "BusinessOwner" = var.business_owner_tag
      "Service"       = "${var.project_tag}-${var.api_name}"
      "Environment"   = var.env_name
      "Terraform"     = "true"
    }
  }
}