# Use a Python slim base image
FROM python:3.8-slim

# Install dependencies and AWS CLI
RUN apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    fuse \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Goofys
RUN curl -LO https://github.com/kahing/goofys/releases/latest/download/goofys && \
    chmod +x goofys && \
    mv goofys /usr/local/bin/goofys

# Optionally, set up the mount point for Goofys
RUN mkdir -p /opt/airflow/dags

# Set environment variables for AWS credentials
ENV AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY
ENV AWS_REGION=us-east-1

# Set the entrypoint to mount the S3 bucket
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/goofys s3://airflow-dags-stage/dags /opt/airflow/dags"]
