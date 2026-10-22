# Security group for the EC2 portfolio server
resource "aws_security_group" "portfolio" {
  name        = "${var.project_name}-sg"
  description = "Security group for DevOps portfolio EC2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Allow HTTP traffic
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.portfolio.id
  description       = "Allow HTTP from the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# Allow HTTPS traffic
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.portfolio.id
  description       = "Allow HTTPS from the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.portfolio.id
  description       = "Allow outbound internet access"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}