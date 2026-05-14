# Monitoring Cheat Sheet

Essential GCP monitoring and logging commands for observability and troubleshooting.

## 📊 Cloud Monitoring

### Basic Monitoring
```bash
# List monitored resources
gcloud monitoring metrics list                    # Available metrics
gcloud monitoring metrics descriptors list        # Metric descriptors

# Query metrics
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/cpu/utilization' \
  --project PROJECT_ID \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z

# Metric details
gcloud monitoring metrics descriptors describe \
  compute.googleapis.com/instance/cpu/utilization
```

### Dashboards & Charts
```bash
# List dashboards
gcloud monitoring dashboards list                 # All dashboards
gcloud monitoring dashboards describe DASHBOARD_ID # Dashboard details

# Create dashboard
gcloud monitoring dashboards create --config-from-file=dashboard.json

# Update dashboard
gcloud monitoring dashboards update DASHBOARD_ID --config-from-file=dashboard.json
```

### Alerts & Policies
```bash
# Alert policies
gcloud monitoring alert-policies list             # List policies
gcloud monitoring alert-policies describe POLICY_ID # Policy details

# Create alert policy
gcloud monitoring alert-policies create \
  --display-name="High CPU Usage" \
  --condition="metric.type=compute.googleapis.com/instance/cpu/utilization AND metric.threshold > 0.8" \
  --notification-channels=CHANNEL_ID

# Update alert policy
gcloud monitoring alert-policies update POLICY_ID \
  --display-name="Updated CPU Alert"

# Delete alert policy
gcloud monitoring alert-policies delete POLICY_ID
```

### Notification Channels
```bash
# Email notification
gcloud monitoring notification-channels create \
  --display-name="Email Alerts" \
  --type=email \
  --notification-channel-labels=email_address=user@example.com

# Slack notification
gcloud monitoring notification-channels create \
  --display-name="Slack Alerts" \
  --type=slack \
  --notification-channel-labels=channel_name=alerts,webhook_url=https://hooks.slack.com/...

# List channels
gcloud monitoring notification-channels list
gcloud monitoring notification-channels describe CHANNEL_ID
```

## 📝 Cloud Logging

### Log Operations
```bash
# List log entries
gcloud logging logs list                         # Available logs
gcloud logging read "resource.type=gce_instance" --limit 10

# Filter logs
gcloud logging read "resource.type=gce_instance AND severity>=WARNING" --limit 50
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=my-service"

# Time-based filtering
gcloud logging read "timestamp>=\"2024-01-01T00:00:00Z\"" --limit 100
gcloud logging read "timestamp>=\"2024-01-01T00:00:00Z\" AND timestamp<=\"2024-01-02T00:00:00Z\""
```

### Log Sinks
```bash
# Create log sink
gcloud logging sinks create my-sink \
  storage.googleapis.com/projects/PROJECT_ID/buckets/my-logs \
  --log-filter="resource.type=gce_instance"

# BigQuery sink
gcloud logging sinks create bq-sink \
  bigquery.googleapis.com/projects/PROJECT_ID/datasets/my_logs \
  --log-filter="resource.type=cloud_run_revision"

# Pub/Sub sink
gcloud logging sinks create pubsub-sink \
  pubsub.googleapis.com/projects/PROJECT_ID/topics/my-logs \
  --log-filter="severity>=ERROR"

# Manage sinks
gcloud logging sinks list                       # List sinks
gcloud logging sinks describe my-sink           # Sink details
gcloud logging sinks update my-sink --log-filter="resource.type=gke_cluster"
gcloud logging sinks delete my-sink             # Delete sink
```

### Log Metrics
```bash
# Create log-based metric
gcloud logging metrics create my-metric \
  --description="Error count" \
  --log-filter="severity>=ERROR" \
  --metric-kind=DELTA \
  --value-type=INT64 \
  --unit=1

# List metrics
gcloud logging metrics list                     # All metrics
gcloud logging metrics describe my-metric       # Metric details

# Update metric
gcloud logging metrics update my-metric \
  --description="Updated error count"

# Delete metric
gcloud logging metrics delete my-metric
```

