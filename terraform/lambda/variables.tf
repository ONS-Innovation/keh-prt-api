variable "env_name" {
  description = "AWS environment"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag for the Lambda function"
  type        = string
  default     = "latest"
}

variable "api_name" {
  description = "API name"
  type        = string
  default     = "prt_api"
}