# kubectl Cheat Sheet

Essential Kubernetes commands for GKE operations and the Associate Cloud Engineer certification.

## 🔧 Context & Configuration

### Cluster Access
```bash
# Configure kubectl
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
kubectl config current-context                           # Show current context
kubectl config get-contexts                              # List contexts
kubectl config use-context CONTEXT_NAME                  # Switch context

# Configuration
kubectl config view                                     # View config
kubectl config set-context --current --namespace=default # Set namespace
kubectl config set-context CONTEXT_NAME --namespace=prod # Set context namespace
```

### Cluster Information
```bash
# Cluster status
kubectl cluster-info                                    # Cluster info
kubectl cluster-info dump                               # Detailed dump
kubectl get nodes                                        # Node status
kubectl describe nodes                                   # Node details
kubectl get nodes -o wide                               # Node IPs and status
```

## 📦 Pod Operations

### Pod Management
```bash
# List pods
kubectl get pods                                        # All pods
kubectl get pods -n NAMESPACE                           # Namespace pods
kubectl get pods -o wide                               # Pod details
kubectl get pods --field-selector=status.phase=Running # Filter by status

# Pod details
kubectl describe pod POD_NAME                           # Pod description
kubectl get pod POD_NAME -o yaml                       # Pod YAML
kubectl logs POD_NAME                                  # Pod logs
kubectl logs POD_NAME -c CONTAINER_NAME                # Multi-container logs
kubectl logs -f POD_NAME                               # Follow logs
kubectl logs --previous POD_NAME                       # Previous logs
```

### Pod Lifecycle
```bash
# Create pods
kubectl run nginx --image=nginx                         # Quick pod
kubectl create -f pod.yaml                             # From YAML
kubectl apply -f pod.yaml                              # Apply changes

# Update pods
kubectl set image pod/POD_NAME nginx=nginx:1.20        # Update image
kubectl edit pod POD_NAME                              # Edit pod
kubectl replace -f pod.yaml                            # Replace pod

# Delete pods
kubectl delete pod POD_NAME                            # Delete pod
kubectl delete pods --field-selector=status.phase=Failed # Delete failed pods
kubectl delete pods -l app=nginx                       # Delete by label
```

## 🚢 Deployment Operations

### Deployment Management
```bash
# Create deployments
kubectl create deployment nginx --image=nginx          # Quick deployment
kubectl create -f deployment.yaml                      # From YAML
kubectl apply -f deployment.yaml                       # Apply deployment

# List deployments
kubectl get deployments                                # All deployments
kubectl get deployments -o wide                       # Deployment details
kubectl describe deployment DEPLOYMENT_NAME           # Deployment info

# Scale deployments
kubectl scale deployment DEPLOYMENT_NAME --replicas=5 # Scale up
kubectl autoscale deployment DEPLOYMENT_NAME --cpu-percent=70 --min=2 --max=10
kubectl get hpa                                        # Check autoscaling
```

### Deployment Updates
```bash
# Rolling updates
kubectl set image deployment/DEPLOYMENT_NAME nginx=nginx:1.20
kubectl rollout status deployment/DEPLOYMENT_NAME     # Update status
kubectl rollout history deployment/DEPLOYMENT_NAME    # Update history
kubectl rollout undo deployment/DEPLOYMENT_NAME       # Rollback

# Deployment editing
kubectl edit deployment DEPLOYMENT_NAME               # Edit deployment
kubectl patch deployment DEPLOYMENT_NAME -p '{"spec":{"replicas":3}}'
```

## 🌐 Service Operations

### Service Management
```bash
# Create services
kubectl create service clusterip nginx --tcp=80:80    # ClusterIP service
kubectl create service loadbalancer nginx --tcp=80:80 # LoadBalancer
kubectl create service nodeport nginx --tcp=80:80     # NodePort
kubectl expose deployment nginx --port=80 --target-port=8080 # Expose deployment

# List services
kubectl get services                                  # All services
kubectl get services -o wide                          # Service details
kubectl describe service SERVICE_NAME                 # Service info

# Service operations
kubectl edit service SERVICE_NAME                     # Edit service
kubectl delete service SERVICE_NAME                   # Delete service
```

### Service Discovery
```bash
# DNS lookup
kubectl run test --image=busybox --rm -it -- nslookup nginx-service
kubectl exec -it POD_NAME -- nslookup SERVICE_NAME

# Endpoint checking
kubectl get endpoints                                 # Service endpoints
kubectl describe endpoints SERVICE_NAME               # Endpoint details
```

## 📋 ConfigMap & Secret Operations

### ConfigMaps
```bash
# Create ConfigMaps
kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2
kubectl create configmap my-config --from-file=config.properties
kubectl create configmap my-config --from-env-file=.env
kubectl apply -f configmap.yaml

# Manage ConfigMaps
kubectl get configmaps                               # List ConfigMaps
kubectl describe configmap CONFIGMAP_NAME            # ConfigMap details
kubectl get configmap CONFIGMAP_NAME -o yaml         # ConfigMap YAML
kubectl edit configmap CONFIGMAP_NAME                # Edit ConfigMap
kubectl delete configmap CONFIGMAP_NAME              # Delete ConfigMap
```

### Secrets
```bash
# Create secrets
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=secret
kubectl create secret tls tls-secret --cert=cert.pem --key=key.pem
kubectl create secret docker-registry regcred --docker-server=REGISTRY --docker-username=USER --docker-password=PASS
kubectl apply -f secret.yaml

# Manage secrets
kubectl get secrets                                  # List secrets
kubectl describe secret SECRET_NAME                   # Secret details
kubectl get secret SECRET_NAME -o yaml               # Secret YAML (base64)
kubectl edit secret SECRET_NAME                      # Edit secret
kubectl delete secret SECRET_NAME                    # Delete secret
```

