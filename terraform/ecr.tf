resource "aws_ecr_repository" "portfolio_repo" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-ecr"
    Environment = "Production"
  }
}

output "ecr_repository_url" {
  description = "URL of the created ECR Repository"
  value       = aws_ecr_repository.portfolio_repo.repository_url
}