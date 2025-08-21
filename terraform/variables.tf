variable "image_tag" {
  description = "Docker image tag for the Lambda function"
  type        = string
  default     = "latest"
}

variable "env_name" {
  description = "AWS environment"
  type        = string
  default     = "sdp-dev"
}

variable "api_name" {
  description = "API name"
  type        = string
  default     = "prt_api"
}

variable "stage" {
  description = "API Gateway stage"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_tag" {
  description = "Project"
  type        = string
  default     = "SDP"
}

variable "team_owner_tag" {
  description = "Team Owner"
  type        = string
  default     = "Knowledge Exchange Hub"
}

variable "business_owner_tag" {
  description = "Business Owner"
  type        = string
  default     = "DST"
}