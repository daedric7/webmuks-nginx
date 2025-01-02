# Stage 1: Clone and build the Go project
FROM golang:1.23.4 AS builder

# Set the working directory inside the container
WORKDIR /app

# Install required tools (git, curl, Node.js, and npm)
RUN apt-get update && apt-get install -y \
    git \
    curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/tulir/gomuks.git /app

# Ensure Go modules are downloaded
RUN go mod download

# Install Node.js dependencies (if needed)
WORKDIR /app/web
RUN npm install

# Run go generate to compile the pages
WORKDIR /app
RUN go generate ./web

# Stage 2: Serve the compiled files with Nginx
FROM nginx:1.25

# Copy the compiled files from the builder stage to the Nginx container
COPY --from=builder /app/web/dist /usr/share/nginx/html

# Expose port 80 for the Nginx container
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
