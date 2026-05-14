# GCP Virtual Private Cloud (VPC) and Networking

## Overview
VPC allows you to create isolated networks in GCP with complete control over IP addressing, routing, and connectivity. Every resource needs to be attached to a VPC.

---

## VPC Fundamentals

### What is a VPC?
- Custom, isolated network environment in GCP
- Project-scoped (each project gets default VPC)
- Region-independent (can span multiple zones globally)
- Can have multiple subnets in different regions

**Key Points:**
- Resources in same VPC can communicate (unless firewall restricts)
- VPCs are isolated from each other by default
- Can create multiple VPCs for different applications/teams

### Default vs. Custom VPC

| Aspect | Default VPC | Custom VPC |
|--------|-------------|-----------|
| Created | Automatically per project | Manual creation |
| Subnets | Auto-created per region | Manual creation |
| Firewall | Allow all internal traffic | More restrictive |
| CIDR | 10.0.0.0/8 | Your choice |
| Recommendation | Dev/Testing only | Production |

---

## VPC Architecture

```
Project
  └── VPC Network: custom-vpc (CIDR: 10.0.0.0/16)
      ├── Subnet: us-central1 (CIDR: 10.0.1.0/24)
      │   └── GCE instances, GKE nodes
      ├── Subnet: europe-west1 (CIDR: 10.0.2.0/24)
      │   └── GCE instances, GKE nodes
      └── Subnet: asia-southeast1 (CIDR: 10.0.3.0/24)
          └── GCE instances, GKE nodes
      
      Firewall Rules
      ├── Allow HTTP (0.0.0.0/0 → :80)
      ├── Allow SSH (0.0.0.0/0 → :22)
      └── Allow internal traffic (10.0.0.0/16 → :0-65535)
```

---

## Subnets

**What is a Subnet?**
- Regional subdivision of a VPC
- One IPv4 CIDR range per subnet
- Cannot overlap with other subnets in same VPC
- Automatically created in secondary ranges (CIDR alias)

### Creating Subnets

```bash
# Create VPC
gcloud compute networks create custom-vpc \
  --subnet-mode=custom \
  --bgp-routing-mode=regional

# Create subnet
gcloud compute networks subnets create us-central1-subnet \
  --network=custom-vpc \
  --region=us-central1 \
  --range=10.0.1.0/24

# Create subnet with secondary range (for GKE pods)
gcloud compute networks subnets create gke-subnet \
  --network=custom-vpc \
  --region=us-central1 \
  --range=10.0.2.0/24 \
  --secondary-range pods=10.4.0.0/14,services=10.0.16.0/20
```

**Secondary Range Use Cases:**
- GKE pod CIDR
- GKE service CIDR
- Custom application ranges

### Listing Subnets

```bash
# List all subnets
gcloud compute networks subnets list

# List subnets in specific network
gcloud compute networks subnets list --network=custom-vpc

# Get subnet details
gcloud compute networks subnets describe us-central1-subnet \
  --region=us-central1
```

---

## Firewall Rules

**Firewall Control:** Stateful firewall that controls ingress and egress traffic.

### Firewall Rule Structure

```
Source → Firewall Rule → Destination
Protocol, Port, IP Range
```

### Creating Firewall Rules

```bash
# Allow HTTP from anywhere
gcloud compute firewall-rules create allow-http \
  --network=custom-vpc \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=web-server

# Allow SSH from specific IP
gcloud compute firewall-rules create allow-ssh \
  --network=custom-vpc \
  --allow=tcp:22 \
  --source-ranges=203.0.113.0/24 \
  --target-tags=managed

# Allow internal traffic
gcloud compute firewall-rules create allow-internal \
  --network=custom-vpc \
  --allow=tcp:0-65535,udp:0-65535,icmp \
  --source-ranges=10.0.0.0/8 \
  --target-tags=backend

# Deny all egress (advanced)
gcloud compute firewall-rules create deny-all-egress \
  --network=custom-vpc \
  --direction=EGRESS \
  --priority=65534 \
  --deny=all
```

**Common Firewall Actions:**
- `--allow` - Permit matching traffic
- `--deny` - Block matching traffic
- `--priority` - Lower number = higher priority (0-65534)
- `--direction` - INGRESS or EGRESS
- `--target-tags` - Tags on target instances (default: all)
- `--source-ranges` - Source IP CIDR blocks
- `--source-tags` - Source resource tags

### Listing Firewall Rules

```bash
# List all firewall rules
gcloud compute firewall-rules list --network=custom-vpc

# Describe firewall rule
gcloud compute firewall-rules describe allow-http

# Watch firewall logs (requires logging enabled)
gcloud compute firewall-rules describe allow-http --format=json
```

---

## Routes

**Route:** Specifies how packets leaving instances are directed.

### Default Routes

