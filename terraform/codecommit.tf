# AWS CodeCommit Git Repository
resource "aws_codecommit_repository" "portfolio_repo" {
  repository_name = var.project_name
  description     = "AWS-native Git repository for DevOps Portfolio"

  tags = {
    Name        = "${var.project_name}-codecommit"
    Environment = "Production"
  }
}

# Output the clone URL
output "codecommit_clone_url_http" {
  description = "HTTP Clone URL for AWS CodeCommit"
  value       = aws_codecommit_repository.portfolio_repo.clone_url_http
}