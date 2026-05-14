# Docker Cheat Sheet

Essential Docker commands for container operations and GCP deployments.

## 🐳 Docker Basics

### Installation & Setup
```bash
# Install Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker info
docker run hello-world
```

### Authentication
```bash
# Login to registries
docker login                                    # Docker Hub
docker login gcr.io                          # Google Container Registry
docker login us.gcr.io                        # US region GCR
docker login eu.gcr.io                        # EU region GCR

# Logout
docker logout
docker logout gcr.io
```

## 📦 Image Operations

### Building Images
```bash
# Basic build
docker build -t my-image:latest .               # Build from Dockerfile
docker build -t my-image:v1.0 .                 # With tag
docker build -f Dockerfile.prod -t my-image .   # Custom Dockerfile

# Build options
docker build --no-cache -t my-image .           # No cache
docker build --pull -t my-image .               # Pull base images
docker build --build-arg VERSION=1.0 -t my-image . # Build args

# Multi-stage builds
docker build --target builder -t my-builder .   # Build specific stage
```

### Image Management
```bash
# List images
docker images                                   # All images
docker images -a                                # All images (including intermediates)
docker images --filter "dangling=true"          # Dangling images

# Image information
docker inspect my-image                         # Image details
docker history my-image                         # Build history
docker inspect my-image | jq '.[0].Config.Env'  # Environment variables

# Image operations
docker tag my-image:latest my-image:v1.0        # Tag image
docker rmi my-image:v1.0                       # Remove image
docker rmi $(docker images -q)                 # Remove all images
docker image prune                             # Remove dangling images
docker image prune -a                          # Remove unused images
```

### Image Registry
```bash
# Push to registry
docker push my-image:latest                     # Push to configured registry
docker push gcr.io/PROJECT_ID/my-image:v1.0    # Push to GCR

# Pull from registry
docker pull nginx:latest                        # Pull from Docker Hub
docker pull gcr.io/PROJECT_ID/my-image:v1.0     # Pull from GCR

# Registry operations
docker search nginx                             # Search Docker Hub
gcloud container images list                    # List GCR images
gcloud container images list-tags gcr.io/PROJECT_ID/my-image
```

## 🚀 Container Operations

### Running Containers
```bash
# Basic run
docker run nginx                                # Run container
docker run -d nginx                             # Run in background
docker run --name my-nginx nginx                 # Named container
docker run -p 8080:80 nginx                      # Port mapping

# Environment and volumes
docker run -e ENV_VAR=value nginx                # Environment variable
docker run -v /host/path:/container/path nginx   # Volume mount
docker run --env-file .env nginx                 # Environment file

# Resource limits
docker run --memory=512m --cpus=0.5 nginx        # Resource limits
docker run --restart=always nginx                # Restart policy
```

### Container Management
```bash
# List containers
docker ps                                       # Running containers
docker ps -a                                    # All containers
docker ps -q                                    # Container IDs only

# Container information
docker inspect my-container                      # Container details
docker logs my-container                         # Container logs
docker logs -f my-container                      # Follow logs
docker stats my-container                        # Resource usage

# Container operations
docker start my-container                        # Start container
docker stop my-container                         # Stop container
docker restart my-container                      # Restart container
docker pause my-container                        # Pause container
docker unpause my-container                      # Unpause container
docker kill my-container                         # Kill container
```

### Interactive Operations
```bash
# Execute commands
docker exec my-container ls -la                  # Run command
docker exec -it my-container /bin/bash           # Interactive shell
docker exec -it my-container sh                  # Alternative shell

# Attach to container
docker attach my-container                       # Attach to running container

# Copy files
docker cp my-container:/app/file.txt ./file.txt  # Copy from container
docker cp ./file.txt my-container:/app/file.txt  # Copy to container
```

## 🏗️ Dockerfile Best Practices

### Basic Dockerfile
```dockerfile
# Use official base image
FROM openjdk:17-jdk-alpine

# Set working directory
WORKDIR /app

# Copy source code
COPY pom.xml .
COPY src ./src

# Build application
RUN ./mvnw clean package -DskipTests

# Copy JAR file
COPY --from=builder /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run application
CMD ["java", "-jar", "app.jar"]
```

### Multi-stage Dockerfile
```dockerfile
# Build stage
FROM maven:3.8-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

### Optimization Techniques
```dockerfile
# Use .dockerignore
# .dockerignore
target/
*.log
.git/

