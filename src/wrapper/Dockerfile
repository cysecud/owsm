# Stage 1: Build
FROM golang:latest AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy Go modules manifests
COPY go.mod go.sum ./

# Download and cache dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o owsm .

# Stage 2: Runtime
FROM scratch

# Set the working directory in the runtime container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/owsm /app/owsm

# Expose the necessary port (if applicable)
EXPOSE 8080

# Set non privileged user
USER nonroot:nonroot

# Command to run the application
ENTRYPOINT [ "./owsm" ]
