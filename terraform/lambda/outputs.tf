output "api_lambda_function_name" {
  description = "The name of the API Lambda function"
  value       = aws_lambda_function.api_lambda.function_name
}

output "api_lambda_function_arn" {
  description = "The ARN of the API Lambda function"
  value       = aws_lambda_function.api_lambda.arn
}

output "api_lambda_function_invoke_arn" {
  description = "The invoke ARN of the API Lambda function"
  value       = aws_lambda_function.api_lambda.invoke_arn
}

output "api_lambda_log_group_name" {
  description = "The name of the CloudWatch log group for the API Lambda function"
  value       = aws_cloudwatch_log_group.api_lambda_log_group.name
}

output "api_lambda_role_name" {
  description = "The name of the IAM role for the API Lambda function"
  value       = aws_iam_role.api_lambda_role.name
}