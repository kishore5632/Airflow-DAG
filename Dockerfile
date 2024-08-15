FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY
ENV AWS_REGION=ap-south-1

# Install necessary packages
RUN apt-get update && apt-get install -y \
    fuse \
    libfuse-dev \
    curl \
    build-essential \
    pkg-config \
    kmod \
    && rm -rf /var/lib/apt/lists/*

# Install Goofys
RUN curl -L -o /usr/local/bin/goofys https://github.com/kahing/goofys/releases/download/v0.24.0/goofys \
    && chmod +x /usr/local/bin/goofys

# Allow non-root users to mount FUSE filesystems
RUN echo "user_allow_other" >> /etc/fuse.conf

# Create mount point
RUN mkdir -p /opt/airflow/dags

# Create a startup script
RUN echo '#!/bin/bash\n\
modprobe fuse || (echo "FUSE module is not loaded"; exit 1)\n\
/usr/local/bin/goofys -f --debug_s3 --endpoint https://s3.ap-south-1.amazonaws.com airflow-dags-stage /opt/airflow/dags\n\
' > /start.sh && chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
