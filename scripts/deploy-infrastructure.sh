#!/bin/bash

# CodeMind Infrastructure Deployment Script
# This script deploys all required infrastructure components to your K8s cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="codemind"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🚀 CodeMind Infrastructure Deployment${NC}"
echo "========================================"

# Check prerequisites
echo -e "\n${YELLOW}📋 Checking prerequisites...${NC}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ helm is not installed${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Create namespace
echo -e "\n${YELLOW}📦 Creating namespace...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repositories
echo -e "\n${YELLOW}📚 Adding Helm repositories...${NC}"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add temporalio https://go.temporal.io/helm-charts
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo add qdrant https://qdrant.github.io/qdrant-helm/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo -e "${GREEN}✅ Helm repositories added${NC}"

# Deploy PostgreSQL
echo -e "\n${YELLOW}🐘 Deploying PostgreSQL...${NC}"
helm upgrade --install postgresql bitnami/postgresql \
  --namespace $NAMESPACE \
  --set auth.postgresPassword=codemind-dev-password \
  --set auth.database=codemind \
  --set primary.persistence.size=10Gi \
  --set metrics.enabled=true \
  --wait

echo -e "${GREEN}✅ PostgreSQL deployed${NC}"

# Deploy Redis
echo -e "\n${YELLOW}🔴 Deploying Redis...${NC}"
helm upgrade --install redis bitnami/redis \
  --namespace $NAMESPACE \
  --set auth.password=codemind-dev-password \
  --set master.persistence.size=5Gi \
  --set metrics.enabled=true \
  --wait

echo -e "${GREEN}✅ Redis deployed${NC}"

# Deploy Qdrant
echo -e "\n${YELLOW}🔍 Deploying Qdrant...${NC}"
helm upgrade --install qdrant qdrant/qdrant \
  --namespace $NAMESPACE \
  --set persistence.size=10Gi \
  --set config.cluster.enabled=false \
  --wait

echo -e "${GREEN}✅ Qdrant deployed${NC}"

# Deploy NATS
echo -e "\n${YELLOW}📨 Deploying NATS...${NC}"
helm upgrade --install nats nats/nats \
  --namespace $NAMESPACE \
  --set config.jetstream.enabled=true \
  --set config.jetstream.fileStore.pvc.size=5Gi \
  --wait

echo -e "${GREEN}✅ NATS deployed${NC}"

# Deploy Temporal
echo -e "\n${YELLOW}⏰ Deploying Temporal...${NC}"
helm upgrade --install temporal temporalio/temporal \
  --namespace $NAMESPACE \
  --set server.replicaCount=1 \
  --set cassandra.config.cluster_size=1 \
  --set prometheus.enabled=false \
  --set grafana.enabled=false \
  --set elasticsearch.enabled=false \
  --wait

echo -e "${GREEN}✅ Temporal deployed${NC}"

# Deploy Monitoring Stack
echo -e "\n${YELLOW}📊 Deploying monitoring stack...${NC}"

# Prometheus
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --set prometheus.prometheusSpec.retention=7d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
  --set grafana.adminPassword=codemind-dev-password \
  --wait

echo -e "${GREEN}✅ Monitoring stack deployed${NC}"

# Deploy MinIO for object storage
echo -e "\n${YELLOW}💾 Deploying MinIO...${NC}"
helm upgrade --install minio bitnami/minio \
  --namespace $NAMESPACE \
  --set auth.rootUser=minioadmin \
  --set auth.rootPassword=codemind-dev-password \
  --set persistence.size=10Gi \
  --wait

echo -e "${GREEN}✅ MinIO deployed${NC}"

# Wait for all pods to be ready
echo -e "\n${YELLOW}⏳ Waiting for all pods to be ready...${NC}"
kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=600s

# Display connection information
echo -e "\n${GREEN}🎉 Infrastructure deployment completed!${NC}"
echo "=========================================="
echo -e "\n${BLUE}📋 Connection Information:${NC}"
echo "Namespace: $NAMESPACE"
echo ""
echo "PostgreSQL:"
echo "  Host: postgresql.$NAMESPACE.svc.cluster.local"
echo "  Port: 5432"
echo "  Database: codemind"
echo "  Username: postgres"
echo "  Password: codemind-dev-password"
echo ""
echo "Redis:"
echo "  Host: redis-master.$NAMESPACE.svc.cluster.local"
echo "  Port: 6379"
echo "  Password: codemind-dev-password"
echo ""
echo "Qdrant:"
echo "  Host: qdrant.$NAMESPACE.svc.cluster.local"
echo "  Port: 6333"
echo ""
echo "NATS:"
echo "  Host: nats.$NAMESPACE.svc.cluster.local"
echo "  Port: 4222"
echo ""
echo "Temporal:"
echo "  Host: temporal-frontend.$NAMESPACE.svc.cluster.local"
echo "  Port: 7233"
echo ""
echo "MinIO:"
echo "  Host: minio.$NAMESPACE.svc.cluster.local"
echo "  Port: 9000"
echo "  Access Key: minioadmin"
echo "  Secret Key: codemind-dev-password"
echo ""

# Port forwarding commands
echo -e "${BLUE}🔌 Port Forwarding Commands:${NC}"
echo "kubectl port-forward -n $NAMESPACE svc/postgresql 5432:5432"
echo "kubectl port-forward -n $NAMESPACE svc/redis-master 6379:6379"
echo "kubectl port-forward -n $NAMESPACE svc/qdrant 6333:6333"
echo "kubectl port-forward -n $NAMESPACE svc/nats 4222:4222"
echo "kubectl port-forward -n $NAMESPACE svc/temporal-frontend 7233:7233"
echo "kubectl port-forward -n $NAMESPACE svc/temporal-web 8080:8080"
echo "kubectl port-forward -n $NAMESPACE svc/minio 9000:9000"
echo "kubectl port-forward -n $NAMESPACE svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "kubectl port-forward -n $NAMESPACE svc/prometheus-grafana 3000:80"
echo ""

echo -e "${GREEN}✅ Ready to start developing CodeMind!${NC}"