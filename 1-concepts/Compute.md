# GCP Compute Services

## Overview
GCP offers multiple compute options ranging from fully managed serverless to Infrastructure-as-a-Service (IaaS) VMs. Choosing the right compute service affects cost, complexity, and scalability.

---

## Compute Services Comparison

| Service | Abstraction | Scaling | Cost | Management | Ideal For |
|---------|------------|---------|------|-----------|-----------|
| **Cloud Run** | Serverless | Automatic (0 → ∞) | Per-request + idle | Minimal | APIs, webhooks, event handlers |
| **App Engine** | Platform | Automatic | Per-instance hour | Low | Web applications, quick deployment |
| **Cloud Functions** | Serverless | Automatic (0 → ∞) | Per-invocation | Minimal | Event-driven, scheduled tasks |
| **GKE** | Container Orchestration | Manual/auto | Per-node + traffic | High | Complex apps, multi-container, microservices |
| **GCE** | Infrastructure | Manual | Per-minute | Very High | Custom OS, performance-critical, legacy apps |
| **Compute Engine** | VMs | Manual/managed | Per-minute | Very High | Full control, custom configurations |

---

## Compute Engine (GCE)

**What it is:**
- Virtual machines in the cloud
- Complete control over OS, software, configurations
- Similar to AWS EC2 or Azure VMs
- Pay per second of usage

### Machine Types

```
General Purpose (N1, N2, E2)
├─ n1-standard-1    (1 vCPU, 3.75 GB memory)
├─ n1-standard-4    (4 vCPU, 15 GB memory)
├─ n2-standard-2    (2 vCPU, 8 GB memory)
└─ e2-micro         (0.25 to 1 vCPU, 1 GB memory) [Free tier]

Memory Optimized (M1, M2, M3)
├─ m1-megamem-96    (96 vCPU, 1.4 TB memory)
└─ m2-ultramem-416  (416 vCPU, 5.8 TB memory)

Compute Optimized (C2, C3)
├─ c2-standard-4    (4 vCPU, 16 GB memory)
└─ c2-standard-16   (16 vCPU, 64 GB memory)
```

### Creating and Managing Instances

```bash
# Create simple instance
gcloud compute instances create my-instance \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud

# Create instance with custom settings
gcloud compute instances create web-server \
  --zone=us-central1-a \
  --machine-type=n1-standard-1 \
  --boot-disk-size=50GB \
  --scopes=cloud-platform \
  --service-account=app-sa@project.iam.gserviceaccount.com \
  --network-interface=network-tier=PREMIUM \
  --tag=web-server \
  --metadata=startup-script='#!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemctl start nginx'

# List instances
gcloud compute instances list

# SSH into instance
gcloud compute ssh my-instance --zone=us-central1-a

# Stop/Start instance
gcloud compute instances stop my-instance --zone=us-central1-a
gcloud compute instances start my-instance --zone=us-central1-a

# Delete instance
gcloud compute instances delete my-instance --zone=us-central1-a
```

### Disks and Snapshots

```bash
# Create additional persistent disk
gcloud compute disks create data-disk \
  --size=100GB \
  --zone=us-central1-a

# Attach disk to instance
gcloud compute instances attach-disk my-instance \
  --disk=data-disk \
  --zone=us-central1-a

# Create snapshot for backup
gcloud compute disks snapshot boot-disk \
  --snapshot-names=boot-snapshot

# Create instance from snapshot
gcloud compute instances create restored-instance \
  --source-snapshot=boot-snapshot
```

### Instance Groups and Load Balancing

```bash
# Create instance template
gcloud compute instance-templates create web-template \
  --machine-type=n1-standard-1 \
  --boot-disk-image=debian-11 \
  --scopes=cloud-platform

# Create managed instance group
gcloud compute instance-groups managed create web-group \
  --base-instance-name=web \
  --template=web-template \
  --size=3 \
  --zone=us-central1-a

# Auto-scaling configuration
gcloud compute instance-groups managed set-autoscaling web-group \
  --max-num-instances=10 \
  --min-num-instances=3 \
  --target-cpu-utilization=0.6

# Create load balancer
gcloud compute backend-services create web-backend \
  --protocol=HTTP \
  --global

# Add instance group to backend
gcloud compute backend-services add-backend web-backend \
  --instance-group=web-group \
  --instance-group-zone=us-central1-a \
  --global
```

---

## Cloud Run

