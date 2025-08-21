variable "aws_lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lambda function to be invoked by the API Gateway"
  type        = string
}

variable "aws_lambda_function_name" {
  description = "The name of the Lambda function to be invoked by the API Gateway"
  type        = string
}

variable "api_name" {
  description = "The name of the API"
  type        = string
  default     = "prt_api"
}

variable "stage" {
  description = "The stage of the API"
  type        = string
  default     = "dev"
}