variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for AWS resource naming"
  type        = string
  default     = "devops-portfolio"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "domain_name" {
  description = "Domain registered in Route 53"
  type        = string
  default     = "mohanad-portfolio.click"
}


variable "github_connection_arn" {
  description = "Existing AWS CodeConnections GitHub connection ARN"
  type        = string
  default     = "arn:aws:codeconnections:us-east-1:116068482301:connection/bb464641-956d-4f47-a27c-5581bb1e3b8f"
}