## 🔍 Debugging & Troubleshooting

### Pod Debugging
```bash
# Pod status
kubectl get pods -o wide                             # Pod status overview
kubectl describe pod POD_NAME                        # Detailed pod info
kubectl logs POD_NAME --previous                     # Previous container logs
kubectl logs -l app=myapp --all-containers          # All containers in pods

# Pod events
kubectl get events --field-selector involvedObject.name=POD_NAME
kubectl get events --sort-by=.metadata.creationTimestamp

# Container debugging
kubectl exec -it POD_NAME -- /bin/bash               # Shell access
kubectl exec POD_NAME -- ls -la /app                 # Run commands
kubectl port-forward pod/POD_NAME 8080:8080          # Port forwarding
```

### Resource Issues
```bash
# Resource usage
kubectl top pods                                     # Pod resource usage
kubectl top nodes                                    # Node resource usage
kubectl describe pod POD_NAME | grep -A 10 Events    # Pod events

# Resource quotas
kubectl get resourcequotas                           # Resource quotas
kubectl describe resourcequota QUOTA_NAME            # Quota details
kubectl get limitranges                              # Limit ranges
```

### Network Debugging
```bash
# Network testing
kubectl run test --image=busybox --rm -it -- wget -O- http://SERVICE_NAME
kubectl run test --image=busybox --rm -it -- nslookup SERVICE_NAME

# Network policies
kubectl get networkpolicies                          # Network policies
kubectl describe networkpolicy POLICY_NAME           # Policy details

# Service connectivity
kubectl get endpoints SERVICE_NAME                   # Service endpoints
kubectl describe endpoints SERVICE_NAME              # Endpoint details
```

## 📊 Monitoring & Logs

### Log Operations
```bash
# Basic logging
kubectl logs POD_NAME                                # Pod logs
kubectl logs -f POD_NAME                             # Follow logs
kubectl logs POD_NAME -c CONTAINER_NAME              # Specific container
kubectl logs -l app=nginx --tail=100                # Last 100 lines

# Advanced logging
kubectl logs --since=1h POD_NAME                     # Last hour
kubectl logs --since-time=2024-01-01T00:00:00Z POD_NAME # Since timestamp
kubectl logs POD_NAME > pod.log                      # Save to file
```

### Monitoring
```bash
# Pod monitoring
kubectl get pods --watch                            # Watch pod changes
kubectl get events --watch                          # Watch cluster events
kubectl get pods -o jsonpath='{.items[*].status.phase}' # JSON path queries

# Resource monitoring
kubectl api-resources                                # Available resources
kubectl api-versions                                 # API versions
kubectl explain pods                                 # Resource documentation
```

## 🔧 Advanced Operations

### Labels & Selectors
```bash
# Label operations
kubectl label pods POD_NAME app=nginx               # Add label
kubectl label pods POD_NAME app-                     # Remove label
kubectl get pods -l app=nginx                       # Select by label
kubectl get pods -l 'app in (nginx,apache)'         # Label selectors

# Label queries
kubectl get pods --show-labels                      # Show all labels
kubectl get pods -L app,version                     # Specific labels
```

### Namespaces
```bash
# Namespace operations
kubectl get namespaces                              # List namespaces
kubectl create namespace test                       # Create namespace
kubectl delete namespace test                       # Delete namespace
kubectl config set-context --current --namespace=test # Switch namespace

# Cross-namespace
kubectl get pods --all-namespaces                   # All namespaces
kubectl get pods -n kube-system                     # Specific namespace
```

### Jobs & CronJobs
```bash
# Job operations
kubectl create job my-job --image=busybox -- echo "Hello World"
kubectl get jobs                                    # List jobs
kubectl describe job JOB_NAME                       # Job details
kubectl logs job/JOB_NAME                           # Job logs
kubectl delete job JOB_NAME                         # Delete job

# CronJob operations
kubectl create cronjob my-cron --image=busybox --schedule="0 * * * *" -- echo "Hourly job"
kubectl get cronjobs                                # List cronjobs
kubectl describe cronjob CRONJOB_NAME               # CronJob details
kubectl delete cronjob CRONJOB_NAME                 # Delete cronjob
```

## 🚨 Troubleshooting Commands

### Common Issues
```bash
# CrashLoopBackOff
kubectl describe pod POD_NAME                        # Check events
kubectl logs POD_NAME --previous                     # Previous logs

# Pending pods
kubectl describe pod POD_NAME                        # Check conditions
kubectl get nodes                                    # Check node status

# ImagePullBackOff
kubectl describe pod POD_NAME                        # Check image status
kubectl get pods -o wide                             # Check node assignment

# Service unreachable
kubectl get endpoints SERVICE_NAME                   # Check endpoints
kubectl describe service SERVICE_NAME                # Service details
```

### Quick Diagnostics
```bash
# Cluster health
kubectl get componentstatuses                        # Control plane status
kubectl get nodes --no-headers | grep -v Ready       # Unready nodes
kubectl get pods --all-namespaces | grep -v Running  # Non-running pods

# Resource issues
kubectl get pods -o jsonpath='{.items[*].status.containerStatuses[*].state}' | jq .
kubectl describe pod POD_NAME | grep -A 5 Conditions
```

## 📋 Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kl='kubectl logs'
alias ke='kubectl edit'
alias kx='kubectl exec -it'
```

---

**Pro Tips:**
- Use `--dry-run=client` to preview changes
- Use `-o yaml` to see full resource definitions
- Use `--watch` to monitor resource changes
- Use `kubectl explain` to understand resource fields
- Use labels and selectors for flexible resource management
