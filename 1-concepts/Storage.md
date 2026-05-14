# GCP Storage Services

## Overview
GCP offers multiple storage solutions for different use cases. Choosing the right storage is critical for performance, cost, and architecture.

---

## Storage Solution Comparison

| Service | Type | Use Case | Consistency | Cost |
|---------|------|----------|-------------|------|
| Cloud Storage | Object Storage | Media, backups, data lakes | Eventually consistent | Low |
| Cloud SQL | Relational DB | Traditional applications, OLTP | Strong | Medium |
| Firestore | NoSQL Document | Mobile apps, real-time, flexible schema | Strong | Variable |
| Cloud Datastore | NoSQL Document | High scalability, auto-sharding | Eventually consistent | Low (deprecated) |
| Cloud BigTable | Wide-column DB | Time-series, analytics, billions of rows | Strong | Medium-High |
| Memorystore | In-memory cache | Session cache, real-time analytics | Volatile | Medium |

---

## Cloud Storage

**What it is:**
- Fully managed object storage (like S3 in AWS)
- Organized in buckets
- Objects stored with hierarchical naming (no true folders)
- Highly available, durable, infinitely scalable

### Storage Classes

| Class | Availability | Access Frequency | Cost | Use Case |
|-------|--------------|------------------|------|----------|
| **Standard** | 99.99% | Any time | High | Immediate access, web content |
| **Nearline** | 99.95% | < 1x/month | Medium | Backups, disaster recovery |
| **Coldline** | 99.95% | < 1x/quarter | Low | Archives, compliance |
| **Archive** | 99.95% | < 1x/year | Lowest | Long-term archives |

### Creating and Managing Buckets

```bash
# Create bucket (must be globally unique)
gsutil mb gs://my-unique-bucket-name

# Create bucket with specific location
gsutil mb -l US -c STANDARD gs://my-bucket

# Create bucket with versioning
gsutil versioning set on gs://my-bucket

# Set uniform bucket-level access
gsutil uniformbucketlevelaccess set on gs://my-bucket

# List buckets
gsutil ls

# Get bucket details
gsutil stat gs://my-bucket
```

### Uploading/Downloading Objects

```bash
# Upload single file
gsutil cp local-file.txt gs://my-bucket/

# Upload directory recursively
gsutil -m cp -r local-directory/ gs://my-bucket/directory/

# Download file
gsutil cp gs://my-bucket/file.txt ./local-file.txt

# Download entire bucket
gsutil -m cp -r gs://my-bucket/ ./local-directory/

# Upload with compression
gsutil -h "Content-Encoding:gzip" cp file.tar.gz gs://my-bucket/

# Set object metadata
gsutil -h "Cache-Control:public, max-age=3600" cp file.txt gs://my-bucket/
```

### Access Control

```bash
# Make object public (NOT recommended)
gsutil acl ch -u AllUsers:R gs://my-bucket/file.txt

# Grant user access
gsutil iam ch user:user@example.com:objectViewer gs://my-bucket

# Grant service account access
gsutil iam ch serviceAccount:sa@project.iam.gserviceaccount.com:objectAdmin gs://my-bucket

# Grant group access
gsutil iam ch group:dev-team@example.com:objectCreator gs://my-bucket

# Get IAM policy
gsutil iam get gs://my-bucket
```

### Lifecycle Rules

```bash
# Create lifecycle policy (JSON)
cat > lifecycle.json <<EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 365}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "Coldline"},
        "condition": {"age": 90}
      }
    ]
  }
}
EOF

# Apply lifecycle policy
gsutil lifecycle set lifecycle.json gs://my-bucket

# Get current lifecycle policy
gsutil lifecycle get gs://my-bucket
```

---

## Cloud SQL

**What it is:**
- Fully managed relational database
- Supports MySQL, PostgreSQL, SQL Server
- Automated backups, replication, updates
- Connects via private IP or public IP

### Database Options

```
MySQL 5.7 / 8.0
PostgreSQL 11 / 12 / 13 / 14 / 15
SQL Server 2019 / 2022
```

### Creating and Managing Instances

