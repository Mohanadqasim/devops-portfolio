# 1. Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 2. Create the EC2 instance
resource "aws_instance" "portfolio" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.portfolio.id]
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }

  # Attach the IAM role for SSM and ECR access
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Require IMDSv2 for better security
  metadata_options {
    http_tokens = "required"
  }

  # Install Docker and prepare the deployment script

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    deploy_script = file("${path.module}/../deploy.sh")
    domain_name   = var.domain_name
  })


  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy_attachment.ecr_read
  ]
}

# 3. Allocate a stable public IP address
resource "aws_eip" "portfolio" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

# 4. Associate the Elastic IP with EC2
resource "aws_eip_association" "portfolio" {
  instance_id   = aws_instance.portfolio.id
  allocation_id = aws_eip.portfolio.id
}