#!/bin/bash

# CodeMind Development Environment Startup Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="codemind"

echo -e "${BLUE}🛠️  CodeMind Development Environment${NC}"
echo "====================================="

# Check if infrastructure is deployed
echo -e "\n${YELLOW}🔍 Checking infrastructure...${NC}"

if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo -e "${RED}❌ CodeMind namespace not found. Run deploy-infrastructure.sh first${NC}"
    exit 1
fi

# Check if pods are running
PODS_NOT_READY=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
if [ "$PODS_NOT_READY" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some pods are not ready. Waiting...${NC}"
    kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=300s
fi

echo -e "${GREEN}✅ Infrastructure is ready${NC}"

# Create environment files
echo -e "\n${YELLOW}📄 Creating environment files...${NC}"

# Backend environment
cat > apps/api/.env << EOF
# Database
DATABASE_URL=postgresql://postgres:codemind-dev-password@localhost:5432/codemind
REDIS_URL=redis://:codemind-dev-password@localhost:6379

# AI Services
AWS_REGION=eu-west-2
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key

AZURE_OPENAI_ENDPOINT=https://your-azure-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-azure-api-key
AZURE_OPENAI_API_VERSION=2024-02-01

# Vector Database
QDRANT_URL=http://localhost:6333

# Temporal
TEMPORAL_HOST=localhost
TEMPORAL_PORT=7233

# NATS
NATS_URL=nats://localhost:4222

# MinIO
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=codemind-dev-password

# Development
DEBUG=true
LOG_LEVEL=debug
EOF

# Frontend environment
cat > apps/web/.env.local << EOF
# API
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_WS_URL=ws://localhost:8000

# Auth (Supabase or similar)
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key

# Development
NEXT_PUBLIC_ENV=development
EOF

echo -e "${GREEN}✅ Environment files created${NC}"

# Start port forwarding in background
echo -e "\n${YELLOW}🔌 Starting port forwarding...${NC}"

# Kill existing port forwards
pkill -f "kubectl port-forward" || true

# Start port forwards
kubectl port-forward -n $NAMESPACE svc/postgresql 5432:5432 &
kubectl port-forward -n $NAMESPACE svc/redis-master 6379:6379 &
kubectl port-forward -n $NAMESPACE svc/qdrant 6333:6333 &
kubectl port-forward -n $NAMESPACE svc/nats 4222:4222 &
kubectl port-forward -n $NAMESPACE svc/temporal-frontend 7233:7233 &
kubectl port-forward -n $NAMESPACE svc/temporal-web 8080:8080 &
kubectl port-forward -n $NAMESPACE svc/minio 9000:9000 &
kubectl port-forward -n $NAMESPACE svc/prometheus-kube-prometheus-prometheus 9090:9090 &
kubectl port-forward -n $NAMESPACE svc/prometheus-grafana 3000:80 &

# Wait for port forwards to establish
sleep 5

echo -e "${GREEN}✅ Port forwarding started${NC}"

# Check connections
echo -e "\n${YELLOW}🔍 Testing connections...${NC}"

# Test PostgreSQL
if nc -z localhost 5432; then
    echo -e "${GREEN}✅ PostgreSQL connection ready${NC}"
else
    echo -e "${RED}❌ PostgreSQL connection failed${NC}"
fi

# Test Redis
if nc -z localhost 6379; then
    echo -e "${GREEN}✅ Redis connection ready${NC}"
else
    echo -e "${RED}❌ Redis connection failed${NC}"
fi

# Test Qdrant
if nc -z localhost 6333; then
    echo -e "${GREEN}✅ Qdrant connection ready${NC}"
else
    echo -e "${RED}❌ Qdrant connection failed${NC}"
fi

echo -e "\n${GREEN}🎉 Development environment ready!${NC}"
echo "=================================="
echo -e "\n${BLUE}📋 Available Services:${NC}"
echo "PostgreSQL:     localhost:5432 (user: postgres, password: codemind-dev-password)"
echo "Redis:          localhost:6379 (password: codemind-dev-password)"
echo "Qdrant:         localhost:6333"
echo "NATS:           localhost:4222"
echo "Temporal UI:    http://localhost:8080"
echo "Temporal gRPC:  localhost:7233"
echo "MinIO:          localhost:9000 (minioadmin / codemind-dev-password)"
echo "Prometheus:     http://localhost:9090"
echo "Grafana:        http://localhost:3000 (admin / codemind-dev-password)"
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo "1. cd apps/api && pip install -r requirements.txt"
echo "2. cd apps/web && npm install"
echo "3. npm run dev"
echo ""
echo -e "${YELLOW}📝 Note: Environment files created with default values.${NC}"
echo -e "${YELLOW}Update .env files with your actual API keys before development.${NC}"
echo ""
echo -e "${RED}⚠️  To stop: Press Ctrl+C, then run: pkill -f 'kubectl port-forward'${NC}"

# Keep script running
echo -e "\n${BLUE}🔄 Keeping port forwards alive... Press Ctrl+C to stop${NC}"
wait