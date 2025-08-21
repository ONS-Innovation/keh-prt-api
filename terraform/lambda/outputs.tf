output "api_lambda_function_name" {
  value = aws_lambda_function.api_lambda.function_name
}

output "api_lambda_function_arn" {
  value = aws_lambda_function.api_lambda.arn
}

output "api_lambda_function_invoke_arn" {
  value = aws_lambda_function.api_lambda.invoke_arn
}

output "api_lambda_log_group_name" {
  value = aws_cloudwatch_log_group.api_lambda_log_group.name
}

output "api_lambda_role_name" {
  value = aws_iam_role.api_lambda_role.name
}