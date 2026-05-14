# BigQuery Cheat Sheet

Essential BigQuery commands for data operations and the Associate Cloud Engineer certification.

## 🔧 bq Command Line Tool

### Authentication & Setup
```bash
# Authentication
bq auth login                                        # Interactive login
bq auth application-default login                     # ADC login
bq auth list                                          # List accounts

# Configuration
bq ls                                                 # List datasets
bq ls -p PROJECT_ID                                   # Project datasets
bq show                                               # Current project
bq show PROJECT_ID                                    # Project info
```

### Project & Dataset Operations
```bash
# Dataset management
bq mk DATASET_NAME                                    # Create dataset
bq mk -d DATASET_NAME                                 # Create if not exists
bq mk --description "My Dataset" DATASET_NAME         # With description
bq ls DATASET_NAME                                    # List tables in dataset
bq show DATASET_NAME                                  # Dataset info
bq rm -r DATASET_NAME                                 # Delete dataset

# Dataset properties
bq update --description "New description" DATASET_NAME
bq update --default_table_expiration 3600000 DATASET_NAME # 1 hour expiration
```

## 📊 Table Operations

### Creating Tables
```bash
# Create empty table
bq mk --table DATASET_NAME.TABLE_NAME \
  column1:STRING,column2:INTEGER,column3:FLOAT

# Create from query result
bq query --destination_table DATASET_NAME.TABLE_NAME \
  --use_legacy_sql=false \
  "SELECT * FROM DATASET_NAME.SOURCE_TABLE LIMIT 1000"

# Create partitioned table
bq mk --table \
  --time_partitioning_type=DAY \
  DATASET_NAME.TABLE_NAME \
  column1:STRING,column2:TIMESTAMP

# Create clustered table
bq mk --table \
  --time_partitioning_type=DAY \
  --clustering_fields=column1,column2 \
  DATASET_NAME.TABLE_NAME \
  schema.json
```

### Table Management
```bash
# List tables
bq ls DATASET_NAME                                    # Tables in dataset
bq ls -a DATASET_NAME                                 # All tables (including hidden)
bq show DATASET_NAME.TABLE_NAME                       # Table info
bq show --format=prettyjson DATASET_NAME.TABLE_NAME   # Detailed info

# Table operations
bq cp DATASET_NAME.TABLE1 DATASET_NAME.TABLE2         # Copy table
bq rm DATASET_NAME.TABLE_NAME                         # Delete table
bq rm -f DATASET_NAME.TABLE_NAME                      # Force delete
```

### Schema Operations
```bash
# Schema management
bq show --schema DATASET_NAME.TABLE_NAME              # Show schema
bq update DATASET_NAME.TABLE_NAME schema.json         # Update schema
bq update --append_table_schema DATASET_NAME.TABLE_NAME column:STRING

# Schema from file
bq mk --table --schema=table_schema.json DATASET_NAME.TABLE_NAME
```

## 🔍 Query Operations

### Running Queries
```bash
# Basic queries
bq query "SELECT * FROM DATASET_NAME.TABLE_NAME LIMIT 10"
bq query --use_legacy_sql=false "SELECT COUNT(*) FROM DATASET_NAME.TABLE_NAME"

# Query with options
bq query --maximum_bytes_billed=1000000 \
  "SELECT * FROM DATASET_NAME.TABLE_NAME"

bq query --dry_run \
  "SELECT * FROM DATASET_NAME.TABLE_NAME"            # Estimate cost

# Save results
bq query --destination_table DATASET_NAME.RESULTS \
  "SELECT * FROM DATASET_NAME.TABLE_NAME WHERE date > '2024-01-01'"
```

### Advanced Query Options
```bash
# Batch queries
bq query --batch \
  "SELECT * FROM DATASET_NAME.LARGE_TABLE"

# Parameterized queries
bq query --parameter="date:DATE:2024-01-01" \
  "SELECT * FROM DATASET_NAME.TABLE_NAME WHERE date = @date"

# Query history
bq ls -j PROJECT_ID                                   # List jobs
bq show -j JOB_ID                                     # Job details
bq cancel JOB_ID                                      # Cancel job
```

