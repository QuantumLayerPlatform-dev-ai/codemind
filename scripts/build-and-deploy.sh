#!/bin/bash

# CodeMind Build and Deploy Script with Semantic Versioning
# Usage: ./build-and-deploy.sh [patch|minor|major]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 CodeMind Build and Deploy Pipeline${NC}"
echo -e "${BLUE}=====================================${NC}"

# Get current version and update
CURRENT_VERSION=$(cat VERSION)
echo -e "${YELLOW}📋 Current Version: ${CURRENT_VERSION}${NC}"

# Update version
./scripts/version.sh ${1:-patch}
NEW_VERSION=$(cat VERSION)

echo -e "${GREEN}📈 New Version: ${NEW_VERSION}${NC}"

# Build metadata
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
BUILD_ID="${NEW_VERSION}-${COMMIT_SHA}"

echo -e "${BLUE}🏗️  Building Docker Images${NC}"
echo -e "   📅 Build Date: ${BUILD_DATE}"
echo -e "   🔑 Commit SHA: ${COMMIT_SHA}"
echo -e "   🏷️  Build ID: ${BUILD_ID}"

# Registry settings
REGISTRY="ghcr.io"
REPO_OWNER="quantumlayerplatform-dev-ai"

# Build API
echo -e "${YELLOW}📦 Building CodeMind API...${NC}"
cd apps/api
docker build \
  --build-arg VERSION=${NEW_VERSION} \
  --build-arg BUILD_DATE=${BUILD_DATE} \
  --build-arg COMMIT_SHA=${COMMIT_SHA} \
  --label "version=${NEW_VERSION}" \
  --label "build-date=${BUILD_DATE}" \
  --label "commit-sha=${COMMIT_SHA}" \
  --label "component=api" \
  --label "project=codemind" \
  -t codemind-api:${NEW_VERSION} \
  -t codemind-api:latest \
  -t ${REGISTRY}/${REPO_OWNER}/codemind-api:${NEW_VERSION} \
  -t ${REGISTRY}/${REPO_OWNER}/codemind-api:latest \
  .

# Build Frontend
echo -e "${YELLOW}📦 Building CodeMind Frontend...${NC}"
cd ../frontend
docker build \
  --build-arg VERSION=${NEW_VERSION} \
  --build-arg BUILD_DATE=${BUILD_DATE} \
  --build-arg COMMIT_SHA=${COMMIT_SHA} \
  --label "version=${NEW_VERSION}" \
  --label "build-date=${BUILD_DATE}" \
  --label "commit-sha=${COMMIT_SHA}" \
  --label "component=frontend" \
  --label "project=codemind" \
  -t codemind-frontend:${NEW_VERSION} \
  -t codemind-frontend:latest \
  -t ${REGISTRY}/${REPO_OWNER}/codemind-frontend:${NEW_VERSION} \
  -t ${REGISTRY}/${REPO_OWNER}/codemind-frontend:latest \
  .

cd ../../

# Push to GitHub Container Registry
echo -e "${YELLOW}🚀 Pushing images to GHCR...${NC}"

# Check if we're logged into GHCR
if ! docker info 2>/dev/null | grep -q "${REGISTRY}"; then
    echo -e "${BLUE}📝 Please login to GHCR first:${NC}"
    echo -e "${BLUE}   echo \$GITHUB_TOKEN | docker login ${REGISTRY} -u USERNAME --password-stdin${NC}"
    echo -e "${BLUE}   Or set SKIP_PUSH=true to skip pushing${NC}"
    if [ "${SKIP_PUSH}" != "true" ]; then
        read -p "Continue without pushing? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        SKIP_PUSH=true
    fi
fi

if [ "${SKIP_PUSH}" != "true" ]; then
    echo -e "${YELLOW}📤 Pushing API image...${NC}"
    docker push ${REGISTRY}/${REPO_OWNER}/codemind-api:${NEW_VERSION}
    docker push ${REGISTRY}/${REPO_OWNER}/codemind-api:latest

    echo -e "${YELLOW}📤 Pushing Frontend image...${NC}"
    docker push ${REGISTRY}/${REPO_OWNER}/codemind-frontend:${NEW_VERSION}
    docker push ${REGISTRY}/${REPO_OWNER}/codemind-frontend:latest

    echo -e "${GREEN}✅ Images pushed to GHCR successfully!${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping image push (SKIP_PUSH=true)${NC}"
fi

# Update K8s manifests with new version
echo -e "${YELLOW}📝 Updating Kubernetes manifests...${NC}"
sed -i "s|image: .*codemind-api:.*|image: ${REGISTRY}/${REPO_OWNER}/codemind-api:${NEW_VERSION}|g" infrastructure/k8s/codemind-api.yaml
sed -i "s|image: .*codemind-frontend:.*|image: ${REGISTRY}/${REPO_OWNER}/codemind-frontend:${NEW_VERSION}|g" infrastructure/k8s/codemind-frontend.yaml

# Add version labels to K8s resources
echo "        version: \"${NEW_VERSION}\"" >> temp_api_labels
echo "        build-id: \"${BUILD_ID}\"" >> temp_api_labels
echo "        component: \"api\"" >> temp_api_labels

echo "        version: \"${NEW_VERSION}\"" >> temp_frontend_labels
echo "        build-id: \"${BUILD_ID}\"" >> temp_frontend_labels
echo "        component: \"frontend\"" >> temp_frontend_labels

# Deploy to Kubernetes
echo -e "${YELLOW}🚢 Deploying to Kubernetes...${NC}"
kubectl apply -f infrastructure/k8s/codemind-api.yaml
kubectl apply -f infrastructure/k8s/codemind-frontend.yaml

# Clean up temp files
rm -f temp_*_labels

# Wait for rollout
echo -e "${YELLOW}⏳ Waiting for deployment rollout...${NC}"
kubectl rollout status deployment/codemind-api -n codemind --timeout=300s
kubectl rollout status deployment/codemind-frontend -n codemind --timeout=300s

# Get service URLs
API_NODEPORT=$(kubectl get svc codemind-api-nodeport -n codemind -o jsonpath='{.spec.ports[0].nodePort}')
FRONTEND_NODEPORT=$(kubectl get svc codemind-frontend-nodeport -n codemind -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}========================${NC}"
echo -e "${GREEN}🔗 API URL: http://${NODE_IP}:${API_NODEPORT}${NC}"
echo -e "${GREEN}🔗 Frontend URL: http://${NODE_IP}:${FRONTEND_NODEPORT}${NC}"
echo -e "${GREEN}📋 Version: ${NEW_VERSION}${NC}"
echo -e "${GREEN}🏷️  Build ID: ${BUILD_ID}${NC}"

# Version milestone check
if [[ "${NEW_VERSION}" == "1.0.0" ]]; then
    echo -e "${GREEN}🎉🎉🎉 PRODUCTION RELEASE 1.0.0 ACHIEVED! 🎉🎉🎉${NC}"
elif [[ "${NEW_VERSION}" =~ ^0\.[0-9]+\.[0-9]+$ ]]; then
    PROGRESS=$(echo "${NEW_VERSION}" | cut -d. -f2)
    echo -e "${YELLOW}📊 Progress toward v1.0.0: ${PROGRESS}/10 major features${NC}"
fi

echo -e "${BLUE}🏁 Build and deploy pipeline completed successfully!${NC}"