```bash
# Routes automatically created:
# 1. Default route to internet (0.0.0.0/0 via default-internet-gateway)
# 2. Subnet route (10.0.1.0/24 for local traffic)
```

### Custom Routes

```bash
# Create static route
gcloud compute routes create route-to-on-prem \
  --network=custom-vpc \
  --destination-range=192.168.0.0/16 \
  --next-hop-gateway=default-internet-gateway

# Create route via VPN tunnel
gcloud compute routes create vpn-route \
  --network=custom-vpc \
  --destination-range=172.16.0.0/12 \
  --next-hop-vpn-tunnel=on-prem-tunnel \
  --next-hop-vpn-tunnel-region=us-central1

# List routes
gcloud compute routes list --filter="network:custom-vpc"
```

---

## IP Addressing

### External IP Addresses

**Static External IP:** Persists even if instance is stopped
```bash
# Reserve static external IP
gcloud compute addresses create web-server-ip \
  --region=us-central1

# Assign to instance
gcloud compute instances create web-server \
  --address=web-server-ip \
  --region=us-central1

# Get static IP details
gcloud compute addresses describe web-server-ip --region=us-central1
```

**Ephemeral External IP:** Lost when instance is stopped
```bash
# Auto-assigned during instance creation
gcloud compute instances create instance-name \
  --network-interface=network-tier=PREMIUM
```

### Internal IP Addresses

- Automatically assigned from subnet CIDR range
- Allow communication within VPC
- Cannot be assigned externally
- Persist for instance lifetime

```bash
# View internal IP
gcloud compute instances describe INSTANCE_ID --zone=ZONE \
  --format='value(networkInterfaces[0].networkIP)'
```

---

## Cloud NAT

**NAT:** Network Address Translation - allows instances without external IPs to access the internet.

### Use Cases
- Private instances accessing external APIs
- Instances downloading packages (npm, pip, apt)
- Bastion/jump host pattern

### Configuring Cloud NAT

```bash
# Create Cloud Router (required for NAT)
gcloud compute routers create my-router \
  --network=custom-vpc \
  --region=us-central1

# Add NAT configuration
gcloud compute routers nats create nat-config \
  --router=my-router \
  --region=us-central1 \
  --nat-all-subnet-ip-ranges \
  --auto-allocate-nat-external-ips
```

**NAT Options:**
```bash
# NAT only specific subnets
gcloud compute routers nats create nat-config \
  --router=my-router \
  --region=us-central1 \
  --source-subnet-ip-ranges LIST_OF_SUBNETS

# Log NAT activities
gcloud compute routers nats create nat-config \
  --router=my-router \
  --region=us-central1 \
  --nat-all-subnet-ip-ranges \
  --enable-logging
```

### Architecture
```
Private Instance (10.0.1.5)
  ↓ (no external IP)
  ↓ outbound traffic
Cloud NAT (in Cloud Router)
  ↓ (translates source IP to external IP)
  ↓
Internet
```

---

## VPC Peering

**VPC Peering:** Direct connection between two VPCs (can be in different projects/organizations).

### Creating VPC Peering

```bash
# Create VPC peering connection
gcloud compute networks peerings create vpc1-to-vpc2 \
  --network=vpc-1 \
  --auto-create-routes \
  --peer-project=PROJECT_ID_2 \
  --peer-network=vpc-2

# Accept peering from other side
gcloud compute networks peerings update vpc1-to-vpc2 \
  --network=vpc-1 \
  --auto-create-routes
```

**Benefits:**
- Low-latency, private communication
- No per-GB charge (unless cross-region)
- Transitive peering not allowed

**Limitations:**
- Does NOT provide transitive routing
- Separate firewall rules needed
- Max 25-50 peering connections (per VPC)

### Architecture
```
VPC-1 (10.0.0.0/16) ←→ [Peering] ←→ VPC-2 (172.16.0.0/16)
  └─ Instance (10.0.1.5)          └─ Instance (172.16.1.5)
    Direct communication
```

---

## Cloud VPN

**VPN:** Encrypted tunnel for connecting on-premises networks to GCP.

### Creating VPN Connection

```bash
# 1. Create VPN gateway
gcloud compute vpn-gateways create on-prem-gateway \
  --network=custom-vpc \
  --region=us-central1

# 2. Create peer VPN gateway (for on-prem)
gcloud compute external-vpn-gateways create on-prem \
  --interfaces 0=IP_ADDRESS

# 3. Create VPN tunnel
gcloud compute vpn-tunnels create on-prem-tunnel \
  --vpn-gateway=on-prem-gateway \
  --external-vpn-gateway=on-prem \
  --region=us-central1 \
  --ike-version=2 \
  --shared-secret=YOUR_SECRET

# 4. Create route
gcloud compute routes create to-on-prem \
  --network=custom-vpc \
  --destination-range=192.168.0.0/16 \
  --next-hop-vpn-tunnel=on-prem-tunnel \
  --next-hop-vpn-tunnel-region=us-central1
```

