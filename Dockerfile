# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variable to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and AWS CLI
RUN apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    fuse \
    python3 \
    python3-pip \
    s3fs \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure FUSE configuration is set up
RUN echo "user_allow_other" >> /etc/fuse.conf

# Optionally, set up the mount point for S3FS
RUN mkdir -p /opt/airflow/dags/ && chmod 777 /opt/airflow/dags

# Set environment variables for AWS credentials
ENV AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY
ENV AWS_REGION=us-east-1

# Create AWS credentials file with environment variables
RUN mkdir -p /root/.aws && \
    echo "AWS_ACCESS_KEY_ID:AWS_SECRET_ACCESS_KEY" > /root/.aws/credentials && \
    chmod 600 /root/.aws/credentials

# Set the entrypoint to run S3FS and keep the container running
ENTRYPOINT ["/bin/sh", "-c", "echo 'Starting S3FS mount...'; s3fs airflow-dags-stage /opt/airflow/dags -o passwd_file=/root/.aws/credentials -o allow_other -o url=https://s3.amazonaws.com && exec /bin/bash"]
