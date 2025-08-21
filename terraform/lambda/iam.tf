data "aws_iam_policy_document" "api_lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_lambda_role" {
  name               = "${var.env_name}-${var.api_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.api_lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "vpc_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface",
      "ec2:CreateTags"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "vpc_permissions" {
  name        = "${var.env_name}-${var.api_name}-vpc-permissions"
  description = "IAM policy for VPC permissions for ${var.api_name} Lambda function"
  policy      = data.aws_iam_policy_document.vpc_permissions.json
}

resource "aws_iam_role_policy_attachment" "vpc_policy" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = aws_iam_policy.vpc_permissions.arn
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.api_lambda_log_group.arn,
    ]
  }
}

resource "aws_iam_policy" "api_lambda_logging_policy" {
  name        = "${var.env_name}-${var.api_name}-lambda-logging-policy"
  description = "Policy for ${var.api_name} Lambda logging"

  policy = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "api_lambda_logging_attachment" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = aws_iam_policy.api_lambda_logging_policy.arn
}
