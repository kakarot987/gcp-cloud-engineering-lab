# IAM Cheat Sheet

Essential Identity and Access Management commands for GCP security and access control.

## 🔐 Authentication

### User Authentication
```bash
# Login methods
gcloud auth login                               # Interactive login
gcloud auth login --no-launch-browser           # Headless login
gcloud auth application-default login           # ADC for applications

# Service account authentication
gcloud auth activate-service-account SA_EMAIL --key-file=key.json
export GOOGLE_APPLICATION_CREDENTIALS=key.json

# List accounts
gcloud auth list                                # Active accounts
gcloud auth list --filter=status:ACTIVE         # Active only
gcloud auth revoke SA_EMAIL                     # Revoke account
```

### Access Tokens
```bash
# Generate tokens
gcloud auth print-access-token                  # Access token
gcloud auth print-identity-token               # Identity token
gcloud auth print-refresh-token                # Refresh token

# Token info
gcloud auth print-access-token | jq -R 'split(".") | .[1] | @base64d | fromjson'
```

## 👥 Service Accounts

### Service Account Management
```bash
# Create service accounts
gcloud iam service-accounts create SA_NAME \
  --description="Service account description" \
  --display-name="Display Name"

# List service accounts
gcloud iam service-accounts list               # All service accounts
gcloud iam service-accounts list --filter="email~@PROJECT_ID.iam.gserviceaccount.com"

# Service account details
gcloud iam service-accounts describe SA_EMAIL
```

### Service Account Keys
```bash
# Create keys
gcloud iam service-accounts keys create key.json --iam-account=SA_EMAIL
gcloud iam service-accounts keys create key.p12 --iam-account=SA_EMAIL --key-file-type=p12

# List keys
gcloud iam service-accounts keys list --iam-account=SA_EMAIL
gcloud iam service-accounts keys list --iam-account=SA_EMAIL --filter="keyType=USER_MANAGED"

# Key operations
gcloud iam service-accounts keys describe KEY_ID --iam-account=SA_EMAIL
gcloud iam service-accounts keys delete KEY_ID --iam-account=SA_EMAIL

# Disable key (recommended)
gcloud iam service-accounts keys disable KEY_ID --iam-account=SA_EMAIL
```

### Workload Identity
```bash
# Enable Workload Identity
gcloud container clusters update CLUSTER_NAME \
  --workload-pool=PROJECT_ID.svc.id.goog

# Create Kubernetes service account
kubectl create serviceaccount ksa-name

# Create IAM policy binding
gcloud iam service-accounts add-iam-policy-binding GSA_EMAIL \
  --role=roles/iam.workloadIdentityUser \
  --member="serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]"

# Annotate Kubernetes service account
kubectl annotate serviceaccount KSA_NAME \
  iam.gke.io/gcp-service-account=GSA_EMAIL
```

## 🔑 IAM Roles & Permissions

### Predefined Roles
```bash
# Common roles
roles/viewer                                    # Read-only access
roles/editor                                    # Read-write access
roles/owner                                      # Full access

# Compute Engine roles
roles/compute.admin                             # Full Compute Engine access
roles/compute.instanceAdmin.v1                  # VM instance management
roles/compute.networkAdmin                      # Network management
roles/compute.securityAdmin                     # Security management

# Storage roles
roles/storage.admin                             # Full Cloud Storage access
roles/storage.objectAdmin                       # Object management
roles/storage.objectViewer                      # Object read access

# BigQuery roles
roles/bigquery.admin                            # Full BigQuery access
roles/bigquery.dataEditor                       # Data editing
roles/bigquery.dataViewer                       # Data viewing
roles/bigquery.jobUser                          # Job execution
```

