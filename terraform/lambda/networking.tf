// Lambda security group
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

  tags = {
    Name = "${var.env_name}-${var.api_name}-lambda-sg"
  }
}

// Egress rule on lambda to talk to db security group
resource "aws_vpc_security_group_egress_rule" "lambda_to_db_egress" {
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.lambda_sg.id
  referenced_security_group_id = data.terraform_remote_state.db.outputs.db_security_group_id
  description                  = "Allow Lambda to communicate with RDS"
}

// Ingress rule on db to talk to lambda security group
resource "aws_vpc_security_group_ingress_rule" "db_to_lambda_ingress" {
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  security_group_id            = data.terraform_remote_state.db.outputs.db_security_group_id
  referenced_security_group_id = aws_security_group.lambda_sg.id
  description                  = "Allow RDS to communicate with Lambda"
}