```bash
# Create MySQL instance
gcloud sql instances create my-mysql-db \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --region=us-central1

# Create PostgreSQL instance with HA
gcloud sql instances create my-postgres-db \
  --database-version=POSTGRES_15 \
  --tier=db-n1-standard-1 \
  --region=us-central1 \
  --availability-type=REGIONAL

# Get instance details
gcloud sql instances describe my-mysql-db

# List all instances
gcloud sql instances list

# Connect to instance
gcloud sql connect my-mysql-db --user=root
```

### User and Database Management

```bash
# Create database
gcloud sql databases create my-app-db \
  --instance=my-mysql-db

# Create user
gcloud sql users create app-user \
  --instance=my-mysql-db \
  --password=SecurePassword123

# List databases
gcloud sql databases list --instance=my-mysql-db

# List users
gcloud sql users list --instance=my-mysql-db
```

### Backups and Replication

```bash
# Create backup
gcloud sql backups create \
  --instance=my-mysql-db

# List backups
gcloud sql backups list --instance=my-mysql-db

# Restore from backup
gcloud sql backups restore BACKUP_ID \
  --backup-instance=my-mysql-db

# Create read replica
gcloud sql instances create my-mysql-replica \
  --master-instance-name=my-mysql-db \
  --tier=db-f1-micro \
  --region=us-east1
```

### Application Connection

```bash
# Get public IP
gcloud sql instances describe my-mysql-db \
  --format='value(ipAddresses[0].ipAddress)'

# Connect via Cloud Shell
gcloud sql connect my-mysql-db --user=root

# Connection string for application
# mysql://app-user:password@INSTANCE_IP:3306/database
# psql "host=INSTANCE_IP user=app-user password=password dbname=database"
```

---

## Firestore

**What it is:**
- NoSQL document database
- Real-time updates
- Automatic scaling
- Strong consistency with eventual consistency options

### Firestore vs. Cloud Datastore

- **Firestore:** New, recommended, strong consistency, real-time updates
- **Cloud Datastore:** Legacy, eventually consistent

### Creating Collections and Documents

```bash
# Enable Firestore API
gcloud services enable firestore.googleapis.com

# Create instance (in Native mode)
gcloud firestore databases create --location=us-central1

# Structure:
# Database
#   ├── Collection: users
#   │   ├── Document: user123
#   │   │   ├── name: "John Doe"
#   │   │   ├── email: "john@example.com"
#   │   │   └── posts: [subcollection]
#   │   └── Document: user456
#   └── Collection: posts
#       ├── Document: post789
#       └── Document: post101112
```

### Example Application (Node.js)

```javascript
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// Add document
db.collection('users').add({
  name: 'John Doe',
  email: 'john@example.com',
  timestamp: admin.firestore.FieldValue.serverTimestamp()
});

// Read documents
db.collection('users').where('email', '==', 'john@example.com').get()
  .then(snapshot => {
    snapshot.forEach(doc => console.log(doc.data()));
  });

// Update document
db.collection('users').doc('user123').update({
  email: 'newemail@example.com'
});

// Real-time listener
db.collection('users').onSnapshot(snapshot => {
  snapshot.forEach(doc => {
    console.log(doc.id, doc.data());
  });
});
```

---

## Cloud BigTable

**What it is:**
- Wide-column NoSQL database
- Designed for time-series and analytical workloads
- Stores trillions of rows, millions of columns
- Very high throughput, low latency

### Use Cases
- Time-series data (metrics, logs, sensor data)
- IoT applications
- Analytics on massive datasets
- Real-time dashboards

### Creating and Managing Clusters

```bash
# Create BigTable instance
gcloud bigtable instances create my-bigtable \
  --cluster=my-cluster \
  --cluster-zone=us-central1-a \
  --cluster-num-nodes=3

# Create table with column family
gcloud bigtable tables create analytics \
  --instance=my-bigtable

# Add column family
gcloud bigtable column-families create cf1 \
  --instance=my-bigtable \
  --table=analytics

# Get instance details
gcloud bigtable instances describe my-bigtable
```

### Row/Column Structure Example

