# Stage 1: Build the application
FROM golang:1.17 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o order-api .

# Stage 2: Run the build binary in a distroless image
FROM gcr.io/distroless/base-debian11

# Set environment variables
ENV DBHOST=localhost \
    DBPORT=5432 \
    DBUSER=postgres \
    DBPASS=postgres \
    DBNAME=postgres \
    ORDERSERVICEHOST=localhost \
    ORDERSERVICEPORT=8001

# Expose the port on which the service will run
EXPOSE 8001

# Copy the compiled binary from the builder stage
COPY --from=builder /app/order-api /

# Command to run the executable
CMD ["/order-api"]
