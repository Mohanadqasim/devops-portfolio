#!/bin/bash
# Update system & install required tools
sudo apt-get update -y
sudo apt-get install -y certbot python3-certbot-nginx curl gnupg lsb-release unzip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker daemon
sudo systemctl enable docker
sudo systemctl start docker

# Generate Free Let's Encrypt SSL Certificate
DOMAIN="mohanad-portfolio.click"
EMAIL="mohanad.qasim.1@gmail.com" # Replace with your email address

sudo certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL

# Authenticate and pull ECR image
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/devops-portfolio:latest"

until aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com; do
    sleep 10
done

until docker pull $ECR_URI; do
    sleep 15
done

# Run container mapping HTTP (80) and HTTPS (443)
docker run -d --name portfolio-web \
  -p 80:80 -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  --restart unless-stopped $ECR_URI