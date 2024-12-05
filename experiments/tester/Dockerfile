# Build the application from source
FROM golang:latest AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o tester .

# Stage 2: Runtime
FROM scratch

# Set the working directory in the runtime container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=build /app/**/*.json .
COPY --from=build /app/tester .

# Command to run the application
ENTRYPOINT [ "./tester" ]
