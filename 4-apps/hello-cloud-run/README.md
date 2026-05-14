# Hello Cloud Run - Serverless Java Application

A sample Spring Boot application demonstrating deployment to Google Cloud Run, showcasing serverless container patterns and best practices for the Associate Cloud Engineer certification.

## 🚀 Features

- **REST API** - Simple greeting and info endpoints
- **Health Checks** - Actuator endpoints for monitoring
- **Environment Info** - Runtime environment details
- **Container Ready** - Optimized for Cloud Run deployment
- **Security** - Non-root container execution

## 📋 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/hello` | Basic greeting message |
| GET | `/api/info` | Application and environment information |
| GET | `/api/health` | Health check status |
| GET | `/actuator/health` | Spring Boot health endpoint |
| GET | `/actuator/info` | Spring Boot info endpoint |

## 🛠️ Local Development

### Prerequisites
```bash
# Java 17+
java -version

# Maven
mvn -version

# Docker (optional)
docker --version
```

### Run Locally
```bash
# Clone and navigate to the project
cd hello-cloud-run

# Build the application
mvn clean compile

# Run the application
mvn spring-boot:run

# Test the endpoints
curl http://localhost:8080/api/hello
curl http://localhost:8080/api/info
curl http://localhost:8080/api/health
```

### Run with Docker
```bash
# Build Docker image
docker build -t hello-cloud-run:latest .

# Run container locally
docker run -p 8080:8080 hello-cloud-run:latest

# Test the application
curl http://localhost:8080/api/hello
```

## ☁️ Deploy to Cloud Run

### Method 1: Source-based Deployment
```bash
# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable Cloud Run API
gcloud services enable run.googleapis.com

# Deploy from source
gcloud run deploy hello-cloud-run \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10 \
  --timeout 300
```

### Method 2: Container-based Deployment
```bash
# Build and push container
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/hello-cloud-run:latest .

# Deploy container
gcloud run deploy hello-cloud-run \
  --image gcr.io/YOUR_PROJECT_ID/hello-cloud-run:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1
```

## 🔧 Configuration

### Environment Variables
| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server port (set by Cloud Run) |
| `K_SERVICE` | - | Service name (set by Cloud Run) |
| `K_REVISION` | - | Revision name (set by Cloud Run) |

### Application Properties
- `app.version` - Application version
- `spring.application.name` - Application name
- `server.port` - Server port configuration

## 📊 Monitoring

### Health Checks
Cloud Run automatically configures health checks using the `/actuator/health` endpoint.

### Logs
```bash
# View logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=hello-cloud-run" --limit=50

# Stream logs
gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=hello-cloud-run"
```

### Metrics
- Request count and latency
- Instance count and utilization
- Error rates and response codes

## 🧹 Cleanup

```bash
# Delete the service
gcloud run services delete hello-cloud-run --region us-central1

# Remove container image (if using container registry)
gcloud container images delete gcr.io/YOUR_PROJECT_ID/hello-cloud-run:latest --force-delete-tags
```

## 🎯 Learning Objectives

- **Serverless Architecture** - No server management
- **Containerization** - Docker best practices
- **REST API Design** - Clean API endpoints
- **Health Monitoring** - Application observability
- **Cloud Native** - 12-factor app principles
- **CI/CD Ready** - Automated deployment

## 📚 Related Documentation

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Note**: This application is designed for learning and demonstration. For production use, add authentication, input validation, rate limiting, and proper error handling.
