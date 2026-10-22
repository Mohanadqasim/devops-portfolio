# 1. IAM role for AWS CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-codebuild-role"
  }
}

# 2. IAM policy for CodeBuild
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRAuthentication"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = aws_ecr_repository.portfolio.arn
      },
      {
        Sid    = "GitHubConnection"
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection",
          "codeconnections:PassConnection",
          "codeconnections:GetConnectionToken"
        ]
        Resource = var.github_connection_arn
      },
      {
        Sid    = "SSMDeployment"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript",
          aws_instance.portfolio.arn
        ]
      },
      {
        Sid    = "SSMCommandStatus"
        Effect = "Allow"
        Action = [
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      }
    ]
  })
}

# 3. Create the AWS CodeBuild project
resource "aws_codebuild_project" "portfolio" {
  name          = "${var.project_name}-build"
  description   = "Build Docker images and deploy DevOps portfolio"
  build_timeout = 10
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_REGISTRY"
      value = split("/", aws_ecr_repository.portfolio.repository_url)[0]
    }

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = aws_ecr_repository.portfolio.repository_url
    }

    environment_variable {
      name  = "EC2_INSTANCE_ID"
      value = aws_instance.portfolio.id
    }
  }

  source {
    type                = "GITHUB"
    location            = "https://github.com/Mohanadqasim/devops-portfolio.git"
    git_clone_depth     = 1
    buildspec           = "buildspec.yml"
    report_build_status = true
  }
  source_version = "refs/heads/main"

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = {
    Name = "${var.project_name}-build"
  }

  depends_on = [
    aws_iam_role_policy.codebuild_policy
  ]
}

# 4. Trigger CodeBuild automatically on GitHub pushes
resource "aws_codebuild_webhook" "portfolio" {
  project_name = aws_codebuild_project.portfolio.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "^refs/heads/main$"
    }
  }
}