**What it is:**
- Fully managed serverless container platform
- Run containerized applications without managing servers
- Auto-scales from 0 to thousands of instances
- Pay only for compute time actually used

### Advantages
- Automatic scaling (including to zero)
- No infrastructure management
- Scales to handle traffic spikes
- Per-request billing (no idle charges)
- Can use any language that can run in a container

### Deploying to Cloud Run

```bash
# Method 1: Deploy from source (auto-builds container)
gcloud run deploy hello-world \
  --source . \
  --region=us-central1 \
  --allow-unauthenticated

# Method 2: Deploy from image
gcloud run deploy hello-cloud-run \
  --image=gcr.io/PROJECT_ID/hello-app:latest \
  --region=us-central1 \
  --allow-unauthenticated

# Deploy with environment variables
gcloud run deploy my-app \
  --image=gcr.io/PROJECT_ID/my-app:v1 \
  --set-env-vars=DATABASE_URL=postgresql://...,LOG_LEVEL=INFO \
  --region=us-central1

# Deploy with Cloud SQL connection
gcloud run deploy my-app \
  --image=gcr.io/PROJECT_ID/my-app:v1 \
  --add-cloudsql-instances=PROJECT_ID:us-central1:my-db \
  --set-env-vars=CLOUDSQL_CONNECTION_NAME=PROJECT_ID:us-central1:my-db \
  --region=us-central1

# List deployments
gcloud run services list

# Get service URL
gcloud run services describe my-app --region=us-central1 \
  --format='value(status.url)'

# Delete service
gcloud run services delete my-app --region=us-central1
```

### Example Cloud Run Application (Python)

```python
# app.py - Flask application
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({"message": "Hello from Cloud Run!"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/api/data')
def get_data():
    return jsonify({"data": [1, 2, 3, 4, 5]})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
```

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

CMD ["python", "app.py"]
```

```bash
# Deploy
gcloud run deploy hello-app \
  --source . \
  --region=us-central1 \
  --allow-unauthenticated
```

### Cloud Run Features

```bash
# Set memory and CPU
gcloud run deploy my-app \
  --image=gcr.io/PROJECT_ID/my-app:v1 \
  --memory=2Gi \
  --cpu=2

# Set timeout
gcloud run deploy my-app \
  --image=gcr.io/PROJECT_ID/my-app:v1 \
  --timeout=3600s

# Request-based autoscaling
gcloud run deploy my-app \
  --image=gcr.io/PROJECT_ID/my-app:v1 \
  --concurrency=80

# Require authentication
gcloud run deploy my-app \
  --image=gcr.io/PROJECT_ID/my-app:v1 \
  --no-allow-unauthenticated
```

---

## Google Kubernetes Engine (GKE)

**What it is:**
- Managed Kubernetes cluster service
- Automates container deployment, scaling, and operations
- Deploy containerized microservices at scale
- Pay for node instances + networking

### GKE vs. Cloud Run

| Aspect | Cloud Run | GKE |
|--------|-----------|-----|
| Abstraction | Serverless containers | Container orchestration |
| Scaling | 0 → ∞ (fully automatic) | Manual/auto (pod-level) |
| Complexity | Low | High |
| Cost | Per-request | Per-node |
| Idle cost | None | Yes (node cost) |
| Use case | Simple APIs, webhooks | Microservices, stateful apps |

### Creating GKE Cluster

```bash
# Create standard cluster
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=n1-standard-1

# Create cluster with custom network
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --network=custom-vpc \
  --subnetwork=gke-subnet \
  --num-nodes=3

# Create cluster with auto-scaling
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=1 \
  --min-nodes=1 \
  --max-nodes=10 \
  --enable-autoscaling

# Get cluster credentials
gcloud container clusters get-credentials my-cluster \
  --zone=us-central1-a

# List clusters
gcloud container clusters list
```

### Deploying to GKE

```bash
# Build and push image
gcloud builds submit --tag=gcr.io/PROJECT_ID/hello-app

# Deploy using kubectl
kubectl create deployment hello-app \
  --image=gcr.io/PROJECT_ID/hello-app:latest

# Expose deployment (create service)
kubectl expose deployment hello-app \
  --type=LoadBalancer \
  --port=80 \
  --target-port=8080

# Check status
kubectl get deployments
kubectl get pods
kubectl get services

