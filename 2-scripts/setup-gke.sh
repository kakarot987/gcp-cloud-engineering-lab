#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: setup-gke.sh
# Purpose: Create a Google Kubernetes Engine (GKE) cluster
# Usage: ./setup-gke.sh [CLUSTER_NAME] [ZONE] [NODE_COUNT]

set -e  # Exit on any error

# Default values
CLUSTER_NAME="${1:-gcp-ace-cluster}"
ZONE="${2:-us-central1-a}"
NODE_COUNT="${3:-3}"

# Configuration
PROJECT_ID="$(gcloud config get-value project)"
REGION="${ZONE%-*}"
MACHINE_TYPE="n1-standard-1"
DISK_SIZE="50GB"

echo " Creating GKE Cluster"
echo " Project: $PROJECT_ID"
echo "☸️  Cluster: $CLUSTER_NAME"
echo " Zone: $ZONE"
echo "️  Nodes: $NODE_COUNT"
echo

# Validate inputs
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set in gcloud config"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# Enable required APIs
echo " Enabling required APIs..."
gcloud services enable container.googleapis.com --quiet

# Check if cluster already exists
if gcloud container clusters describe "$CLUSTER_NAME" --zone="$ZONE" --project="$PROJECT_ID" &>/dev/null; then
    echo "❌ Error: Cluster '$CLUSTER_NAME' already exists in zone $ZONE"
    exit 1
fi

# Create VPC if it doesn't exist (for demo purposes)
VPC_NAME="gke-vpc"
if ! gcloud compute networks describe "$VPC_NAME" --project="$PROJECT_ID" &>/dev/null; then
    echo "️  Creating VPC for GKE cluster..."
    gcloud compute networks create "$VPC_NAME" \
        --subnet-mode=custom \
        --bgp-routing-mode=regional \
        --project="$PROJECT_ID" \
        --quiet

    # Create subnet with secondary ranges for GKE
    gcloud compute networks subnets create "${VPC_NAME}-subnet" \
        --network="$VPC_NAME" \
        --region="$REGION" \
        --range=10.0.0.0/16 \
        --secondary-range=pods=10.4.0.0/14,services=10.0.16.0/20 \
        --project="$PROJECT_ID" \
        --quiet
fi

# Create GKE cluster
echo "️  Creating GKE cluster..."
gcloud container clusters create "$CLUSTER_NAME" \
    --zone="$ZONE" \
    --num-nodes="$NODE_COUNT" \
    --machine-type="$MACHINE_TYPE" \
    --disk-size="$DISK_SIZE" \
    --network="$VPC_NAME" \
    --subnetwork="${VPC_NAME}-subnet" \
    --enable-ip-alias \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --enable-autorepair \
    --enable-autoupgrade \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --project="$PROJECT_ID" \
    --quiet

# Get cluster credentials
echo " Getting cluster credentials..."
gcloud container clusters get-credentials "$CLUSTER_NAME" \
    --zone="$ZONE" \
    --project="$PROJECT_ID"

# Verify cluster
echo " Verifying cluster..."
kubectl get nodes

# Create a sample deployment
echo " Creating sample application..."

# Create namespace
kubectl create namespace gcp-ace-lab --dry-run=client -o yaml | kubectl apply -f -

# Create deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-gke
  namespace: gcp-ace-lab
  labels:
    app: hello-gke
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-gke
  template:
    metadata:
      labels:
        app: hello-gke
    spec:
      containers:
      - name: hello-gke
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# Create service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: hello-gke-service
  namespace: gcp-ace-lab
spec:
  selector:
    app: hello-gke
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF

# Wait for external IP
echo "⏳ Waiting for LoadBalancer external IP..."
sleep 30

# Get service information
EXTERNAL_IP=$(kubectl get service hello-gke-service -n gcp-ace-lab -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo
echo "✅ GKE cluster '$CLUSTER_NAME' created successfully!"
echo
echo " Cluster Details:"
echo "   Name: $CLUSTER_NAME"
echo "   Zone: $ZONE"
echo "   Nodes: $NODE_COUNT ($MACHINE_TYPE)"
echo "   Network: $VPC_NAME"
echo "   Subnet: ${VPC_NAME}-subnet"
echo "   Autoscaling: 1-5 nodes"
echo "   Autorepair: Enabled"
echo "   Autoupgrade: Enabled"
echo
echo " Sample Application:"
echo "   Namespace: gcp-ace-lab"
echo "   Deployment: hello-gke (2 replicas)"
echo "   Service: hello-gke-service (LoadBalancer)"
if [ -n "$EXTERNAL_IP" ]; then
    echo "   External IP: $EXTERNAL_IP"
    echo "   URL: http://$EXTERNAL_IP"
fi
echo
echo "️  Management Commands:"
echo "   Get nodes: kubectl get nodes"
echo "   Get pods: kubectl get pods -n gcp-ace-lab"
echo "   Get services: kubectl get services -n gcp-ace-lab"
echo "   Scale deployment: kubectl scale deployment hello-gke --replicas=3 -n gcp-ace-lab"
echo "   View logs: kubectl logs -l app=hello-gke -n gcp-ace-lab"
echo
echo " GKE Commands:"
echo "   Resize cluster: gcloud container clusters resize $CLUSTER_NAME --num-nodes=5 --zone=$ZONE"
echo "   Upgrade cluster: gcloud container clusters upgrade $CLUSTER_NAME --zone=$ZONE"
echo "   Delete cluster: gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE"
echo
echo " Test the application:"
if [ -n "$EXTERNAL_IP" ]; then
    echo "   curl http://$EXTERNAL_IP"
else
    echo "   kubectl get service hello-gke-service -n gcp-ace-lab -w"
fi
echo
echo " Useful kubectl commands:"
echo "   kubectl get all -n gcp-ace-lab"
echo "   kubectl describe pod -l app=hello-gke -n gcp-ace-lab"
echo "   kubectl exec -it deployment/hello-gke -n gcp-ace-lab -- /bin/sh"