## 📥 Data Loading

### Load from Files
```bash
# Load CSV
bq load --source_format=CSV \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/data.csv \
  column1:STRING,column2:INTEGER

# Load JSON
bq load --source_format=NEWLINE_DELIMITED_JSON \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/data.json \
  schema.json

# Load with options
bq load --skip_leading_rows=1 \
  --allow_quoted_newlines \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/data.csv
```

### Load from Cloud Storage
```bash
# Wildcard loading
bq load DATASET_NAME.TABLE_NAME \
  "gs://BUCKET_NAME/data*.csv" \
  schema.json

# Partitioned loading
bq load --time_partitioning_type=DAY \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/data.csv \
  schema.json
```

### Streaming Inserts
```bash
# Insert single row
echo '{"column1":"value1","column2":123}' | \
bq insert DATASET_NAME.TABLE_NAME

# Insert multiple rows
bq insert DATASET_NAME.TABLE_NAME row1.json row2.json

# Insert from file
bq insert DATASET_NAME.TABLE_NAME < data.json
```

## 📤 Data Export

### Export to Cloud Storage
```bash
# Export to CSV
bq extract --destination_format=CSV \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/export.csv

# Export to JSON
bq extract --destination_format=NEWLINE_DELIMITED_JSON \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/export.json

# Export with compression
bq extract --compression=GZIP \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/export.csv.gz
```

### Export Options
```bash
# Field delimiter
bq extract --field_delimiter="|" \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/export.csv

# Print header
bq extract --print_header=true \
  DATASET_NAME.TABLE_NAME \
  gs://BUCKET_NAME/export.csv

# Query results export
bq query --destination_table DATASET_NAME.TEMP_TABLE \
  "SELECT * FROM DATASET_NAME.TABLE_NAME WHERE condition"
bq extract DATASET_NAME.TEMP_TABLE gs://BUCKET_NAME/results.csv
```

## 🔄 Data Transfer Service

### Transfer Configuration
```bash
# List transfers
bq ls --transfer_config                                # List configs
bq ls --transfer_run                                   # List runs

# Create transfer
bq mk --transfer_config \
  --data_source=google_cloud_storage \
  --target_dataset=DATASET_NAME \
  --display_name="GCS Transfer" \
  --params='{"data_path_template":"gs://BUCKET_NAME/*.csv","destination_table_name_template":"table","file_format":"CSV","max_bad_records":"0","skip_leading_rows":"1"}'

# Transfer operations
bq show --transfer_config CONFIG_ID                    # Config details
bq update --transfer_config CONFIG_ID --display_name="New Name"
bq rm --transfer_config CONFIG_ID                      # Delete config
```

## 📊 Dataset & Table Metadata

### Information Queries
```bash
# Dataset info
bq show --format=prettyjson DATASET_NAME              # Dataset metadata
bq ls --format=prettyjson DATASET_NAME                # Tables list

# Table info
bq show --format=prettyjson DATASET_NAME.TABLE_NAME   # Table metadata
bq show --schema --format=prettyjson DATASET_NAME.TABLE_NAME # Schema only

# Storage info
bq show --format=prettyjson DATASET_NAME.TABLE_NAME | jq '.numBytes'
bq show --format=prettyjson DATASET_NAME.TABLE_NAME | jq '.numRows'
```

### Cost Estimation
```bash
# Query cost estimation
bq query --dry_run --format=prettyjson \
  "SELECT * FROM DATASET_NAME.TABLE_NAME" | jq '.statistics.query.totalBytesProcessed'

# Storage costs
bq ls -a DATASET_NAME | while read table; do
  bq show --format=prettyjson DATASET_NAME.$table | jq '.numBytes'
done
```