# Get external IP
kubectl get services hello-app --watch
```

### GKE Example Manifest

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-app
  template:
    metadata:
      labels:
        app: hello-app
    spec:
      containers:
      - name: hello-app
        image: gcr.io/PROJECT_ID/hello-app:v1
        ports:
        - containerPort: 8080
        env:
        - name: LOG_LEVEL
          value: "info"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-app
spec:
  selector:
    app: hello-app
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

```bash
# Deploy manifest
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Update deployment
kubectl set image deployment/hello-app \
  hello-app=gcr.io/PROJECT_ID/hello-app:v2

# Scale deployment
kubectl scale deployment hello-app --replicas=5
```

---

## Cloud Functions

**What it is:**
- Serverless function-as-a-service (FaaS)
- Execute single functions in response to events
- Auto-scales from 0 to thousands
- Pay per invocation + compute time

### Supported Triggers
- HTTP requests
- Pub/Sub messages
- Cloud Storage events
- Firestore events
- Cloud Tasks
- Cloud Scheduler

### Creating a Function

```bash
# Create HTTP function
gcloud functions deploy hello-http \
  --runtime=python39 \
  --trigger-http \
  --allow-unauthenticated

# Create Pub/Sub function
gcloud functions deploy process-message \
  --runtime=python39 \
  --trigger-topic=my-topic

# Create Cloud Storage function
gcloud functions deploy process-file \
  --runtime=python39 \
  --trigger-resource=my-bucket \
  --trigger-event=google.storage.object.finalize

# List functions
gcloud functions list

# Delete function
gcloud functions delete hello-http
```

### Example Function (Python)

```python
# main.py
import functions_framework
import json

@functions_framework.http
def hello_http(request):
    """HTTP Cloud Function."""
    request_json = request.get_json(silent=True)
    name = request_json.get('name', 'World') if request_json else 'World'
    return json.dumps({'message': f'Hello, {name}!'})

@functions_framework.cloud_event
def process_pubsub(cloud_event):
    """Cloud Pub/Sub Cloud Function."""
    import base64
    message = base64.b64decode(cloud_event.data["message"]["data"])
    print(f'Message: {message}')
```

---

## Choosing the Right Compute Service

### Use Cloud Run if:
- ✅ Stateless HTTP service
- ✅ Simple API/webhook
- ✅ Need to scale to zero (save on costs)
- ✅ Event-driven processing
- ✅ Rapid development/deployment

### Use App Engine if:
- ✅ Traditional web application
- ✅ Need datastore/sessions
- ✅ Want zero-ops approach
- ✅ Built-in traffic splitting

### Use Cloud Functions if:
- ✅ Single-function event handler
- ✅ Triggered by specific events
- ✅ Short-running tasks
- ✅ Scheduled operations

### Use GKE if:
- ✅ Microservices architecture
- ✅ Complex application requirements
- ✅ Need service mesh (Istio)
- ✅ Stateful applications
- ✅ Existing Kubernetes expertise

### Use Compute Engine if:
- ✅ Need full OS control
- ✅ Custom software/licenses
- ✅ Long-running processes
- ✅ Legacy application migration
- ✅ Performance-critical applications

---

## Best Practices

### Compute Engine
```bash
# ✅ Use startup scripts for initialization
gcloud compute instances create server \
  --metadata=startup-script='#!/bin/bash
    apt-get update && apt-get install -y nginx'

# ✅ Use instance groups with load balancing
gcloud compute instance-groups managed create servers \
  --template=server-template \
  --size=3

# ✅ Use preemptible VMs for cost savings (if workload tolerates interruption)
gcloud compute instances create cheap-server \
  --preemptible
```

### Cloud Run
```bash
# ✅ Set appropriate timeout and memory
gcloud run deploy app \
  --memory=1Gi \
  --timeout=60s

# ✅ Use minimum instances to reduce cold starts
gcloud run deploy app \
  --min-instances=1

# ✅ Serve health checks on /health
# Implement in your application
```

### GKE
```bash
# ✅ Use cluster autoscaling
gcloud container clusters create cluster \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10

# ✅ Use resource requests and limits
# See example manifest above

# ✅ Use network policies for security
kubectl apply -f network-policy.yaml
```

---

## Interview Tips

✅ **Know:**
- Compute options and when to use each
- Container basics and why they're used
- Kubernetes concepts (pods, deployments, services)
- Autoscaling mechanisms
- Cost optimization strategies
- Load balancing concepts

❌ **Avoid:**
- Using Compute Engine for simple APIs (use Cloud Run)
- Not understanding serverless vs. managed services
- Misunderstanding GKE complexity
- Ignoring autoscaling configuration
- Not considering costs in architecture decisions

