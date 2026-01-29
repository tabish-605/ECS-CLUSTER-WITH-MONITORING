#!/bin/bash
set -e

# Variables
CLUSTER_NAME="prod-ecs-cluster"
SERVICE_NAME="dummy-alarm-test-service"
REGION="us-east-1"
ECR_REPO=$(terraform output -raw ecr_repository_url)

echo "Building and pushing Docker image..."
docker build -t dummy-alarm-test-app ./app
docker tag dummy-alarm-test-app:latest ${ECR_REPO}:latest

# Login to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ECR_REPO}

docker push ${ECR_REPO}:latest

echo "Updating ECS service..."
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --force-new-deployment \
    --region $REGION

echo "Waiting for service to stabilize..."
sleep 180

# Get the load balancer endpoint
echo "Getting service endpoint..."
# This would need to query the ALB/Service discovery

echo "Running alarm tests..."
python3 scripts/test_alarms.py \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --region $REGION

echo "Cleanup..."
# Scale down after tests
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --desired-count 1 \
    --region $REGION