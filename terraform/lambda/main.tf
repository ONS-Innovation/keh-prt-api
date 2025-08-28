resource "aws_lambda_function" "api_lambda" {
  function_name = "${var.env_name}-${var.api_name}-lambda"
  role          = aws_iam_role.api_lambda_role.arn
  image_uri     = "${data.aws_ecr_repository.api_ecr.repository_url}:${var.image_tag}"
  package_type  = "Image"
  architectures = ["x86_64"]
  timeout       = 30
  reserved_concurrent_executions = 100

  logging_config {
    log_format = "JSON"
  }
  vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      ENVIRONMENT    = var.stage
      DB_SECRET_NAME = data.terraform_remote_state.db.outputs.db_credentials_secret_name
    }
  }
}

resource "aws_cloudwatch_log_group" "api_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.api_lambda.function_name}"
  retention_in_days = 14
}
