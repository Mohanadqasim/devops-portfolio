variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name tag prefix"
  type        = string
  default     = "devops-portfolio"
}

variable "instance_type" {
  description = "EC2 Instance size"
  type        = string
  default     = "t2.micro"
}