### Custom Roles
```bash
# Create custom role
gcloud iam roles create CUSTOM_ROLE \
  --project=PROJECT_ID \
  --title="Custom Role Title" \
  --description="Custom role description" \
  --permissions=compute.instances.list,compute.instances.get

# List custom roles
gcloud iam roles list --project=PROJECT_ID     # Project roles
gcloud iam roles list                          # Organization roles

# Role details
gcloud iam roles describe CUSTOM_ROLE --project=PROJECT_ID
gcloud iam roles describe roles/viewer         # Predefined role

# Update custom role
gcloud iam roles update CUSTOM_ROLE \
  --project=PROJECT_ID \
  --add-permissions=compute.instances.start \
  --remove-permissions=compute.instances.list

# Delete custom role
gcloud iam roles delete CUSTOM_ROLE --project=PROJECT_ID
```

### IAM Policy Bindings

#### Project Level
```bash
# Get current policy
gcloud projects get-iam-policy PROJECT_ID

# Add member to role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:USER_EMAIL \
  --role=roles/editor

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:SA_EMAIL \
  --role=roles/storage.admin

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=group:GROUP_EMAIL \
  --role=roles/viewer

# Remove member from role
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member=user:USER_EMAIL \
  --role=roles/editor

# Set entire policy
gcloud projects set-iam-policy PROJECT_ID policy.json
```

#### Organization Level
```bash
# Organization policies
gcloud organizations get-iam-policy ORGANIZATION_ID
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member=user:USER_EMAIL \
  --role=roles/resourcemanager.organizationAdmin
```

#### Folder Level
```bash
# Folder policies
gcloud resource-manager folders get-iam-policy FOLDER_ID
gcloud resource-manager folders add-iam-policy-binding FOLDER_ID \
  --member=user:USER_EMAIL \
  --role=roles/editor
```

## 🔒 Resource-Specific Permissions

### Cloud Storage
```bash
# Bucket IAM
gsutil iam ch user:USER_EMAIL:objectViewer gs://BUCKET_NAME
gsutil iam ch serviceAccount:SA_EMAIL:admin gs://BUCKET_NAME
gsutil iam get gs://BUCKET_NAME

# Object ACLs (legacy)
gsutil acl ch -u user:USER_EMAIL:R gs://BUCKET_NAME/object.txt
gsutil acl get gs://BUCKET_NAME/object.txt
```

### BigQuery
```bash
# Dataset permissions
bq add-iam-policy-binding --member=user:USER_EMAIL --role=roles/bigquery.dataEditor DATASET_NAME
bq remove-iam-policy-binding --member=user:USER_EMAIL --role=roles/bigquery.dataEditor DATASET_NAME
bq show --format=prettyjson DATASET_NAME | jq '.access'
```

### Compute Engine
```bash
# Instance access
gcloud compute instances add-iam-policy-binding INSTANCE_NAME \
  --zone=ZONE \
  --member=user:USER_EMAIL \
  --role=roles/compute.instanceAdmin

# OS Login
gcloud compute instances add-metadata INSTANCE_NAME \
  --zone=ZONE \
  --metadata enable-oslogin=TRUE
```

### Kubernetes Engine
```bash
# Cluster access
gcloud container clusters get-credentials CLUSTER_NAME
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=USER_EMAIL

# RBAC
kubectl create rolebinding my-binding \
  --clusterrole=edit \
  --user=USER_EMAIL \
  --namespace=default
```

## 👤 User & Group Management

### Google Workspace Integration
```bash
# Domain-wide delegation
gcloud iam service-accounts add-iam-policy-binding SA_EMAIL \
  --role=roles/iam.serviceAccountTokenCreator \
  --member=user:ADMIN_EMAIL

# Group membership
gcloud identity groups memberships list --group-email=GROUP_EMAIL
gcloud identity groups memberships add MEMBER_EMAIL --group-email=GROUP_EMAIL
```

### Directory API
```bash
# User information
gcloud auth list --format="value(account)"
gcloud projects get-iam-policy PROJECT_ID --flatten="bindings[].members" --filter="bindings.role:roles/owner"
```

## 🔍 IAM Auditing

