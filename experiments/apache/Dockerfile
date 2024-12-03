# Use a lightweight base image
FROM debian:bullseye-slim

# Install Apache Benchmark
RUN apt-get update && \
    apt-get install -y apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# Copy the script files

# Default command (optional)
CMD ["ab", "-h"]
