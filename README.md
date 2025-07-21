# Production Minecraft Server on Azure Kubernetes Service

A production-ready Minecraft server deployment on Azure Kubernetes Service (AKS) with persistent storage and Infrastructure as Code.

## 🏗️ Architecture Overview

This project demonstrates a complete cloud-native application deployment featuring:
- **Azure Kubernetes Service (AKS)** for container orchestration
- **Azure File Share** for persistent world data storage
- **Bicep Infrastructure as Code** for reproducible deployments
- **Helm Charts** for Kubernetes application management
- **LoadBalancer Service** for public internet access

## 🚀 Features

- **Persistent World Data**: Minecraft worlds survive pod restarts and cluster updates
- **Static Public IP**: Consistent IP address that never changes (no more updating server lists!)
- **Auto-scaling Infrastructure**: AKS cluster with configurable node counts
- **Environment-specific Deployments**: Parameter files for different environments
- **Secure Storage**: Managed identity integration for Azure File Share access
- **Public Access**: LoadBalancer service with static external IP for reliable connections
- **Resource Efficiency**: Server auto-pauses when no players are connected

## 📋 Components

### Infrastructure (Bicep)
- **AKS Cluster**: Kubernetes cluster with system node pool
- **Static Public IP**: Reserved IP address in AKS managed resource group
- **Storage Account**: Azure Storage with File Share for persistent data
- **Managed Identity**: Service identity for secure resource access
- **Resource Group Management**: Proper MC_ resource group handling

### Application (Helm)
- **Deployment**: Minecraft server container with resource limits
- **Service**: LoadBalancer for external connectivity
- **PersistentVolume**: Static volume pointing to Azure File Share
- **PersistentVolumeClaim**: Storage request for the application

## 🛠️ Project Structure

```
Minecraft Web Server K8s/
├── main_sever.bicep                 # Main infrastructure template
├── params/
│   └── starting_server.bicepparam   # Environment parameters
├── modules/
│   ├── aks.bicep                    # AKS cluster module
│   ├── storage.bicep                # Storage account module
│   └── mi.bicep                     # Managed identity module
└── minecraft-01/                    # Helm chart
    ├── Chart.yaml
    ├── values.yaml                  # Application configuration
    └── templates/
        ├── deployment.yaml          # Minecraft server deployment
        ├── service.yaml             # LoadBalancer service
        ├── persistentvolume.yaml    # Static PV for Azure File Share
        └── persistentvolumeclaim.yaml # Storage claim
```

## 🚦 Deployment Guide

### Prerequisites
- Azure CLI installed and authenticated
- kubectl configured
- Helm 3.x installed

### 1. Deploy Infrastructure
```bash
az deployment sub create \
  --parameters ".\params\starting_server.bicepparam" \
  -l "westeurope" \
  --subscription "YOUR_SUBSCRIPTION_ID" \
  --name "minecraft-deployment"
```

### 2. Connect to AKS Cluster
```bash
az aks get-credentials \
  --resource-group rg-minecraft-server-staging \
  --name aks-minecraft-staging
```

### 3. Create Storage Secret
```bash
# Get storage account key
az storage account keys list \
  --account-name "minecraftworlddata2024xyz21312" \
  --resource-group "rg-minecraft-server-staging" \
  --query '[0].value' --output tsv

# Create Kubernetes secret
kubectl create secret generic azure-file-secret \
  --from-literal=azurestorageaccountname=minecraftworlddata2024xyz21312 \
  --from-literal=azurestorageaccountkey=YOUR_STORAGE_KEY
```

### 4. Deploy Minecraft Server
```bash
helm install minecraft-01 ./minecraft-01 --namespace default
```

### 5. Get External IP
```bash
kubectl get service minecraft-minecraft-01 -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## 🎮 Connecting to the Server

Your server has a **static IP address** that never changes!

1. Open Minecraft Java Edition
2. Add server with IP: `128.251.156.59:25565` (or your deployed static IP)
3. Connect and enjoy!

**Note**: The IP address is consistent across deployments and service restarts.

## 🐛 Troubleshooting

### Common Issues

**Pod not starting:**
```bash
kubectl describe pod -l app.kubernetes.io/name=minecraft-01
kubectl logs -l app.kubernetes.io/name=minecraft-01
```

**Service has no endpoints:**
```bash
kubectl get endpoints minecraft-minecraft-01
kubectl describe service minecraft-minecraft-01
```

**External IP not accessible:**
```bash
# Test internal connectivity
kubectl exec -it deployment/minecraft-minecraft-01 -- netstat -tlnp | grep 25565

# Check service configuration
kubectl get service minecraft-minecraft-01 -o yaml
```

## 🔍 Key Learnings

### Kubernetes Storage
- **Dynamic vs Static Provisioning**: Used static PV to control exact file share location
- **Storage Classes**: Learned difference between built-in `azurefile` and custom storage classes
- **PV/PVC Relationship**: Understanding the binding process and troubleshooting mismatches

### Service Networking
- **LoadBalancer vs Ingress**: Minecraft requires TCP LoadBalancer, not HTTP Ingress
- **Port Configuration**: Critical importance of matching named ports between deployment and service
- **External IP Management**: How Azure assigns and manages public IPs for LoadBalancer services

### Azure Integration
- **AKS Managed Resources**: Understanding and working with the `MC_` resource group for AKS-managed infrastructure
- **Static IP Management**: Creating Public IPs in the correct resource group for LoadBalancer services
- **Resource Group Dependencies**: Proper sequencing of resource creation and referencing
- **File Share Authentication**: Using storage account keys vs managed identity (future improvement)
- **Network Security Groups**: Automatic rule creation for LoadBalancer services

## 🔮 Future Improvements

1. **Workload Identity**: Replace storage account keys with managed identity authentication
2. **Monitoring**: Add Prometheus/Grafana for server metrics and alerting
3. **Backup Automation**: Scheduled backups of world data to blob storage
4. **Ingress Controller**: Add web-based administration interface
5. **Network Policies**: Implement pod-to-pod security restrictions
6. **Resource Quotas**: Set proper CPU/memory limits and requests
7. **Multi-environment**: Expand parameter files for dev/staging/production
8. **Custom Domain**: Map a DNS name to the static IP address

## 📊 Architecture Benefits

- **Scalability**: Can easily scale AKS nodes up/down based on demand
- **Reliability**: Pod restarts don't affect world data persistence
- **Maintainability**: Infrastructure as Code enables version control and reproducible deployments
- **Security**: Network isolation and managed identities for secure access
- **Cost Optimization**: Server auto-pauses when empty, reducing compute costs

## 🎯 Skills Demonstrated

- **Infrastructure as Code**: Bicep template development and deployment
- **Container Orchestration**: Kubernetes deployment, service, and storage management
- **Cloud Architecture**: Azure service integration and networking
- **Application Packaging**: Helm chart development and templating
- **System Debugging**: Troubleshooting networking, storage, and service issues
- **DevOps Practices**: Parameterized deployments and environment management

---

*This project showcases production-ready cloud-native application deployment using modern DevOps practices and Azure cloud services.*