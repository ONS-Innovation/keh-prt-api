module "lambda" {
  source = "./lambda/"

  # Variables
  env_name  = var.env_name
  image_tag = var.image_tag
  api_name  = var.api_name
  stage     = var.stage
}

module "api_gateway" {
  source = "./api_gateway/"

  # Variables
  env_name  = var.env_name
  aws_lambda_function_invoke_arn = module.lambda.api_lambda_function_invoke_arn
  aws_lambda_function_name       = module.lambda.api_lambda_function_name
  api_name                       = var.api_name
  stage                          = var.stage

  service_subdomain = var.service_subdomain
  domain            = var.domain
  domain_extension  = var.domain_extension
}