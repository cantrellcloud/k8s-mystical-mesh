# Network IP Matrix - Multi-Cluster Kubernetes Environment

**Pre-Production Infrastructure**  
**Version:** 1.0  
**Date:** December 18, 2025

---

## Table of Contents

1. [Network Port Groups](#network-port-groups)
2. [Cluster IP Allocations](#cluster-ip-allocations)
3. [Service Endpoints](#service-endpoints)
4. [Node Inventory](#node-inventory)

---

## Network Port Groups

The infrastructure uses four distinct network segments for different purposes:

| Port Group | IP Space | Description |
|------------|----------|-------------|
| **hardware** | 10.231.3.131 - 10.231.3.254 | vSphere Supervisor Control Plane |
| **kubes-domain** | 10.0.4.0/24 | Kubernetes Admin, Cluster Nodes, and App Services |
| **netapp-1001** | 172.16.0.101 - 172.16.0.130 | Kubernetes Cluster Nodes for Persistent Volumes (iSCSI) |
| **segment1** | 1.0.0.128/25 | Kubernetes Cluster Nodes and App Services (Alternative Network) |

**Network Purposes:**

- **hardware:** vSphere infrastructure management
- **kubes-domain:** Primary Kubernetes management and service network
- **netapp-1001:** Dedicated storage network for iSCSI traffic
- **segment1:** Alternative network path for redundancy and segmentation

---

## Cluster IP Allocations

### Complete Cluster Matrix

| Cluster | Site | Node IP Range | Storage IP Range | Segment1 IP Range | Domain MetalLB Pool | Segment1 MetalLB Pool | Domain Ingress IP | Segment1 Ingress IP | Service CIDR | Pod Network CIDR |
|---------|------|---------------|------------------|-------------------|---------------------|----------------------|-------------------|---------------------|--------------|------------------|
| **j64manager** | J64 | 10.0.4.131-140 | 172.16.0.101-108 | 1.0.0.131-140 | 10.0.4.30-39 | 1.0.0.201-210 | 10.0.4.35 | 1.0.0.205 | 10.93.0.0/16 | 10.243.0.0/16 |
| **j64domain** | J64 | 10.0.4.141-150 | 172.16.0.109-115 | 1.0.0.141-150 | 10.0.4.40-49 | 1.0.0.211-220 | 10.0.4.45 | 1.0.0.215 | 10.94.0.0/16 | 10.244.0.0/16 |
| **j52domain** | J52 | 10.0.4.161-170 | 172.16.0.116-122 | 1.0.0.161-170 | 10.0.4.60-69 | 1.0.0.221-230 | 10.0.4.65 | 1.0.0.225 | 10.96.0.0/16 | 10.246.0.0/16 |
| **r01domain** | R01 | 10.0.4.181-190 | 172.16.0.123-129 | 1.0.0.181-190 | 10.0.4.80-89 | 1.0.0.231-240 | 10.0.4.85 | 1.0.0.235 | 10.98.0.0/16 | 10.248.0.0/16 |

### j64manager Cluster (Management Cluster)

**IP Allocations:**

- **Node IPs (kubes-domain):** 10.0.4.131 - 10.0.4.140
- **Storage IPs (netapp-1001):** 172.16.0.101 - 172.16.0.108
- **Segment1 IPs:** 1.0.0.131 - 1.0.0.140
- **Domain MetalLB Pool:** 10.0.4.30 - 10.0.4.39
- **Segment1 MetalLB Pool:** 1.0.0.201 - 1.0.0.210
- **Contour Ingress (Domain):** 10.0.4.35
- **Contour Ingress (Segment1):** 1.0.0.205
- **Cluster Service CIDR:** 10.93.0.0/16
- **Pod Network CIDR:** 10.243.0.0/16

**FQDN:** j64manager-cluster.dev.kube

**Purpose:** MongoDB Operator, Central Monitoring (Prometheus/Grafana), Istio Primary Control Plane

### j64domain Cluster (Application Cluster - Site J64)

**IP Allocations:**

- **Node IPs (kubes-domain):** 10.0.4.141 - 10.0.4.150
- **Storage IPs (netapp-1001):** 172.16.0.109 - 172.16.0.115
- **Segment1 IPs:** 1.0.0.141 - 1.0.0.150
- **Domain MetalLB Pool:** 10.0.4.40 - 10.0.4.49
- **Segment1 MetalLB Pool:** 1.0.0.211 - 1.0.0.220
- **Contour Ingress (Domain):** 10.0.4.45
- **Contour Ingress (Segment1):** 1.0.0.215
- **Cluster Service CIDR:** 10.94.0.0/16
- **Pod Network CIDR:** 10.244.0.0/16

**FQDN:** j64domain-cluster.dev.kube

**Purpose:** Rocket.Chat Application, MongoDB ReplicaSet Member, NATS Messaging

### j52domain Cluster (Application Cluster - Site J52)

**IP Allocations:**

- **Node IPs (kubes-domain):** 10.0.4.161 - 10.0.4.170
- **Storage IPs (netapp-1001):** 172.16.0.116 - 172.16.0.122
- **Segment1 IPs:** 1.0.0.161 - 1.0.0.170
- **Domain MetalLB Pool:** 10.0.4.60 - 10.0.4.69
- **Segment1 MetalLB Pool:** 1.0.0.221 - 1.0.0.230
- **Contour Ingress (Domain):** 10.0.4.65
- **Contour Ingress (Segment1):** 1.0.0.225
- **Cluster Service CIDR:** 10.96.0.0/16
- **Pod Network CIDR:** 10.246.0.0/16

**FQDN:** j52domain-cluster.dev.kube

**Purpose:** Rocket.Chat Application, MongoDB ReplicaSet Member, NATS Messaging

### r01domain Cluster (Application Cluster - Site R01)

**IP Allocations:**

- **Node IPs (kubes-domain):** 10.0.4.181 - 10.0.4.190
- **Storage IPs (netapp-1001):** 172.16.0.123 - 172.16.0.129
- **Segment1 IPs:** 1.0.0.181 - 1.0.0.190
- **Domain MetalLB Pool:** 10.0.4.80 - 10.0.4.89
- **Segment1 MetalLB Pool:** 1.0.0.231 - 1.0.0.240
- **Contour Ingress (Domain):** 10.0.4.85
- **Contour Ingress (Segment1):** 1.0.0.235
- **Cluster Service CIDR:** 10.98.0.0/16
- **Pod Network CIDR:** 10.248.0.0/16

**FQDN:** r01domain-cluster.dev.kube

**Purpose:** Rocket.Chat Application, MongoDB ReplicaSet Member, NATS Messaging

---

## Service Endpoints

### Application Services

| Service | FQDN | Domain Network IPs | Segment1 Network IPs | Protocol | Port |
|---------|------|-------------------|---------------------|----------|------|
| **Rocket.Chat** | rocket.dev.local | 10.0.4.45, 10.0.4.65, 10.0.4.85 | 1.0.0.215, 1.0.0.225, 1.0.0.235 | HTTP/HTTPS | 80/443 |

**Note:** Sites are simulated representations of possible deployment configurations in a production environment.

### Infrastructure Services

| Service | FQDN/Endpoint | IP Address | Protocol | Port | Purpose |
|---------|---------------|------------|----------|------|---------|
| **Container Registry** | altregistry.dev.kube | - | HTTPS | 8443 | Container image repository |
| **NetApp Storage (NFS)** | tridentsvm.dev.kube | - | NFS | 2049 | NFS storage provisioning |
| **NetApp Storage (iSCSI)** | tridentsvm.dev.kube | - | iSCSI | 3260 | Block storage provisioning |
| **NetApp Data LIF** | tridentsvm-data.dev.kube | - | NFS | 2049 | NFS data traffic |

### Service Mesh East-West Gateways

| Cluster | Network | Gateway Type | Port | Purpose |
|---------|---------|--------------|------|---------|
| j64manager | Domain MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |
| j64manager | Segment1 MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |
| j64domain | Domain MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |
| j64domain | Segment1 MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |
| j52domain | Domain MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |
| j52domain | Segment1 MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |
| r01domain | Domain MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |
| r01domain | Segment1 MetalLB Pool | LoadBalancer | 15443 | Cross-cluster service mesh traffic |

**Note:** East-west gateways are assigned IPs dynamically from MetalLB pools when deployed.

---

## Node Inventory

### j64manager Cluster (Site J64)

| Hostname | kubes-domain | netapp-1001 | segment1 | Role |
|----------|--------------|-------------|----------|------|
| **j64manager-cluster** | - | - | - | Cluster VIP |
| j64manager-ctrl01 | 10.0.4.131 | 172.16.0.101 | 1.0.0.131 | Control Plane |
| j64manager-ctrl02 | 10.0.4.132 | 172.16.0.102 | 1.0.0.132 | Control Plane |
| j64manager-ctrl03 | 10.0.4.133 | 172.16.0.103 | 1.0.0.133 | Control Plane |
| j64manager-spare | 10.0.4.134 | 172.16.0.104 | 1.0.0.134 | Spare Node |
| j64manager-work01 | 10.0.4.135 | 172.16.0.105 | 1.0.0.135 | Worker Node |
| j64manager-work02 | 10.0.4.136 | 172.16.0.106 | 1.0.0.136 | Worker Node |
| j64manager-work03 | 10.0.4.137 | 172.16.0.107 | 1.0.0.137 | Worker Node |
| j64manager-work04 | 10.0.4.138 | 172.16.0.108 | 1.0.0.138 | Worker Node |

**Total Capacity:** 3 control plane nodes, 4 worker nodes, 1 spare

### j64domain Cluster (Site J64)

| Hostname | kubes-domain | netapp-1001 | segment1 | Role |
|----------|--------------|-------------|----------|------|
| **j64domain-cluster** | - | - | - | Cluster VIP |
| j64domain-ctrl01 | 10.0.4.141 | 172.16.0.109 | 1.0.0.141 | Control Plane |
| j64domain-ctrl02 | 10.0.4.142 | 172.16.0.110 | 1.0.0.142 | Control Plane |
| j64domain-ctrl03 | 10.0.4.143 | 172.16.0.111 | 1.0.0.143 | Control Plane |
| j64domain-spare | 10.0.4.144 | 172.16.0.112 | 1.0.0.144 | Spare Node |
| j64domain-work01 | 10.0.4.145 | 172.16.0.113 | 1.0.0.145 | Worker Node |
| j64domain-work02 | 10.0.4.146 | 172.16.0.114 | 1.0.0.146 | Worker Node |
| j64domain-work03 | 10.0.4.147 | 172.16.0.115 | 1.0.0.147 | Worker Node |

**Total Capacity:** 3 control plane nodes, 3 worker nodes, 1 spare

### j52domain Cluster (Site J52)

| Hostname | kubes-domain | netapp-1001 | segment1 | Role |
|----------|--------------|-------------|----------|------|
| **j52domain-cluster** | - | - | - | Cluster VIP |
| j52domain-ctrl01 | 10.0.4.161 | 172.16.0.116 | 1.0.0.161 | Control Plane |
| j52domain-ctrl02 | 10.0.4.162 | 172.16.0.117 | 1.0.0.162 | Control Plane |
| j52domain-ctrl03 | 10.0.4.163 | 172.16.0.118 | 1.0.0.163 | Control Plane |
| j52domain-spare | 10.0.4.164 | 172.16.0.119 | 1.0.0.164 | Spare Node |
| j52domain-work01 | 10.0.4.165 | 172.16.0.120 | 1.0.0.165 | Worker Node |
| j52domain-work02 | 10.0.4.166 | 172.16.0.121 | 1.0.0.166 | Worker Node |
| j52domain-work03 | 10.0.4.167 | 172.16.0.122 | 1.0.0.167 | Worker Node |

**Total Capacity:** 3 control plane nodes, 3 worker nodes, 1 spare

### r01domain Cluster (Site R01)

| Hostname | kubes-domain | netapp-1001 | segment1 | Role |
|----------|--------------|-------------|----------|------|
| **r01domain-cluster** | - | - | - | Cluster VIP |
| r01domain-ctrl01 | 10.0.4.181 | 172.16.0.123 | 1.0.0.181 | Control Plane |
| r01domain-ctrl02 | 10.0.4.182 | 172.16.0.124 | 1.0.0.182 | Control Plane |
| r01domain-ctrl03 | 10.0.4.183 | 172.16.0.125 | 1.0.0.183 | Control Plane |
| r01domain-spare | 10.0.4.184 | 172.16.0.126 | 1.0.0.184 | Spare Node |
| r01domain-work01 | 10.0.4.185 | 172.16.0.127 | 1.0.0.185 | Worker Node |
| r01domain-work02 | 10.0.4.186 | 172.16.0.128 | 1.0.0.186 | Worker Node |
| r01domain-work03 | 10.0.4.187 | 172.16.0.129 | 1.0.0.187 | Worker Node |

**Total Capacity:** 3 control plane nodes, 3 worker nodes, 1 spare

---

## Network Architecture Diagrams

### Three-Network Design

Each cluster node has three network interfaces:

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Node                       │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ kubes-domain │  │ netapp-1001  │  │   segment1   │  │
│  │  (Primary)   │  │  (Storage)   │  │ (Secondary)  │  │
│  │              │  │              │  │              │  │
│  │ 10.0.4.x/24  │  │ 172.16.0.x   │  │ 1.0.0.x/25   │  │
│  │              │  │              │  │              │  │
│  │ Management   │  │ iSCSI Only   │  │ App Traffic  │  │
│  │ App Services │  │ Block Storage│  │ Alternative  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Traffic Segmentation

**kubes-domain (10.0.4.0/24):**

- Kubernetes API server communication
- kubectl/helm management traffic
- LoadBalancer services (MetalLB)
- Ingress traffic (Contour)
- Service mesh control plane (Istio)

**netapp-1001 (172.16.0.101-130):**

- Dedicated iSCSI storage network
- Persistent volume traffic only
- Isolated from application traffic
- Direct connection to NetApp SVM

**segment1 (1.0.0.128/25):**

- Alternative network path for services
- Redundant LoadBalancer services
- Additional ingress endpoints
- Network segmentation and isolation

### MetalLB IP Pool Strategy

Each cluster has two MetalLB pools for redundancy:

- **Domain Pool:** Allocates IPs from kubes-domain network (10.0.4.x)
- **Segment1 Pool:** Allocates IPs from segment1 network (1.0.0.x)

Services can request IPs from either pool using address pool annotations.

---

## Reference Links

- **Main Documentation:** [README.md](../README.md)
- **System Design:** [System-Design-Document.md](System-Design-Document.md)
- **Monitoring Guide:** [Monitoring-Enhancements.md](Monitoring-Enhancements.md)
- **Security Guide:** [Security-Hardening-Guide.md](Security-Hardening-Guide.md)
- **Operations Guide:** [Operations-Quick-Reference.md](Operations-Quick-Reference.md)

---

**Document maintained by:** Infrastructure Team  
**Last reviewed:** December 18, 2025  
**Next review:** Quarterly or upon infrastructure changes