---

## Hybrid Connectivity Comparison

| Feature | VPC Peering | Cloud VPN | Cloud Interconnect |
|---------|-------------|-----------|-------------------|
| Connectivity | GCP to GCP | On-prem to GCP | On-prem to GCP |
| Encryption | No | Yes (IPsec) | Optional |
| Bandwidth | Up to GCP limit | 1.5 Gbps | 10/100 Gbps |
| Use Case | Multi-VPC mesh | On-prem access | High throughput |
| Cost | Low (cross-region higher) | Per GB | High initial, low ongoing |

---

## Best Practices

### 1. **Use Custom VPC for Production**
```bash
# ✅ Production setup
gcloud compute networks create prod-vpc \
  --subnet-mode=custom \
  --bgp-routing-mode=regional
```

### 2. **Plan CIDR Ranges Carefully**
```
VPC: 10.0.0.0/16 (65,536 IPs)
  ├─ Subnet-1: 10.0.1.0/24 (256 IPs)
  ├─ Subnet-2: 10.0.2.0/24 (256 IPs)
  ├─ GKE Pods: 10.4.0.0/14 (262,144 IPs)
  └─ Reserved: 10.0.16.0/20 (4,096 IPs)

Avoid 191.168.0.0/16 which overlaps with on-prem!
```

### 3. **Firewall Rules - Principle of Least Privilege**
```bash
# ✅ GOOD: Specific rules
gcloud compute firewall-rules create allow-http-web \
  --network=prod-vpc \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=web-tier

# ❌ AVOID: Too permissive
gcloud compute firewall-rules create allow-all \
  --network=prod-vpc \
  --allow=all \
  --source-ranges=0.0.0.0/0
```

### 4. **Use Tags for Firewall Organization**
```bash
# Tag-based firewall rules
gcloud compute firewall-rules create allow-db-from-app \
  --network=prod-vpc \
  --allow=tcp:5432 \
  --source-tags=app-server \
  --target-tags=db-server
```

### 5. **Enable VPC Flow Logs**
```bash
# Monitor traffic in subnets
gcloud compute networks subnets create monitored-subnet \
  --network=custom-vpc \
  --region=us-central1 \
  --range=10.0.1.0/24 \
  --enable-flow-logs
```

### 6. **Document Your Network Topology**
```
Network Documentation:
- VPC Name, CIDR range, billing project
- Subnets: name, region, CIDR, secondary ranges
- Firewall rules: purpose, source/destination
- Routes: destination, next hop
- External IPs: associated resource
- NAT: which subnets, external IPs
```

---

## Common VPC Patterns

### Pattern 1: Multi-tier Application
```
VPC: 10.0.0.0/16
├─ Web-tier subnet: 10.0.1.0/24 (external IPs, Load Balancer)
├─ App-tier subnet: 10.0.2.0/24 (no external IPs, Cloud NAT)
├─ DB-tier subnet: 10.0.3.0/24 (no external IPs, no internet)
└─ Firewall rules enforce communication between tiers
```

### Pattern 2: GKE Cluster Networking
```
VPC: 10.0.0.0/16
└─ Subnet: 10.0.1.0/24 (node CIDR)
   ├─ Secondary range: 10.4.0.0/14 (pod CIDR)
   └─ Secondary range: 10.0.16.0/20 (service CIDR)
```

### Pattern 3: Multi-Region Setup
```
VPCs connected via VPC Peering
├─ Region 1: VPC 10.0.0.0/16
└─ Region 2: VPC 10.1.0.0/16
   L (peering without transitive routing)
```

---

## Troubleshooting Commands

```bash
# Test connectivity between instances
gcloud compute ssh instance-1 --zone=ZONE -- \
  ping instance-2.c.PROJECT_ID.internal

# Check firewall logs
gcloud logging read "resource.type=gce_firewall_rule" \
  --limit=10 --format=json

# Diagnostic: List all routes to destination
gcloud compute routes list \
  --filter="destination_range:192.168.0.0/16"

# Test VPC peering connectivity
gcloud compute networks peerings list --network=vpc-1

# Check VPC flow logs
gcloud logging read "resource.type=gce_network_interface" \
  --limit=10
```

---

## Interview Tips

✅ **Know:**
- VPC structure (regions, subnets, CIDR ranges)
- Firewall rules and stateful nature
- External vs. Internal IP distinction
- Cloud NAT use cases and setup
- VPC peering vs. Cloud VPN
- Tag-based firewall organization

❌ **Avoid:**
- Using default VPC for production
- Overlapping CIDR ranges
- Too permissive firewall rules
- Confusing routes with peering
- Not planning CIDR ranges ahead

