// CloudWatch log group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api_gateway/${var.stage}/${var.api_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "cloudwatch" {
  name = "${var.stage}-${var.api_name}-cloudwatch_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

// IAM role and policy to give API Gateway permissions to write to the CloudWatch log group created above
resource "aws_iam_policy" "cloudwatch" {
  name = "${var.stage}-${var.api_name}-cloudwatch_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect = "Allow"
      Resource = [
        "${aws_cloudwatch_log_group.api_gateway.arn}:*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}