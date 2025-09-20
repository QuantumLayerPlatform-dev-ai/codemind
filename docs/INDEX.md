# CodeMind Documentation Index

Welcome to the comprehensive documentation for CodeMind - the world's first cognitive software factory!

## 📚 Documentation Index

### **Getting Started**
- [**README.md**](../README.md) - Main project overview and quick start
- [**CLAUDE.md**](./CLAUDE.md) - Guide for future Claude instances working with CodeMind

### **Technical Implementation**
- [**IMPLEMENTATION_SUMMARY.md**](./IMPLEMENTATION_SUMMARY.md) - Complete technical summary of the live system
- [**infrastructure-strategy.md**](./infrastructure-strategy.md) - Infrastructure decisions and K8s architecture

### **Business & Product**
- [**codemind-executive-summary.md**](./codemind-executive-summary.md) - Executive overview and business case
- [**codemind-startup-blueprint.md**](./codemind-startup-blueprint.md) - Comprehensive 73KB startup blueprint
- [**product-visualization.md**](./product-visualization.md) - Product concept and visualization
- [**complete-product-experience.md**](./complete-product-experience.md) - Full product experience documentation

## 🚀 Component Documentation

### **Frontend** - Next.js 14 UI ✅ WORKING
📁 **Location**: `/apps/frontend/` | 🔗 **Repo**: [codemind-frontend](https://github.com/QuantumLayerPlatform-dev-ai/codemind-frontend)
- Professional React interface with shadcn/ui
- Real-time API integration with business intent analysis
- Enterprise UX with loading states and error handling

### **API** - FastAPI Backend ✅ WORKING
📁 **Location**: `/apps/api/` | 🔗 **Repo**: [codemind-api](https://github.com/QuantumLayerPlatform-dev-ai/codemind-api)
- Intelligent LLM routing (Claude 3.7, Azure OpenAI)
- Enterprise middleware (auth, rate limiting, context tracking)
- Production-ready modular architecture

### **Infrastructure** - Kubernetes ✅ DEPLOYED
📁 **Location**: `/infrastructure/` | 🔗 **Repo**: [codemind-infrastructure](https://github.com/QuantumLayerPlatform-dev-ai/codemind-infrastructure)
- K8s manifests for all services (NodePort strategy)
- One-command deployment scripts
- PostgreSQL, Redis, Qdrant, NATS, Temporal, MinIO

## 📁 **Repository Structure**

**This is a monorepo** containing all working components:
- **Main development**: Use this repository
- **Component access**: Individual repos available for focused work
- **Documentation**: Comprehensive docs in `/docs/` directory

## 🎯 Current System Status

- **✅ LIVE**: All components operational
- **✅ GitHub**: Code and docs versioned
- **✅ UK Optimized**: London AWS + UK South Azure
- **✅ Enterprise Ready**: Production architecture

## 📖 Quick Links

- **Live Frontend**: http://localhost:3000 / http://192.168.1.212:3000
- **Live API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## 🤝 Contributing

This documentation is part of the CodeMind cognitive software factory ecosystem. See individual component repositories for specific contribution guidelines.

---

**🇬🇧 Built in the UK, for the UK, ready for the world! 🚀**