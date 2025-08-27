output "api_url" {
  description = "The URL of the API Gateway endpoint"
  value       = "${var.service_subdomain}.${var.domain}.${var.domain_extension}"
}