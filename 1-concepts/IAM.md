# GCP Identity and Access Management (IAM)

## Overview
IAM controls **WHO** can do **WHAT** on **WHICH** resources in GCP. It's a critical component of GCP security and access control.

**Core Concept:** Who → Role → Resources

---

## Principal Identity Model

### 1. **Google Accounts**
- Personal Google accounts (gmail.com, googlemail.com)
- Used for testing or individual developers
- Not recommended for production

### 2. **Service Accounts**
- Machine-to-machine authentication
- No human associated
- Can be used by applications or scheduled tasks
- Identified by email: `SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com`

**Common Use Cases:**
- Application authenticating to GCP APIs
- Compute Engine VM sending data to Cloud Storage
- Cloud Functions calling other GCP services
- External systems authenticating to GCP

**Create Service Account:**
```bash
# Create service account
gcloud iam service-accounts create my-service-account \
  --display-name="My Service Account"

# Get service account email
gcloud iam service-accounts list

# Create and download key (for external authentication)
gcloud iam service-accounts keys create key.json \
  --iam-account=SA_EMAIL
```

### 3. **Google Groups**
- Group of email addresses
- Can be internal (G Suite) or external
- Simplifies permission management
- Email: `group-name@example.com`

**Advantages:**
- Easy bulk user management
- Dynamic group membership
- Centralized access control

### 4. **Cloud Identity Domains**
- Managed user directory (like Active Directory)
- Integrates with SSO/SAML
- 2-factor authentication support
- External users can be invited

### 5. **AllUsers & AllAuthenticatedUsers**
- **`allUsers`:** Anyone on the internet (public access)
- **`allAuthenticatedUsers`:** Any Google account holder
- Use with extreme caution

---

## Role-Based Access Control (RBAC)

### Role Types

#### 1. **Basic Roles** (Legacy - Not Recommended)
- Broad, project-level permissions
- **Viewer:** Read-only access
- **Editor:** View and modify
- **Owner:** Full control + billing access

⚠️ **Why Avoid:**
- Too permissive
- Cannot be applied at resource level
- Not suitable for production environments
- Use predefined roles instead

#### 2. **Predefined Roles**
- Created and maintained by Google
- Service-specific (e.g., SQL Admin, GKE Admin)
- Named: `roles/SERVICE.ROLE`
- Best practice for production

**Examples:**
```
roles/compute.admin          # Full Compute Engine access
roles/compute.instanceAdmin  # Manage GCE instances only
roles/storage.objectViewer   # Read-only Cloud Storage
roles/storage.objectAdmin    # Full Cloud Storage access
roles/cloudsql.admin         # CloudSQL administration
roles/container.admin        # Full GKE access
```

**Best Practices:**
```bash
# ✅ GOOD: Grant specific, minimal roles
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/compute.instanceAdmin

# ❌ AVOID: Basic roles
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/editor
```

#### 3. **Custom Roles**
- Defined by you with specific permissions
- More control than predefined roles
- Named: `organizations/ORG_ID/roles/roleName`

**Create Custom Role:**
```bash
gcloud iam roles create custom-role \
  --project=PROJECT_ID \
  --title="Custom Role" \
  --description="Custom role description" \
  --permissions=compute.instances.get,compute.instances.list
```

---

## Permissions

**Permission Format:** `service.resource.action`

**Examples:**
```
compute.instances.create      # Create GCE instance
compute.instances.delete      # Delete GCE instance
storage.buckets.get           # Read bucket metadata
storage.objects.list          # List objects in bucket
cloudsql.instances.get        # Get CloudSQL instance
container.clusters.create     # Create GKE cluster
```

---

## IAM Binding

**Binding:** Links a member (WHO) → role (WHAT) → resources (WHERE)

### Viewing IAM Bindings

```bash
# Get IAM policy for project
gcloud projects get-iam-policy PROJECT_ID

# Get IAM policy for resource (e.g., Cloud Storage bucket)
gsutil iam get gs://BUCKET_NAME

# Get IAM policy for service account
gcloud iam service-accounts get-iam-policy SA_EMAIL
```

### Granting Roles

```bash
# Grant role to user
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:USER_EMAIL \
  --role=roles/compute.admin

# Grant role to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:SA_EMAIL \
  --role=roles/storage.admin

# Grant role to group
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=group:GROUP_EMAIL \
  --role=roles/viewer
```

### Revoking Roles

```bash
# Revoke role from member
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member=user:USER_EMAIL \
  --role=roles/editor
```

