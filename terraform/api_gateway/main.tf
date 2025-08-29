

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "${var.stage}-${var.api_name}-gateway"
  description = "API Gateway for ${var.api_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

// TODO: IAM Authorizer

// Setup root resource
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_root_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.aws_lambda_function_invoke_arn
}

// Setup proxy resource to handle all methods
// This will allow the FastAPI application to handle all requests
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.aws_lambda_function_invoke_arn
}

// TODO: Define endpoints which need IAM Auth for access
// Maybe a good idea to think about how we organise this

// Give API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "${var.stage}-${var.api_name}-AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.aws_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}


// Create Deployment for the API Gateway
resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  description = "Deployment for ${var.stage}-${var.api_name}-gateway"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.proxy_root_integration,
    aws_api_gateway_integration.proxy_integration,
  ]

  // This block will cause a redeployment of the API Gateway whenever the main.tf file changes
  // If we move the API method definitions to a different file, this should be pointed there.
  triggers = {
    redeployment = sha1(jsonencode([
      file("main.tf")
    ]))
  }
}

resource "aws_api_gateway_stage" "api_gateway_stage" {
  rest_api_id          = aws_api_gateway_rest_api.api_gateway.id
  stage_name           = var.stage
  deployment_id        = aws_api_gateway_deployment.api_gateway_deployment.id
  xray_tracing_enabled = true

  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      errorMessage   = "$context.error.message"
      errorType      = "$context.error.responseType"
    })
  }
}

resource "aws_api_gateway_method_settings" "api_gateway_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_stage.stage_name

  method_path = "*/*"

  settings {
    metrics_enabled      = true
    logging_level        = "INFO"
    data_trace_enabled   = false
    caching_enabled      = true
    cache_data_encrypted = true
  }
}

// Create Domain Name
resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  domain_name              = "${var.service_subdomain}.${var.domain}.${var.domain_extension}"
  security_policy          = "TLS_1_2"
  regional_certificate_arn = aws_acm_certificate.api_gateway_certificate.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [
    aws_acm_certificate.api_gateway_certificate,
    aws_acm_certificate_validation.cert
  ]
}

// Create Route 53 Record
resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api_gateway_domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_domain.regional_zone_id
    evaluate_target_health = true
  }
}

// Create ACM Certificate
resource "aws_acm_certificate" "api_gateway_certificate" {
  domain_name       = "${var.service_subdomain}.${var.domain}.${var.domain_extension}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

// Create Route53 record for certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_gateway_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain.zone_id
}

// Certificate Validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.api_gateway_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

// Map domain to api gateway stage
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_domain.domain_name
}
