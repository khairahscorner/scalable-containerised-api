#!/bin/bash

# retrieve necessary variables from .env (Modifying for GHA: envs directly set in workflow)
# export $(grep -v '^#' .env | xargs)

# Other variables
REPOSITORY_NAME="$1" # pass in value via script run

echo "Authenticating Docker to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "Building Docker image..."
docker build -t $REPOSITORY_NAME .

echo "Tagging Docker image..."
docker tag $REPOSITORY_NAME:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$REPOSITORY_NAME:latest

echo "Pushing Docker image to Amazon ECR..."
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$REPOSITORY_NAME:latest
echo "Docker image pushed successfully!"

# modifying for GHA
# if ! grep -q "^IMAGE_URL=" .env; then
#   echo "Adding IMAGE_URL to .env file..."
#   echo "\\nIMAGE_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$REPOSITORY_NAME:latest" >> .env
# else
#   echo "IMAGE_URL is already defined in .env file."
# fi

if [[ -z "$IMAGE_URL" ]]; then
  echo "Adding IMAGE_URL to GHA environment..."
  IMAGE_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$REPOSITORY_NAME:latest"

  echo "IMAGE_URL=$IMAGE_URL" >> $GITHUB_ENV
else
  echo "IMAGE_URL is already set in the GHA environment."
fi