## 🔐 Access Control

### IAM Permissions
```bash
# Dataset permissions
bq show --format=prettyjson DATASET_NAME | jq '.access'
bq add-iam-policy-binding --member=user:USER@DOMAIN.COM --role=roles/bigquery.dataViewer DATASET_NAME
bq remove-iam-policy-binding --member=user:USER@DOMAIN.COM --role=roles/bigquery.dataViewer DATASET_NAME

# Table permissions
bq add-iam-policy-binding --member=user:USER@DOMAIN.COM --role=roles/bigquery.dataViewer DATASET_NAME.TABLE_NAME
```

### Legacy Access Control
```bash
# ACL management (deprecated but still available)
bq update --source_format=CSV --skip_leading_rows=1 \
  --schema='user_email:STRING,role:STRING' \
  DATASET_NAME.TABLE_NAME \
  acl.csv
```

## 📈 Performance & Optimization

### Query Optimization
```bash
# Query with caching
bq query --use_cache \
  "SELECT * FROM DATASET_NAME.TABLE_NAME"

# Query with result caching disabled
bq query --no_query_cache \
  "SELECT * FROM DATASET_NAME.TABLE_NAME"

# Partition pruning
bq query "SELECT * FROM DATASET_NAME.TABLE_NAME
  WHERE _PARTITIONTIME >= '2024-01-01 00:00:00'
  AND _PARTITIONTIME < '2024-02-01 00:00:00'"
```

### Resource Management
```bash
# Set query priority
bq query --batch \
  "SELECT * FROM DATASET_NAME.LARGE_TABLE"

# Maximum billing
bq query --maximum_bytes_billed=1000000000 \
  "SELECT * FROM DATASET_NAME.TABLE_NAME"

# Job management
bq wait JOB_ID                                       # Wait for job completion
bq cancel JOB_ID                                     # Cancel running job
```

## 🚨 Troubleshooting

### Common Issues
```bash
# Job status
bq show -j JOB_ID                                    # Job details
bq ls -j PROJECT_ID                                  # Recent jobs

# Error details
bq show -j JOB_ID | jq '.status.errors'              # Job errors
bq show -j JOB_ID | jq '.statistics'                 # Job statistics

# Quota issues
bq show                                             # Project info
bq show | jq '.quotaBytesPerSecondPerProject'       # Quota info
```

### Debug Queries
```bash
# Explain query
bq query --dry_run --format=prettyjson \
  "SELECT * FROM DATASET_NAME.TABLE_NAME" | jq '.statistics.query.queryPlan'

# Query validation
bq query --dry_run \
  "SELECT * FROM DATASET_NAME.TABLE_NAME WHERE invalid_column = 1"
```

## 📋 Scripting Examples

### Backup Script
```bash
#!/bin/bash
DATASET="my_dataset"
BACKUP_BUCKET="gs://backups/$(date +%Y%m%d)"

# Export all tables
for table in $(bq ls $DATASET | tail -n +3 | awk '{print $1}'); do
  bq extract --compression=GZIP $DATASET.$table $BACKUP_BUCKET/$table.csv.gz
done
```

### Cost Monitoring
```bash
#!/bin/bash
# Daily cost query
bq query --use_legacy_sql=false "
SELECT
  DATE(creation_time) as date,
  SUM(total_bytes_billed) / POW(1024, 4) as tb_billed,
  SUM(total_bytes_billed) * 5 / POW(1024, 4) as estimated_cost
FROM \`PROJECT_ID.region-us\`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE DATE(creation_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY date
ORDER BY date DESC
"
```

---

**Pro Tips:**
- Use `--dry_run` to estimate query costs before execution
- Use `--maximum_bytes_billed` to prevent unexpected costs
- Use partitioned tables for time-series data
- Use clustering for frequently filtered columns
- Monitor query performance with `INFORMATION_SCHEMA`
