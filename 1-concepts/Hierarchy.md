# GCP Resource Hierarchy

## Overview
GCP uses a hierarchical structure for organizing and managing resources. Understanding this hierarchy is fundamental for effective resource management, IAM, and billing.

## Hierarchy Levels (Top to Bottom)

```
Organization
    └── Folder (Optional, nested allowed)
        └── Project
            └── Resources (GCE, CloudSQL, etc.)
```

---

## 1. Organization

**What it is:**
- Top-level entity in the GCP hierarchy
- Represents your enterprise/company
- Optional but recommended for large deployments

**Key Points:**
- Only ONE organization per customer
- Organization Admin manages the entire hierarchy
- Billing centralization
- Policy enforcement across all projects
- Audit logging at organization level

**Common Tasks:**
```bash
# Get organization ID
gcloud organizations list

# Set organization policies
gcloud resource-manager org-policies set-policy policy.yaml --project=PROJECT_ID
```

---

## 2. Folders

**What it is:**
- Optional organizational unit
- Can be nested (max 10 levels deep)
- Groups related projects
- Useful for teams, environments, or business units

**Benefits:**
- Team isolation (e.g., `Frontend-Team`, `Backend-Team`)
- Environment separation (e.g., `Dev`, `Staging`, `Prod`)
- Policy inheritance from parent folder
- Simplified billing tracking by folder
- Granular IAM permissions

**Common Tasks:**
```bash
# Create folder
gcloud resource-manager folders create \
  --display-name="Development" \
  --organization=ORGANIZATION_ID

# List folders
gcloud resource-manager folders list \
  --organization=ORGANIZATION_ID

# Set IAM policy on folder
gcloud resource-manager folders set-iam-policy FOLDER_ID policy.json
```

---

## 3. Projects

**What it is:**
- Container for all GCP resources
- Resources MUST belong to a project
- Billing is tied to projects
- Unique project ID and name
- Can be in ONE folder or organization

**Key Characteristics:**
- **Project ID:** Globally unique, immutable, used in APIs
- **Project Name:** Human-readable, mutable
- **Project Number:** Unique number assigned by GCP

**Project Setup:**
```bash
# Create a project
gcloud projects create my-project \
  --name="My Project" \
  --folder=FOLDER_ID

# Set default project
gcloud config set project PROJECT_ID

# List all projects
gcloud projects list

# Get project details
gcloud projects describe PROJECT_ID
```

---

## 4. Resources

**What it is:**
- Actual GCP services/instances
- VM instances, databases, storage buckets, etc.
- Always belong to a project
- Subject to project-level IAM and billing

**Examples:**
- Compute Engine instances (GCE)
- Cloud Storage buckets
- CloudSQL databases
- Kubernetes clusters (GKE)
- App Engine applications
- Cloud Functions

---

## IAM Inheritance

IAM policies are inherited down the hierarchy:

```
Organization IAM Policy
        ↓ (inherited)
    Folder IAM Policy
        ↓ (inherited)
    Project IAM Policy
        ↓ (inherited)
    Resource IAM Policy
```

**Example:**
- If `Editor` role is granted at Organization level, all projects inherit it
- Resource-level permissions can ADD restrictions (principle of least privilege)
- Child permissions cannot override parent restrictions

---

## Billing Hierarchy

```
Organization
    └── Billing Account (1-N relationship)
        └── Projects (each project linked to ONE billing account)
            └── Services (GCE, CloudSQL, etc.)
```

**Key Points:**
- One organization can have multiple billing accounts
- Each project must be linked to exactly ONE billing account
- Billing reports can be organized by folder, labels, or service
- Budget alerts can be set at billing account level

---

## Best Practices

### 1. **Organization Structure**
```
Organization
├── Folder: Development
│   ├── Project: dev-app-backend
│   ├── Project: dev-database
│   └── Project: dev-data-pipeline
├── Folder: Staging
│   ├── Project: staging-app-backend
│   └── Project: staging-database
└── Folder: Production
    ├── Project: prod-app-backend
    ├── Project: prod-database
    └── Project: prod-data-pipeline
```

### 2. **Naming Conventions**
- **Organizations:** Company name
- **Folders:** Tier/Environment (Dev, Staging, Prod)
- **Projects:** `<app-name>-<env>` (e.g., `myapp-prod`)
- Use lowercase, hyphens for readability

### 3. **IAM at Each Level**
- **Organization:** Org Admin, Billing Admin, Security Officer
- **Folder:** Folder Admin, Project Creator
- **Project:** Project Editor, Project Viewer, custom roles
- **Resource:** Service account, can be granular

### 4. **Billing Management**
- Create separate billing accounts for different cost centers
- Use labels on resources for detailed cost tracking
- Set up budget alerts and recommendations
- Monitor costs by folder and project

### 5. **Audit & Governance**
- Enable Cloud Audit Logs at organization level
- Set organization policies to enforce compliance
- Use resource hierarchy for policy enforcement
- Implement least privilege at each level

---

## Common Commands Reference

```bash
# Organization
gcloud organizations list
gcloud organizations describe ORG_ID

# Folders
gcloud resource-manager folders create --display-name="Dev"
gcloud resource-manager folders list --organization=ORG_ID
gcloud resource-manager folders delete FOLDER_ID

# Projects
gcloud projects create PROJECT_ID --name="Project Name"
gcloud projects list
gcloud projects delete PROJECT_ID
gcloud config set project PROJECT_ID

# IAM
gcloud members add-binding RESOURCE_ID --member=MEMBER --role=ROLE
gcloud resource-manager folders get-iam-policy FOLDER_ID
```

---

## Interview Tips

✅ **Know:**
- Why organization is optional but recommended
- How IAM inheritance works
- Difference between Project ID and Project Number
- How billing is tied to projects
- Use cases for folders (team isolation, environment separation)

❌ **Avoid:**
- Confusing Project ID with Project Number
- Not planning hierarchy before creating resources
- Mixing multiple environments in one project
- Ignoring folder structure for IAM management

