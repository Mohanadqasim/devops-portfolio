# IAM Role for EC2
resource "aws_iam_role" "ec2_ecr_role" {
  name = "${var.project_name}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach ECR ReadOnly Policy
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# Ubuntu 22.04 LTS AMI Lookup
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 Instance
resource "aws_instance" "portfolio_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("${path.module}/user_data.sh")

  tags = {
    Name = "${var.project_name}-server"
  }
}

# Elastic IP
resource "aws_eip" "portfolio_eip" {
  instance = aws_instance.portfolio_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

output "ec2_public_ip" {
  description = "Public Elastic IP of EC2 Instance"
  value       = aws_eip.portfolio_eip.public_ip
}