## 🔍 Error Reporting

### Error Operations
```bash
# List error groups
gcloud error-reporting groups list              # Error groups
gcloud error-reporting groups describe GROUP_ID # Group details

# Error events
gcloud error-reporting events list --group-id=GROUP_ID
gcloud error-reporting events describe EVENT_ID

# Error statistics
gcloud error-reporting stats list               # Error stats
gcloud error-reporting stats list --service=my-service
```

## 📈 Uptime Checks

### Uptime Monitoring
```bash
# Create uptime check
gcloud monitoring uptime-check-configs create my-check \
  --display-name="Website Uptime" \
  --resource-type=uptime-url \
  --resource-labels=host=my-website.com \
  --checker-type=STATIC_IP_CHECKERS \
  --selected-regions=us-central1,us-east1

# TCP uptime check
gcloud monitoring uptime-check-configs create tcp-check \
  --display-name="Database Uptime" \
  --resource-type=uptime-tcp \
  --resource-labels=host=my-db.com,port=5432

# List uptime checks
gcloud monitoring uptime-check-configs list
gcloud monitoring uptime-check-configs describe my-check

# Update uptime check
gcloud monitoring uptime-check-configs update my-check \
  --display-name="Updated Website Check"

# Delete uptime check
gcloud monitoring uptime-check-configs delete my-check
```

## 🔧 Service Monitoring

### Service Level Objectives (SLOs)
```bash
# Create SLO
gcloud monitoring slo create \
  --display-name="API Latency SLO" \
  --service-id=SERVICE_ID \
  --goal=0.95 \
  --rolling-period=7d \
  --latency-good-service-filter="metric.type=\"run.googleapis.com/request_latencies\" AND metric.label.\"status\"=\"OK\""

# List SLOs
gcloud monitoring slo list --service-id=SERVICE_ID
gcloud monitoring slo describe SLO_ID --service-id=SERVICE_ID

# Update SLO
gcloud monitoring slo update SLO_ID \
  --goal=0.99 \
  --service-id=SERVICE_ID

# Delete SLO
gcloud monitoring slo delete SLO_ID --service-id=SERVICE_ID
```

### Custom Metrics
```bash
# Create custom metric
gcloud monitoring metrics create my-custom-metric \
  --description="Custom application metric" \
  --metric-kind=GAUGE \
  --value-type=DOUBLE \
  --unit="1"

# Send custom metrics
curl -X POST \
  https://monitoring.googleapis.com/v3/projects/PROJECT_ID/timeSeries \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "timeSeries": [{
      "metric": {
        "type": "custom.googleapis.com/my-custom-metric",
        "labels": {"key": "value"}
      },
      "resource": {
        "type": "gce_instance",
        "labels": {"instance_id": "123456789", "zone": "us-central1-a"}
      },
      "points": [{
        "interval": {"endTime": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"},
        "value": {"doubleValue": 42.0}
      }]
    }]
  }'
```

## 📋 Resource Monitoring

### GCE Instance Monitoring
```bash
# Instance metrics
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/cpu/utilization' \
  --project PROJECT_ID \
  --start-time "2024-01-01T00:00:00Z" \
  --end-time "2024-01-02T00:00:00Z"

# Disk usage
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/disk/write_bytes_count' \
  --project PROJECT_ID

# Network traffic
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/network/received_bytes_count' \
  --project PROJECT_ID
```

### GKE Cluster Monitoring
```bash
# Cluster metrics
gcloud monitoring metrics query \
  'fetch k8s_cluster::kubernetes.io/namespace_name/pod_count' \
  --project PROJECT_ID

# Node metrics
gcloud monitoring metrics query \
  'fetch k8s_node::kubernetes.io/node_cpu/usage_time' \
  --project PROJECT_ID

# Pod metrics
gcloud monitoring metrics query \
  'fetch k8s_pod::kubernetes.io/pod_cpu/usage_time' \
  --project PROJECT_ID
```

