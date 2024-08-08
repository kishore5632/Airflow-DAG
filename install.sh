#!/bin/bash

# Set environment variables
export ENVIRONMENT=stage
export REDIS_PASSWORD=my_redis_password

# Define the AWS region (AWS credentials will be managed via Kubernetes secrets)
export AWS_REGION=us-east-1

# Add the required repositories
helm repo add apache-airflow https://airflow.apache.org
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deploy Airflow
echo "Deploying Airflow..."
helm upgrade --install airflow apache-airflow/airflow -f /home/ubuntu/data-on-eks/schedulers/terraform/self-managed-airflow/airflow-values.yaml --namespace airflow --create-namespace

# Monitor the deployment
echo "Monitoring the deployment with Minikube dashboard..."
minikube dashboard
