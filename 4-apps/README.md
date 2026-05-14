# 4-apps/ - Sample Applications for GCP

This directory contains sample Java/Spring Boot applications demonstrating deployment to different GCP compute services, showcasing practical application development and containerization skills.

## 📁 Directory Structure

```
4-apps/
├── hello-cloud-run/           # Serverless container app
│   ├── src/                   # Java source code
│   ├── pom.xml               # Maven configuration
│   ├── Dockerfile            # Container build instructions
│   └── README.md             # Deployment guide
└── hello-gke/                 # Kubernetes application
    ├── src/                   # Java source code
    ├── pom.xml               # Maven configuration
    ├── Dockerfile            # Container build instructions
    ├── k8s/                  # Kubernetes manifests
    │   ├── deployment.yaml   # Deployment configuration
    │   ├── service.yaml      # Service exposure
    │   └── configmap.yaml    # Configuration data
    └── README.md             # Deployment guide
```

## 🚀 Application Overview

### Hello Cloud Run
**Purpose:** Demonstrate serverless container deployment
- **Framework:** Spring Boot 3.x with Spring Web
- **Features:** REST API with health checks, environment info
- **Deployment:** Cloud Run (fully managed serverless)
- **Scaling:** Automatic scaling to zero

### Hello GKE
**Purpose:** Demonstrate container orchestration
- **Framework:** Spring Boot 3.x with Spring Web + Actuator
- **Features:** REST API, health checks, metrics, config management
- **Deployment:** Google Kubernetes Engine (GKE)
- **Scaling:** Horizontal Pod Autoscaling (HPA)

## 🛠️ Prerequisites

```bash
# Java 17+ and Maven
java -version
mvn -version

# Docker (for local testing)
docker --version

# Google Cloud SDK
gcloud --version

# kubectl (for GKE)
kubectl version --client
```

## 📚 Learning Objectives

### Cloud Run Application
- **Containerization** - Docker best practices
- **Serverless Architecture** - No infrastructure management
- **API Design** - RESTful endpoints
- **Cloud Native** - 12-factor app principles

### GKE Application
- **Microservices** - Containerized applications
- **Kubernetes** - Pod, Service, Deployment concepts
- **Configuration Management** - ConfigMaps and Secrets
- **Observability** - Health checks and metrics
- **Scaling** - HPA and resource management

## 🎯 Certification Benefits

- **ACE Exam Topics**: Compute options, containers, Kubernetes
- **Practical Skills**: Java development, Docker, K8s manifests
- **Production Patterns**: Health checks, logging, monitoring
- **Deployment Strategies**: CI/CD-ready applications

## 🚀 Quick Start

### Deploy Hello Cloud Run
```bash
cd hello-cloud-run
mvn clean package
gcloud run deploy hello-cloud-run \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Deploy Hello GKE
```bash
cd hello-gke
mvn clean package
docker build -t hello-gke:latest .
docker tag hello-gke:latest gcr.io/YOUR_PROJECT/hello-gke:latest
docker push gcr.io/YOUR_PROJECT/hello-gke:latest

# Deploy to GKE
kubectl apply -f k8s/
kubectl get pods
kubectl get services
```

## 🔧 Customization

Both applications include:
- **Environment Variables** - Configurable via deployment
- **Health Endpoints** - `/actuator/health` for monitoring
- **Info Endpoints** - `/actuator/info` for application details
- **Custom Properties** - Application-specific configuration

## 📊 Monitoring & Observability

- **Health Checks** - Kubernetes readiness/liveness probes
- **Metrics** - Spring Boot Actuator metrics
- **Logging** - Structured JSON logging
- **Tracing** - Request correlation IDs

## 🧹 Cleanup

```bash
# Cloud Run
gcloud run services delete hello-cloud-run --region us-central1

# GKE
kubectl delete -f hello-gke/k8s/
```

---

**Note**: These applications are designed for learning and demonstration. For production use, add authentication, input validation, and security headers.