### Cloud Run Monitoring
```bash
# Request count
gcloud monitoring metrics query \
  'fetch cloud_run_revision::run.googleapis.com/request_count' \
  --project PROJECT_ID

# Request latency
gcloud monitoring metrics query \
  'fetch cloud_run_revision::run.googleapis.com/request_latencies' \
  --project PROJECT_ID

# Instance count
gcloud monitoring metrics query \
  'fetch cloud_run_revision::run.googleapis.com/container/instance_count' \
  --project PROJECT_ID
```

## 🚨 Incident Management

### Incident Response
```bash
# List incidents
gcloud monitoring incidents list                 # Active incidents
gcloud monitoring incidents describe INCIDENT_ID # Incident details

# Acknowledge incident
gcloud monitoring incidents acknowledge INCIDENT_ID \
  --acknowledge-time="2024-01-01T12:00:00Z"

# Close incident
gcloud monitoring incidents close INCIDENT_ID
```

## 📊 Export & Integration

### Data Export
```bash
# Export metrics to BigQuery
gcloud monitoring metrics create my-export \
  --description="Metrics export" \
  --metric-kind=DELTA \
  --value-type=DOUBLE \
  --unit="1" \
  --bigquery-export

# Export logs to BigQuery
gcloud logging sinks create bq-logs \
  bigquery.googleapis.com/projects/PROJECT_ID/datasets/logs_dataset \
  --log-filter="resource.type=gce_instance"
```

### Third-party Integration
```bash
# Webhook integration
gcloud monitoring notification-channels create webhook-channel \
  --display-name="Webhook Alerts" \
  --type=webhook \
  --notification-channel-labels=url=https://my-webhook.com/alerts

# PagerDuty integration
gcloud monitoring notification-channels create pagerduty-channel \
  --display-name="PagerDuty Alerts" \
  --type=pagerduty \
  --notification-channel-labels=service_key=YOUR_PAGERDUTY_KEY
```

## 📈 Performance Analysis

### Query Optimization
```bash
# Time range queries
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/cpu/utilization | within 1h' \
  --project PROJECT_ID

# Aggregation queries
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/cpu/utilization | mean | group_by [resource.instance_id]' \
  --project PROJECT_ID

# Complex queries
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/cpu/utilization | filter resource.instance_id =~ "web-.*" | mean' \
  --project PROJECT_ID
```

### Cost Monitoring
```bash
# Billing metrics
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/billing/estimated_charges' \
  --project PROJECT_ID

# Resource usage costs
gcloud monitoring metrics query \
  'fetch gce_instance::compute.googleapis.com/instance/uptime' \
  --project PROJECT_ID
```

## 🚨 Troubleshooting

### Common Monitoring Issues
```bash
# Missing metrics
gcloud monitoring metrics list --filter="metric.type=compute.googleapis.com/instance/cpu/utilization"

# Permission issues
gcloud projects get-iam-policy PROJECT_ID --filter="bindings.role:roles/monitoring.viewer"

# Log ingestion delays
gcloud logging logs list                        # Check log availability
gcloud logging read "timestamp>=\"$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)\"" --limit 5
```

### Debug Commands
```bash
# API debugging
gcloud monitoring metrics list --verbosity=debug
gcloud logging read "resource.type=gce_instance" --verbosity=debug

# Configuration validation
gcloud monitoring alert-policies list --format="table(name,displayName,enabled)"
gcloud logging sinks list --format="table(name,destination,filter)"
```

---

**Pro Tips:**
- Use metric filters to focus on specific resources
- Set up alerts for critical metrics before issues occur
- Use log-based metrics for custom monitoring
- Export logs to BigQuery for advanced analysis
- Create SLOs to track service reliability
- Use uptime checks for external service monitoring
