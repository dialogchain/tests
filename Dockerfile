# Use a specific version of Ubuntu LTS as base
FROM ubuntu:22.04

# Set non-interactive frontend for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools and Python
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3 \
    python3-pip \
    python3-venv \
    make \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the test script
COPY test_make_in_docker.sh .
RUN chmod +x test_make_in_docker.sh

# Default command
CMD ["/bin/bash", "-c", "./test_make_in_docker.sh"]