```
Table: metrics
Row Key: app123_2024-05-14_10:30:00
  Column Family: data
    ├── cpu: 45.2%
    ├── memory: 78.5%
    └── disk: 62.1%
```

---

## Memorystore

**What it is:**
- Fully managed Redis or Memcached service
- In-memory data store for caching
- Sub-millisecond latency
- Automatic failover and replication

### Use Cases
- Session storage
- Cache layers (reducing database load)
- Real-time leaderboards
- Rate limiting

### Creating Memorystore Instance

```bash
# Create Redis instance
gcloud redis instances create my-cache \
  --size=1 \
  --region=us-central1 \
  --redis-version=7.0

# Create Memcached instance
gcloud memcache instances create my-memcached \
  --node-count=3 \
  --node-cpu=1 \
  --node-memory=1gb \
  --region=us-central1

# Get instance details
gcloud redis instances describe my-cache

# Get connection string
gcloud redis instances describe my-cache \
  --format='value(host,port)'
```

### Application Example (Redis with Python)

```python
import redis

# Connect to Memorystore Redis
r = redis.Redis(
    host='REDIS_HOST',
    port=6379,
    decode_responses=True
)

# Set value
r.set('user:123', 'John Doe', ex=3600)  # 1 hour TTL

# Get value
user = r.get('user:123')

# Increment counter
r.incr('session_count')

# Use as cache
def get_user(user_id):
    cached = r.get(f'user:{user_id}')
    if cached:
        return cached
    
    user = db.query(f'SELECT * FROM users WHERE id={user_id}')
    r.set(f'user:{user_id}', user, ex=3600)
    return user
```

---

## When to Use Which Storage?

### Cloud Storage
✅ Use for:
- Media files (images, videos)
- Backups
- Data lakes
- Log files
- Unstructured data

### Cloud SQL
✅ Use for:
- Traditional OLTP applications
- Complex queries with JOINs
- ACID transactions needed
- Structured data
- Legacy application migration

### Firestore
✅ Use for:
- Real-time mobile/web apps
- Flexible schema
- Rapid development
- Auto-scaling requirements
- Document-oriented data

### Cloud BigTable
✅ Use for:
- Time-series data (millions of writes/sec)
- Analytical queries
- Very large datasets (500GB+)
- Machine learning feature store

### Memorystore
✅ Use for:
- Caching (reduce DB load)
- Session storage
- Real-time counters
- Pub/Sub messaging
- Rate limiting

---

## Best Practices

### Cloud Storage
```bash
# ✅ Enable versioning for critical data
gsutil versioning set on gs://critical-bucket

# ✅ Use lifecycle policies for cost management
gsutil lifecycle set policy.json gs://my-bucket

# ✅ Enable uniform bucket-level access
gsutil uniformbucketlevelaccess set on gs://my-bucket

# ✅ Monitor access with logging
gsutil logging set on -b gs://logs-bucket gs://my-bucket
```

### Cloud SQL
```bash
# ✅ Enable automated backups
gcloud sql instances patch my-db \
  --backup-start-time=03:00 \
  --enable-bin-log

# ✅ Use private IP for security
gcloud sql instances create my-db \
  --no-assign-ip \
  --network=custom-vpc

# ✅ Create read replicas
gcloud sql instances create my-replica \
  --master-instance-name=my-db
```

### Firestore
```javascript
// ✅ Use indexes for complex queries
// Create composite indexes via GCP Console

// ✅ Batch writes for efficiency
let batch = db.batch();
for (let user of users) {
  batch.set(db.collection('users').doc(user.id), user);
}
await batch.commit();

// ✅ Use transactions for consistency
await db.runTransaction(async (transaction) => {
  const doc = await transaction.get(userRef);
  transaction.update(userRef, {balance: doc.get('balance') - 100});
});
```

---

## Interview Tips

✅ **Know:**
- Storage classes and their use cases
- When to use SQL vs. NoSQL
- Replication and backup strategies
- Access control and encryption
- Cost optimization techniques
- Query patterns for each database

❌ **Avoid:**
- Using Cloud Storage for structured data queries
- Not planning backup strategies
- Storing sensitive data without encryption
- Overprovisioning capacity
- Using Datastore (it's deprecated)

