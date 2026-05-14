# Hello GKE - Kubernetes Java Application

A comprehensive Spring Boot application demonstrating deployment to Google Kubernetes Engine (GKE), showcasing container orchestration, microservices architecture, and Kubernetes best practices for the Associate Cloud Engineer certification.

## 🚀 Features

- **REST API** - Multiple endpoints with path/query parameters
- **Health Checks** - Liveness, readiness, and startup probes
- **Configuration Management** - ConfigMaps for environment variables
- **Auto-scaling** - Horizontal Pod Autoscaler (HPA)
- **Load Balancing** - Service and Ingress configurations
- **Security** - Non-root containers, security contexts
- **Monitoring** - Spring Boot Actuator with Prometheus metrics

## 📋 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/hello` | Basic greeting message |
| GET | `/api/v1/hello/{name}` | Personalized greeting |
| GET | `/api/v1/hello/repeat?name=X&count=Y` | Repeated greeting |
| GET | `/api/v1/info` | Application and environment information |
| GET | `/api/v1/health` | Health check status |
| GET | `/api/v1/ready` | Readiness check |
| GET | `/actuator/health` | Spring Boot health endpoint |
| GET | `/actuator/info` | Spring Boot info endpoint |
| GET | `/actuator/metrics` | Application metrics |
| GET | `/actuator/prometheus` | Prometheus metrics |

## 🛠️ Local Development

### Prerequisites
```bash
# Java 17+
java -version

# Maven
mvn -version

# Docker
docker --version

# Kubernetes tools (optional)
kubectl version --client
minikube version  # For local testing
```

### Run Locally
```bash
# Build the application
mvn clean compile

# Run the application
mvn spring-boot:run

# Test the endpoints
curl http://localhost:8080/api/v1/hello
curl http://localhost:8080/api/v1/hello/World
curl "http://localhost:8080/api/v1/hello/repeat?name=Kubernetes&count=3"
curl http://localhost:8080/api/v1/info
curl http://localhost:8080/api/v1/health
```

### Run with Docker
```bash
# Build Docker image
docker build -t hello-gke:latest .

# Run container locally
docker run -p 8080:8080 \
  -e ENVIRONMENT=development \
  -e GREETING_MESSAGE="Hello from Docker!" \
  hello-gke:latest

# Test the application
curl http://localhost:8080/api/v1/hello
```

## ☁️ Deploy to GKE

### Prerequisites
```bash
# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Configure kubectl for your cluster
gcloud container clusters get-credentials YOUR_CLUSTER_NAME --region us-central1
```

### Build and Push Container
```bash
# Build the application
mvn clean package

# Build Docker image
docker build -t hello-gke:latest .

# Tag for GCR
docker tag hello-gke:latest gcr.io/YOUR_PROJECT_ID/hello-gke:latest

# Push to GCR
docker push gcr.io/YOUR_PROJECT_ID/hello-gke:latest
```

### Deploy to Kubernetes
```bash
# Update the image reference in deployment.yaml
# Change: gcr.io/YOUR_PROJECT_ID/hello-gke:latest

# Deploy all resources
kubectl apply -f k8s/

# Check deployment status
kubectl get pods
kubectl get services
kubectl get ingress
kubectl get hpa

# Check logs
kubectl logs -l app=hello-gke

# Port forward for testing (optional)
kubectl port-forward svc/hello-gke-service 8080:80
```

### Test the Deployment
```bash
# Get service URL
kubectl get svc hello-gke-loadbalancer

# Test endpoints
curl http://EXTERNAL_IP/api/v1/hello
curl http://EXTERNAL_IP/api/v1/info
curl http://EXTERNAL_IP/api/v1/health

# Load test for auto-scaling
hey -n 1000 -c 10 http://EXTERNAL_IP/api/v1/hello
kubectl get hpa
kubectl get pods
```

## 🔧 Configuration

### ConfigMap Values
Edit `k8s/configmap.yaml` to customize:
- `ENVIRONMENT` - Application environment
- `GREETING_MESSAGE` - Default greeting message
- `LOG_LEVEL` - Application log level

### Environment Variables
| Variable | Default | Description |
|----------|---------|-------------|
| `ENVIRONMENT` | `production` | Application environment |
| `GREETING_MESSAGE` | `Hello from Kubernetes!` | Default greeting |
| `LOG_LEVEL` | `INFO` | Logging level |

### Resource Limits
Configured in `deployment.yaml`:
- **Requests**: 256Mi memory, 100m CPU
- **Limits**: 512Mi memory, 500m CPU

## 📊 Monitoring & Observability

### Health Checks
- **Liveness Probe**: `/api/v1/health` (30s interval)
- **Readiness Probe**: `/api/v1/ready` (10s interval)
- **Startup Probe**: `/api/v1/health` (10s interval)

### Metrics
```bash
# Access Prometheus metrics
curl http://EXTERNAL_IP/actuator/prometheus

# View HPA status
kubectl describe hpa hello-gke-hpa
```

### Logs
```bash
# View application logs
kubectl logs -l app=hello-gke --tail=100

# Stream logs in real-time
kubectl logs -l app=hello-gke -f

# View logs from specific pod
kubectl logs POD_NAME
```

## 🔄 Auto-scaling

### Horizontal Pod Autoscaler
Configured to scale based on:
- **CPU**: 70% average utilization
- **Memory**: 80% average utilization
- **Min Pods**: 2
- **Max Pods**: 10

### Test Auto-scaling
```bash
# Generate load
hey -n 10000 -c 50 http://EXTERNAL_IP/api/v1/hello

# Monitor scaling
kubectl get hpa -w
kubectl get pods -w
```

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete -f k8s/

# Delete container image
gcloud container images delete gcr.io/YOUR_PROJECT_ID/hello-gke:latest --force-delete-tags
```

## 🎯 Learning Objectives

- **Container Orchestration** - Kubernetes deployments
- **Microservices** - REST API design and implementation
- **Configuration Management** - ConfigMaps and environment variables
- **Auto-scaling** - HPA and resource management
- **Health Monitoring** - Probes and application health
- **Security** - Pod security contexts and best practices
- **Load Balancing** - Services and ingress routing

## 📚 Kubernetes Concepts Demonstrated

- **Pods** - Container execution units
- **Deployments** - Declarative application updates
- **Services** - Network abstraction for pods
- **ConfigMaps** - Configuration data management
- **Ingress** - External access routing
- **HPA** - Automatic scaling
- **Probes** - Health checking mechanisms

## 🔧 Customization Options

### Scaling Configuration
- Modify replica counts in `deployment.yaml`
- Adjust HPA thresholds in `hpa.yaml`
- Configure resource requests/limits

### Networking
- Use LoadBalancer service for external access
- Configure Ingress for advanced routing
- Set up internal networking with ClusterIP

### Security
- Enable workload identity
- Configure network policies
- Add pod security standards

---

**Note**: This application demonstrates production-ready Kubernetes patterns. For production deployment, consider adding secrets management, persistent volumes, and proper CI/CD pipelines.
