# Use a Python slim base image
FROM python:3.8-slim

# Install curl and file utility
RUN apt-get update && \
    apt-get install -y curl file && \
    apt-get clean

# Download the correct pre-built objinsync binary
RUN curl -L -o /usr/local/bin/objinsync https://github.com/scribd/objinsync/releases/download/v0.1.0/objinsync-linux-amd64 \
    && chmod +x /usr/local/bin/objinsync

# Optionally, verify that the binary is executable
RUN ls -l /usr/local/bin/objinsync

# Check if the binary is working
RUN /usr/local/bin/objinsync --version || echo "objinsync failed to run"

# Optionally, set the entrypoint to objinsync
ENTRYPOINT ["/usr/local/bin/objinsync"]
