# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev

# Copy go mod and sum files
COPY go.mod go.sum* ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
# CGO_ENABLED=1 is required for sqlite3
RUN CGO_ENABLED=1 GOOS=linux go build -o main ./cmd/api/main.go

# Run stage
FROM alpine:latest

RUN apk add --no-cache ca-certificates libc6-compat

WORKDIR /root/

# Copy the pre-built binary
COPY --from=builder /app/main .

# Expose port 8080
EXPOSE 8080

# Command to run the executable
CMD ["./main"]
