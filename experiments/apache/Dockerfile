# Use a lightweight base image
FROM debian:bullseye-slim

# Install Apache Benchmark
RUN apt-get update && \
    apt-get install -y apache2-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the script files
COPY **/*.json .
COPY bench.sh .

#ENTRYPOINT [ "ab", "-h" ]
