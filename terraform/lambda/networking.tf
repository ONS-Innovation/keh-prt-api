resource "aws_security_group" "lambda_sg" {
  name        = "${var.env_name}-${var.api_name}-lambda-sg"
  description = "Security group for ${var.api_name} Lambda function"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow HTTPS traffic within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] // Allow HTTPS traffic within VPC
  }
  egress {
    description = "Allow all outbound HTTPS traffic to any destination"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow all outbound HTTPS traffic
  }
}