---

## Service Account Key Management

### Types of Keys

1. **User-managed Keys** (JSON)
   - Downloaded to your machine
   - You manage lifecycle
   - Risk if exposed

```bash
# Create key
gcloud iam service-accounts keys create ~/key.json \
  --iam-account=SA_EMAIL

# List keys
gcloud iam service-accounts keys list \
  --iam-account=SA_EMAIL

# Delete key
gcloud iam service-accounts keys delete KEY_ID \
  --iam-account=SA_EMAIL
```

2. **Google-managed Keys**
   - Google manages lifecycle
   - Automatically rotated
   - Only available to service account

---

## IAM Best Practices

### 1. **Principle of Least Privilege (PoLP)**
- Grant minimum permissions needed
- Regularly audit and remove unused roles
- Use custom roles for specific requirements

```bash
# ✅ GOOD: Service account with storage.objectViewer
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:app@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.objectViewer

# ❌ AVOID: Service account with storage.admin
```

### 2. **Use Service Accounts for Applications**
```bash
# Create dedicated service account per app
gcloud iam service-accounts create app-backend \
  --display-name="App Backend"

# Grant minimum required permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:app-backend@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.objectViewer

# Attach to compute instance
gcloud compute instances create my-instance \
  --service-account=app-backend@PROJECT_ID.iam.gserviceaccount.com
```

### 3. **Never Use Default Service Account**
- Default SA: `PROJECT_NUMBER-compute@developer.gserviceaccount.com`
- Create specific service accounts per workload
- Default has too many permissions

### 4. **Secure Service Account Keys**
- Rotate user-managed keys every 90 days
- Use Google-managed keys when possible
- Store JSON keys securely (e.g., secret vault)
- Don't commit keys to version control

```bash
# NEVER do this:
git commit key.json  # ❌ DON'T!
```

### 5. **Enable Audit Logging**
```bash
# Check audit logs for IAM changes
gcloud logging read "resource.type=gce_instance AND \
  protoPayload.methodName=compute.instances.create" \
  --project=PROJECT_ID \
  --limit=10 \
  --format=json
```

### 6. **Use IAM Conditions** (Advanced)
- Time-based access
- Resource-based conditions
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=user:USER_EMAIL \
  --role=roles/compute.admin \
  --condition='resource.name.startsWith("projects/PROJECT_ID/zones/us-central1-a")'
```

---

## Common IAM Scenarios

### Scenario 1: Developer Access to GKE Cluster
```bash
# Create service account
gcloud iam service-accounts create gke-dev \
  --display-name="GKE Developer"

# Grant container.developer role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:gke-dev@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/container.developer

# Grant read-only storage access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:gke-dev@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.objectViewer
```

### Scenario 2: Application Accessing Cloud Storage
```bash
# Create service account
gcloud iam service-accounts create app-sa \
  --display-name="Application Service Account"

# Grant storage viewer role
gcloud storage buckets add-iam-policy-binding gs://BUCKET_NAME \
  --member=serviceAccount:app-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.objectViewer

# Grant storage writer role for specific objects
gcloud storage buckets add-iam-policy-binding gs://BUCKET_NAME \
  --member=serviceAccount:app-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.objectCreator
```

### Scenario 3: CI/CD Pipeline Access (CloudBuild)
```bash
# Grant Cloud Build necessary permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/compute.admin

# Grant Artifact Registry access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/artifactregistry.writer
```

---

## IAM Policy JSON Format

```json
{
  "bindings": [
    {
      "role": "roles/viewer",
      "members": [
        "user:user@example.com",
        "serviceAccount:sa@project.iam.gserviceaccount.com"
      ]
    },
    {
      "role": "roles/editor",
      "members": [
        "group:dev-team@example.com"
      ]
    }
  ],
  "etag": "..."
}
```

---

## Troubleshooting IAM Issues

```bash
# Test if service account has permission
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:SA_EMAIL"

# Check service account permissions
gcloud iam service-accounts get-iam-policy SA_EMAIL

# Enable IAM API if not available
gcloud services enable iam.googleapis.com
```

---

## Interview Tips

✅ **Know:**
- Difference between basic, predefined, and custom roles
- What service accounts are and when to use them
- Principle of least privilege
- How to create and manage service account keys
- IAM inheritance from organization/folder/project

❌ **Avoid:**
- Granting basic roles (Editor, Owner) in production
- Using default service account
- Sharing service account keys
- Misunderstanding member naming format
- Not documenting your IAM structure