### Policy Analysis
```bash
# Analyze policies
gcloud asset analyze-iam-policy \
  --project=PROJECT_ID \
  --identity=user:USER_EMAIL

gcloud asset analyze-iam-policy \
  --project=PROJECT_ID \
  --role=roles/editor

# Search for permissions
gcloud asset search-all-iam-policies \
  --scope=projects/PROJECT_ID \
  --query="policy:roles/editor"
```

### Access Reviews
```bash
# Check effective permissions
gcloud iam roles describe roles/editor --format="export" | jq '.includedPermissions'
gcloud projects get-iam-policy PROJECT_ID --flatten="bindings[].members[]" --filter="bindings.members:USER_EMAIL"
```

## 🛡️ Security Best Practices

### Service Account Security
```bash
# Key rotation
gcloud iam service-accounts keys create new-key.json --iam-account=SA_EMAIL
# Update applications with new key
gcloud iam service-accounts keys delete OLD_KEY_ID --iam-account=SA_EMAIL

# Key restrictions
gcloud iam service-accounts keys create key.json \
  --iam-account=SA_EMAIL \
  --key-file-type=json \
  --restrict-to-service=compute.googleapis.com
```

### Principle of Least Privilege
```bash
# Audit current permissions
gcloud projects get-iam-policy PROJECT_ID --format="table(bindings.role, bindings.members)"

# Create minimal custom roles
gcloud iam roles create minimal-role \
  --project=PROJECT_ID \
  --title="Minimal Access Role" \
  --permissions=storage.objects.get,storage.objects.list

# Use conditions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:USER_EMAIL \
  --role=roles/storage.objectViewer \
  --condition="expression=request.time < timestamp('2024-12-31T23:59:59Z'),title=Temp Access"
```

### Security Audits
```bash
# Find overly permissive roles
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members[]" \
  --filter="bindings.role:roles/owner OR bindings.role:roles/editor"

# Check for external users
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members[]" \
  --filter="-bindings.members:user:*@DOMAIN.com"
```

## 🚨 Troubleshooting

### Permission Issues
```bash
# Check current user
gcloud auth list --filter=status:ACTIVE

# Test permissions
gcloud projects get-iam-policy PROJECT_ID --filter="bindings.members:$(gcloud auth list --format='value(account)')"

# Check service account permissions
gcloud iam service-accounts get-iam-policy SA_EMAIL
```

### Common Errors
```bash
# Permission denied
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:$(gcloud auth list --format='value(account)') \
  --role=roles/iam.securityReviewer

# Service account not found
gcloud iam service-accounts list --filter="email:SA_EMAIL"

# Key expired
gcloud iam service-accounts keys create new-key.json --iam-account=SA_EMAIL
```

### Debug Commands
```bash
# Verbose output
gcloud iam service-accounts list --verbosity=debug
gcloud projects get-iam-policy PROJECT_ID --verbosity=debug

# API debugging
gcloud config set core/log_http true
gcloud iam roles list
gcloud config set core/log_http false
```

## 📋 Policy Management

### Policy Files
```json
{
  "bindings": [
    {
      "role": "roles/editor",
      "members": [
        "user:user@example.com",
        "serviceAccount:sa@project.iam.gserviceaccount.com"
      ]
    }
  ]
}
```

### Batch Operations
```bash
# Bulk policy updates
gcloud projects set-iam-policy PROJECT_ID policy.json

# Export policies
gcloud projects get-iam-policy PROJECT_ID --format=json > policy.json

# Compare policies
diff policy-before.json policy-after.json
```

---

**Pro Tips:**
- Use service accounts instead of user accounts for applications
- Rotate service account keys regularly (90 days max)
- Follow principle of least privilege
- Use custom roles for fine-grained permissions
- Enable Workload Identity for GKE
- Audit IAM policies regularly
- Use conditions for temporary access
- Avoid using primitive roles (Owner/Editor/Viewer)
