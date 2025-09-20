# CodeMind Infrastructure

Kubernetes infrastructure for CodeMind - the world's first cognitive software factory. This repository contains all the necessary manifests and deployment scripts to run CodeMind on your Kubernetes cluster.

## 🏗️ Architecture Overview

CodeMind infrastructure consists of:

### 🗄️ Data Layer
- **PostgreSQL**: Primary database for application data
- **Redis**: Caching and session management
- **Qdrant**: Vector database for semantic search
- **MinIO**: Object storage for files and artifacts

### 📨 Messaging & Orchestration
- **NATS**: High-performance messaging system
- **Temporal**: Workflow orchestration engine

### 🚀 Deployment Strategy
- **NodePort Services**: Stable access without port-forwarding
- **Non-persistent Storage**: Fast development iteration (configurable for production)
- **UK Optimized**: Ready for London/UK South deployments

## 🛠️ Quick Start

### Prerequisites
- Kubernetes cluster (tested on 5-node cluster)
- kubectl configured and connected
- Helm 3.x installed

### Deployment

1. **Clone the repository**
   ```bash
   git clone https://github.com/QuantumLayerPlatform-dev-ai/codemind-infrastructure.git
   cd codemind-infrastructure
   ```

2. **Deploy the infrastructure**
   ```bash
   chmod +x scripts/deploy-infrastructure.sh
   ./scripts/deploy-infrastructure.sh
   ```

3. **Verify deployment**
   ```bash
   kubectl get pods -n codemind
   kubectl get svc -n codemind
   ```

The script will deploy all services and show you the NodePort access details.

## 📊 Service Access

After deployment, services are available via NodePort:

| Service | NodePort | Purpose |
|---------|----------|---------|
| PostgreSQL | 30432 | Primary database |
| Redis | 30379 | Cache and sessions |
| Qdrant | 30333 | Vector database |
| NATS | 30422 | Messaging |
| Temporal Frontend | 30233 | Workflow UI |
| MinIO | 30900 | Object storage |
| MinIO Console | 30909 | Storage management UI |

Access format: `http://your-k8s-node-ip:nodeport`

## 🔧 Configuration

### Environment Variables

Key configurations for your applications:

```bash
# Database connections
DATABASE_URL=postgresql+asyncpg://postgres:codemind-dev-password@k8s-node-ip:30432/codemind
REDIS_URL=redis://:codemind-dev-password@k8s-node-ip:30379
QDRANT_URL=http://k8s-node-ip:30333

# Messaging
NATS_URL=nats://k8s-node-ip:30422

# Temporal
TEMPORAL_HOST=k8s-node-ip
TEMPORAL_PORT=30233
TEMPORAL_NAMESPACE=default

# MinIO (if needed)
MINIO_ENDPOINT=k8s-node-ip:30900
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=codemind-dev-password
```

### Default Credentials

**Development credentials** (change for production):
- PostgreSQL: `postgres / codemind-dev-password`
- Redis: `codemind-dev-password`
- MinIO: `minioadmin / codemind-dev-password`

## 📁 Repository Structure

```
infrastructure/
├── k8s/                    # Kubernetes manifests
│   ├── nodeport-services.yaml   # NodePort service definitions
│   └── qdrant-simple.yaml      # Custom Qdrant deployment
├── scripts/                # Deployment scripts
│   └── deploy-infrastructure.sh # Main deployment script
└── README.md              # This file
```

## 🚀 Production Considerations

### Storage
Current setup uses **non-persistent storage** for rapid development. For production:

1. **Configure Persistent Volumes**:
   ```bash
   # Enable persistence in Helm values
   --set persistence.enabled=true
   --set persistence.size=50Gi
   ```

2. **Use Storage Classes**:
   ```yaml
   storageClass: "your-storage-class"
   ```

### Security
1. **Change default passwords**
2. **Enable TLS/SSL**
3. **Configure network policies**
4. **Set up RBAC**

### Monitoring
1. **Add Prometheus monitoring**
2. **Configure log aggregation**
3. **Set up alerting**

## 🔍 Troubleshooting

### Common Issues

**1. Pods stuck in Pending**
```bash
kubectl describe pod <pod-name> -n codemind
# Check for PV/storage issues
```

**2. Temporal pods CrashLooping**
```bash
# Temporal requires Cassandra to be ready first
kubectl logs temporal-schema-1-xxxxx -n codemind
```

**3. Service not accessible**
```bash
# Check NodePort services
kubectl get svc -n codemind | grep NodePort
```

### Useful Commands

```bash
# Check all pods status
kubectl get pods -n codemind -w

# View logs
kubectl logs -f <pod-name> -n codemind

# Port forward (alternative to NodePort)
kubectl port-forward svc/postgresql 5432:5432 -n codemind

# Delete and redeploy
kubectl delete namespace codemind
./scripts/deploy-infrastructure.sh
```

## 📈 Current Status

- ✅ **PostgreSQL**: Running stable on NodePort 30432
- ✅ **Redis**: Cache layer ready on NodePort 30379
- ✅ **Qdrant**: Vector DB operational on NodePort 30333
- ✅ **NATS**: Messaging ready on NodePort 30422
- ✅ **MinIO**: Object storage on NodePort 30900
- ⚠️ **Temporal**: Some pods in CrashLoopBackOff (advanced features)

**Core functionality working perfectly for CodeMind operations!**

## 🤝 Contributing

This is part of the CodeMind cognitive software factory. See the main repository for contribution guidelines.

## 📄 License

Commercial license - see LICENSE for details.

---

**🇬🇧 Enterprise-ready infrastructure, UK optimized! 🚀**

Part of the [CodeMind](https://github.com/QuantumLayerPlatform-dev-ai/codemind) ecosystem.