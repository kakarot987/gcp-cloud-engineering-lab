# gsutil Cheat Sheet

Essential commands for Google Cloud Storage operations and the Associate Cloud Engineer certification.

## 🗄️ Bucket Operations

### Creating & Managing Buckets
```bash
# Create buckets
gsutil mb gs://BUCKET_NAME                                    # Create bucket
gsutil mb -p PROJECT_ID gs://BUCKET_NAME                      # Specify project
gsutil mb -c regional -l us-central1 gs://BUCKET_NAME         # Regional bucket
gsutil mb -c multi_regional -l us gs://BUCKET_NAME            # Multi-regional

# List buckets
gsutil ls                                                    # All buckets
gsutil ls -p PROJECT_ID                                      # Project buckets
gsutil ls -b gs://BUCKET_NAME                                # Bucket details

# Bucket information
gsutil ls -L gs://BUCKET_NAME                                # Bucket metadata
gsutil du -s gs://BUCKET_NAME                                # Bucket size
gsutil du -sh gs://BUCKET_NAME                               # Human-readable size
```

### Bucket Configuration
```bash
# Versioning
gsutil versioning set on gs://BUCKET_NAME                    # Enable versioning
gsutil versioning set off gs://BUCKET_NAME                   # Disable versioning
gsutil versioning get gs://BUCKET_NAME                       # Check status

# Lifecycle management
gsutil lifecycle set lifecycle.json gs://BUCKET_NAME         # Set lifecycle
gsutil lifecycle get gs://BUCKET_NAME                        # Get lifecycle

# Labels
gsutil label set label.json gs://BUCKET_NAME                 # Set labels
gsutil label get gs://BUCKET_NAME                            # Get labels
gsutil label ch -l key:value gs://BUCKET_NAME                # Change labels
```

### Permissions & Access
```bash
# IAM permissions
gsutil iam ch user:USER_EMAIL:objectViewer gs://BUCKET_NAME   # Grant access
gsutil iam ch -r user:USER_EMAIL:objectAdmin gs://BUCKET_NAME # Recursive grant
gsutil iam get gs://BUCKET_NAME                              # Get IAM policy

# Public access
gsutil iam ch allUsers:objectViewer gs://BUCKET_NAME         # Make public
gsutil iam ch -d allUsers:objectViewer gs://BUCKET_NAME      # Remove public

# ACLs (legacy)
gsutil acl set public-read gs://BUCKET_NAME/file.txt         # Public file
gsutil acl get gs://BUCKET_NAME                              # Get bucket ACL
gsutil acl ch -u user:USER_EMAIL:R gs://BUCKET_NAME          # Grant read
```

## 📁 File Operations

### Upload & Download
```bash
# Upload files
gsutil cp local-file.txt gs://BUCKET_NAME/                    # Single file
gsutil cp -r local-dir gs://BUCKET_NAME/                      # Directory
gsutil cp *.txt gs://BUCKET_NAME/                            # Wildcard upload

# Download files
gsutil cp gs://BUCKET_NAME/file.txt local-file.txt           # Single file
gsutil cp -r gs://BUCKET_NAME/dir local-dir                  # Directory
gsutil cp gs://BUCKET_NAME/*.txt .                           # Wildcard download

# Streaming
echo "Hello World" | gsutil cp - gs://BUCKET_NAME/hello.txt   # Stream upload
gsutil cp gs://BUCKET_NAME/file.txt - | cat                  # Stream download
```

### File Management
```bash
# List files
gsutil ls gs://BUCKET_NAME/                                  # List contents
gsutil ls -l gs://BUCKET_NAME/                               # With details
gsutil ls -lr gs://BUCKET_NAME/                              # Recursive list
gsutil ls -la gs://BUCKET_NAME/                              # All versions

# File information
gsutil ls -L gs://BUCKET_NAME/file.txt                       # File metadata
gsutil stat gs://BUCKET_NAME/file.txt                        # File status

# Move & rename
gsutil mv gs://BUCKET_NAME/file.txt gs://BUCKET_NAME/new-file.txt
gsutil mv gs://BUCKET_NAME/file.txt gs://BUCKET2_NAME/       # Move to different bucket

# Copy between buckets
gsutil cp gs://BUCKET1/file.txt gs://BUCKET2/file.txt
gsutil cp -r gs://BUCKET1/dir gs://BUCKET2/
```

### Deletion
```bash
# Delete files
gsutil rm gs://BUCKET_NAME/file.txt                          # Single file
gsutil rm gs://BUCKET_NAME/dir/**                            # Directory contents
gsutil rm -r gs://BUCKET_NAME/dir                            # Directory
gsutil rm gs://BUCKET_NAME/*.txt                             # Wildcard delete

# Versioned deletes
gsutil rm -a gs://BUCKET_NAME/file.txt                       # All versions
gsutil rm gs://BUCKET_NAME/file.txt#version-id               # Specific version

# Empty bucket
gsutil rm -a gs://BUCKET_NAME/**                             # All objects & versions
```

## 🔄 Synchronization

### Directory Sync
```bash
# Basic sync
gsutil rsync local-dir gs://BUCKET_NAME/                     # Upload sync
gsutil rsync gs://BUCKET_NAME/ local-dir                     # Download sync

# Sync options
gsutil rsync -r local-dir gs://BUCKET_NAME/                  # Recursive
gsutil rsync -d gs://BUCKET_NAME/ local-dir                  # Delete extra files
gsutil rsync -x "*.log" local-dir gs://BUCKET_NAME/          # Exclude patterns

# Dry run
gsutil rsync -n local-dir gs://BUCKET_NAME/                  # Preview changes
gsutil rsync -c local-dir gs://BUCKET_NAME/                  # Checksum sync
```