# Order commands for caching
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

COPY package.json .
RUN npm install
COPY . .

# Use multi-stage builds
# Combine RUN commands
# Use specific tags
```

## 🔄 Docker Compose

### Basic docker-compose.yml
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Compose Commands
```bash
# Basic operations
docker-compose up                              # Start services
docker-compose up -d                           # Start in background
docker-compose down                            # Stop services
docker-compose build                           # Build services
docker-compose pull                            # Pull images

# Service management
docker-compose ps                              # List services
docker-compose logs                            # View logs
docker-compose logs -f web                     # Follow service logs
docker-compose exec web bash                   # Execute in service
docker-compose restart web                     # Restart service

# Scaling
docker-compose up -d --scale web=3             # Scale service
```

## 🏷️ Image Tagging & Versioning

### Tagging Strategies
```bash
# Semantic versioning
docker tag my-image:latest my-image:v1.0.0
docker tag my-image:latest my-image:v1.0
docker tag my-image:latest my-image:v1

# Git-based tagging
GIT_COMMIT=$(git rev-parse --short HEAD)
docker tag my-image:latest my-image:$GIT_COMMIT
docker tag my-image:latest my-image:$(git describe --tags)

# Date-based tagging
docker tag my-image:latest my-image:$(date +%Y%m%d-%H%M%S)
```

### Registry Organization
```bash
# Google Container Registry
docker tag my-image gcr.io/PROJECT_ID/my-image:v1.0
docker push gcr.io/PROJECT_ID/my-image:v1.0

# Artifact Registry
docker tag my-image us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-image:v1.0
docker push us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-image:v1.0
```

## 🔧 Advanced Operations

### Networking
```bash
# Network management
docker network ls                              # List networks
docker network create my-network                # Create network
docker network inspect my-network               # Network details
docker run --network my-network nginx           # Connect to network

# Container networking
docker run --link db:database nginx              # Legacy linking
docker run --network container:db nginx          # Shared network
```

### Volumes & Storage
```bash
# Volume operations
docker volume ls                                # List volumes
docker volume create my-volume                   # Create volume
docker volume inspect my-volume                  # Volume details
docker run -v my-volume:/data nginx              # Use volume

# Bind mounts
docker run -v /host/path:/container/path nginx   # Bind mount
docker run -v /host/path:/container/path:ro nginx # Read-only mount
```

### Security
```bash
# Run as non-root
docker run --user 1001:1001 nginx                # Specific user
docker run --read-only nginx                     # Read-only filesystem
docker run --tmpfs /tmp nginx                    # Temporary filesystem

# Security scanning
docker scan my-image                             # Vulnerability scan
gcloud container images describe gcr.io/PROJECT_ID/my-image --show-package-vulnerability
```

## 🚨 Troubleshooting

### Common Issues
```bash
# Container won't start
docker logs my-container                         # Check logs
docker inspect my-container | jq '.[0].State'    # Check state

# Port conflicts
docker ps -a | grep :8080                         # Check port usage
netstat -tlnp | grep :8080                       # System port usage

# Image build failures
docker build --no-cache -t my-image .             # Skip cache
docker build --progress=plain -t my-image .      # Detailed output
```

### Debug Commands
```bash
# Container debugging
docker run -it --entrypoint /bin/bash my-image    # Debug image
docker exec -it my-container /bin/bash            # Debug running container

# System cleanup
docker system df                                 # Disk usage
docker system prune                              # Remove unused data
docker system prune -a --volumes                 # Aggressive cleanup
```

## 📋 CI/CD Integration

### GitHub Actions Example
```yaml
name: Build and Push Docker Image
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build Docker Image
      run: docker build -t my-image:${{ github.sha }} .
    - name: Push to GCR
      run: |
        gcloud auth configure-docker
        docker tag my-image:${{ github.sha }} gcr.io/PROJECT_ID/my-image:${{ github.sha }}
        docker push gcr.io/PROJECT_ID/my-image:${{ github.sha }}
```

### Cloud Build Example
```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/my-image:$COMMIT_SHA', '.']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/my-image:$COMMIT_SHA']
```

---

**Pro Tips:**
- Use multi-stage builds to reduce image size
- Always specify image tags (avoid `latest`)
- Use `.dockerignore` to exclude unnecessary files
- Run containers as non-root users for security
- Use health checks for container orchestration
- Leverage build cache for faster builds
