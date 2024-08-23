FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY
ENV AWS_REGION=ap-south-1

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    fuse \
    libfuse-dev \
    kmod \
    && rm -rf /var/lib/apt/lists/*

# Install Rclone
RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip \
    && unzip rclone-current-linux-amd64.zip \
    && cd rclone-*-linux-amd64 \
    && cp rclone /usr/local/bin/ \
    && chown root:root /usr/local/bin/rclone \
    && chmod 755 /usr/local/bin/rclone \
    && rm -rf rclone-current-linux-amd64.zip rclone-*-linux-amd64

# Allow non-root users to mount FUSE filesystems
RUN echo "user_allow_other" >> /etc/fuse.conf

# Create mount point
RUN mkdir -p /opt/airflow/dags /var/log

# Create Rclone config file
RUN mkdir -p /root/.config/rclone \
    && echo "[s3]" > /root/.config/rclone/rclone.conf \
    && echo "type = s3" >> /root/.config/rclone/rclone.conf \
    && echo "provider = AWS" >> /root/.config/rclone/rclone.conf \
    && echo "env_auth = true" >> /root/.config/rclone/rclone.conf \
    && echo "region = ap-south-1" >> /root/.config/rclone/rclone.conf \
    && echo "acl = private" >> /root/.config/rclone/rclone.conf \
    && echo "storage_class = STANDARD" >> /root/.config/rclone/rclone.conf \
    && chmod 600 /root/.config/rclone/rclone.conf  # Ensure config file permissions

# Create a startup script
RUN echo '#!/bin/bash\n\
echo "Starting script...\n" > /var/log/startup.log\n\
modprobe fuse || (echo "FUSE module is not loaded"; exit 1)\n\
while true; do \n\
    echo "Starting rclone sync..." | tee -a /var/log/rclone-sync.log\n\
    rclone sync /opt/airflow/dags s3:airflow-dags-stage --config /root/.config/rclone/rclone.conf --use-server-modtime --transfers 16 --checkers 8 --bwlimit 10M --tpslimit 10 --log-level INFO --log-file /var/log/rclone-sync.log || (echo "Rclone sync failed" | tee -a /var/log/rclone-sync.log)\n\
    echo "Sync completed. Waiting for 10 seconds..." | tee -a /var/log/rclone-sync.log\n\
    sleep 10\n\
done\n\
' > /start.sh && chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
