
#!/bin/bash
set -euo pipefail

AWS_REGION="${AWS_REGION:?AWS_REGION is required}"
ECR_REPOSITORY_URI="${ECR_REPOSITORY_URI:?ECR_REPOSITORY_URI is required}"
IMAGE_TAG="${IMAGE_TAG:?IMAGE_TAG is required}"

ECR_REGISTRY="${ECR_REPOSITORY_URI%%/*}"
IMAGE_URI="${ECR_REPOSITORY_URI}:${IMAGE_TAG}"

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "Pulling Docker image..."
docker pull "$IMAGE_URI"

echo "Stopping old container..."
docker rm -f devops-portfolio 2>/dev/null || true

echo "Starting new container..."
docker run -d \
  --name devops-portfolio \
  --restart unless-stopped \
  -p 127.0.0.1:8080:80 \
  "$IMAGE_URI"

echo "Checking website health..."

for attempt in {1..10}; do
  if curl --fail --silent --output /dev/null http://127.0.0.1:8080/; then
    echo "Website is responding successfully!"
    echo "Deployment completed successfully!"
    exit 0
  fi

  echo "Waiting for website... ($attempt/10)"
  sleep 3
done

echo "ERROR: Website health check failed."
docker logs --tail 50 devops-portfolio
exit 1