### Advanced Sync
```bash
# Parallel operations
gsutil -m rsync -r local-dir gs://BUCKET_NAME/                # Multi-threaded
gsutil -m cp -r local-dir gs://BUCKET_NAME/                   # Parallel copy

# Large file handling
gsutil cp -o GSUtil:parallel_composite_upload_threshold=150M large-file gs://BUCKET_NAME/
```

## 🔍 Searching & Filtering

### Find Operations
```bash
# Find files
gsutil ls gs://BUCKET_NAME/**/*.txt                          # Find by extension
gsutil ls gs://BUCKET_NAME/** | grep "pattern"               # Grep search

# Filter by size
gsutil ls -l gs://BUCKET_NAME/ | awk '$2 > 1000000'          # Files > 1MB
gsutil ls -l gs://BUCKET_NAME/ | sort -k2 -n                 # Sort by size

# Filter by date
gsutil ls -l gs://BUCKET_NAME/ | grep "2024-01-"              # January 2024
```

### Metadata Queries
```bash
# Custom metadata
gsutil setmeta -h "Content-Type:text/plain" gs://BUCKET_NAME/file.txt
gsutil ls -L gs://BUCKET_NAME/file.txt | grep "Content-Type"

# Storage class
gsutil ls -L gs://BUCKET_NAME/ | grep "StorageClass"          # Check classes
gsutil rewrite -s nearline gs://BUCKET_NAME/file.txt         # Change class
```

## ⚡ Performance & Optimization

### Transfer Optimization
```bash
# Parallel transfers
gsutil -m cp -r local-dir gs://BUCKET_NAME/                   # Multi-threaded
gsutil -o GSUtil:parallel_thread_count=4 cp large-file gs://BUCKET_NAME/

# Chunk size
gsutil -o GSUtil:parallel_composite_upload_threshold=100M cp large-file gs://BUCKET_NAME/

# Bandwidth control
gsutil -o GSUtil:max_upload_speed=50m cp large-file gs://BUCKET_NAME/
```

### Caching & Resume
```bash
# Resume interrupted transfers
gsutil cp large-file gs://BUCKET_NAME/                       # Auto-resume
gsutil -o GSUtil:check_hashes=if_fast_else_skip cp large-file gs://BUCKET_NAME/

# Disable caching
gsutil -o GSUtil:use_magicfile=False cp file.txt gs://BUCKET_NAME/
```

## 🔧 Configuration

### gsutil Configuration
```bash
# Configuration file
gsutil config                                                 # Interactive config
cat ~/.gsutil/gsutil.cfg                                     # View config

# Environment variables
export GSUTIL_OPTS="-o GSUtil:parallel_thread_count=4"       # Set options
export BOTO_CONFIG=/path/to/boto.cfg                         # Custom config
```

### Authentication
```bash
# Service account
export GOOGLE_APPLICATION_CREDENTIALS=key.json
gsutil ls                                                     # Authenticated access

# Access token
gcloud auth print-access-token | gsutil -o GSUtil:use_oauth2=True ls
```

## 📊 Monitoring & Logging

### Transfer Statistics
```bash
# Progress and stats
gsutil -D cp large-file gs://BUCKET_NAME/                     # Debug output
gsutil cp -v large-file gs://BUCKET_NAME/                     # Verbose output

# Performance metrics
gsutil perfdiag gs://BUCKET_NAME/                             # Performance test
gsutil perfdiag -n 10 gs://BUCKET_NAME/file.txt               # File test
```

### Logging
```bash
# gsutil logs
gsutil -o GSUtil:default_project_id=PROJECT_ID cp file.txt gs://BUCKET_NAME/

# Cloud Logging integration
gcloud logging read "resource.type=gcs_bucket" --filter="bucket_name=BUCKET_NAME"
```

## 🚨 Troubleshooting

### Common Issues
```bash
# Permission errors
gsutil iam get gs://BUCKET_NAME                              # Check permissions
gsutil acl get gs://BUCKET_NAME                              # Check ACLs

# Connection issues
gsutil -D ls                                                # Debug connection
gsutil -o GSUtil:check_hashes=never ls                      # Skip checksums

# Memory issues
gsutil -o GSUtil:parallel_thread_count=1 cp large-file gs://BUCKET_NAME/
```

### Error Recovery
```bash
# Resume failed transfers
gsutil cp -c large-file gs://BUCKET_NAME/                    # Continue transfer
gsutil rsync -C local-dir gs://BUCKET_NAME/                  # Continue sync

# Verify transfers
gsutil hash local-file.txt                                  # Local hash
gsutil ls -L gs://BUCKET_NAME/file.txt | grep "Hash"         # Remote hash
```

## 📋 Batch Operations

### Scripting Examples
```bash
# Backup script
#!/bin/bash
BUCKET="gs://backup-$(date +%Y%m%d)"
gsutil mb $BUCKET
gsutil cp -r /important/data $BUCKET/
gsutil lifecycle set lifecycle.json $BUCKET

# Cleanup script
#!/bin/bash
gsutil ls gs:// | grep "old-" | xargs gsutil rm -r
```

### Automation
```bash
# Cron job for backups
0 2 * * * /usr/local/bin/gsutil rsync -r /data gs://daily-backup/

# Monitor bucket size
gsutil du -s gs://BUCKET_NAME/ | awk '{print $1/1024/1024 " MB"}'
```

---

**Pro Tips:**
- Use `-m` flag for parallel operations on large transfers
- Use `-r` flag for recursive operations on directories
- Use `-d` flag with rsync to delete extra files
- Use wildcards (*) for batch operations
- Use `gsutil -q` to suppress output in scripts
