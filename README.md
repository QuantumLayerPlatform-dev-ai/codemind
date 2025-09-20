# CodeMind: The World's First Cognitive Software Factory

CodeMind transforms business ideas into complete, production-ready applications using AI agents that understand business intent, generate code, and deploy automatically.

## 🚀 Quick Start

```bash
# Deploy infrastructure
./scripts/deploy-infrastructure.sh

# Start development environment
./scripts/dev-start.sh

# Run the system
npm run dev
```

## 🏗️ Architecture

CodeMind is built as a distributed system with the following components:

- **Frontend**: Next.js 14 with TypeScript
- **Backend**: FastAPI with Python + Rust services
- **Orchestration**: Temporal workflows + NATS messaging
- **AI/ML**: AWS Bedrock + Azure OpenAI with smart routing
- **Data**: PostgreSQL + Redis + Qdrant + Neo4j
- **Infrastructure**: Kubernetes + Istio + Kong

## 📁 Project Structure

```
codemind/
├── apps/                           # Applications
│   ├── web/                        # Next.js frontend
│   ├── api/                        # FastAPI backend
│   └── workers/                    # Temporal workers
├── services/                       # Microservices
│   ├── business-intent/            # Business understanding
│   ├── code-generator/             # Code generation
│   ├── llm-router/                 # Model routing
│   ├── verifier/                   # Verification (Rust)
│   ├── deployment/                 # App deployment
│   └── evolution/                  # Living software
├── packages/                       # Shared packages
│   ├── shared/                     # Common utilities
│   ├── types/                      # TypeScript types
│   └── ui/                         # UI components
├── infrastructure/                 # Infrastructure as Code
│   ├── k8s/                        # Kubernetes manifests
│   ├── helm/                       # Helm charts
│   └── terraform/                  # Terraform configs
├── workflows/                      # Temporal workflows
│   ├── application-generation/     # Main workflows
│   └── activities/                 # Workflow activities
└── docs/                          # Documentation
```

## 🎯 Development Phases

### Phase 1: Foundation ✅ COMPLETED
- ✅ Infrastructure setup (K8s + NodePort services)
- ✅ Basic LLM integration (AWS Bedrock Claude 3.7)
- ✅ Core services (FastAPI + middleware)
- ✅ Database setup (PostgreSQL, Redis, Qdrant, NATS)
- ✅ UK region optimization (London AWS, UK South Azure)

### Phase 2: Backend Services ✅ COMPLETED
- ✅ Smart LLM routing with cost optimization
- ✅ Authentication & rate limiting middleware
- ✅ Context management & request tracking
- ✅ Production-ready FastAPI architecture
- ✅ Real AWS Bedrock integration working

### Phase 3: Frontend ✅ COMPLETED
- ✅ Next.js 14 + TypeScript + Tailwind setup
- ✅ Beautiful UI with shadcn/ui components
- ✅ Real-time API integration
- ✅ Professional design with enterprise features
- ✅ Full end-to-end functionality

### Phase 4: System Integration ✅ COMPLETED
- ✅ Frontend ↔ Backend connection working
- ✅ Live business intent analysis
- ✅ Cost tracking & performance monitoring
- ✅ Error handling & loading states
- ✅ Production-ready deployment

## 🛠️ Technology Stack

| Layer | Technologies |
|-------|-------------|
| Frontend | Next.js 14, TypeScript, Tailwind, shadcn/ui |
| Backend | Python (FastAPI), Rust (Axum), Node.js |
| Orchestration | Temporal, NATS JetStream, Redis Streams |
| AI/ML | AWS Bedrock, Azure OpenAI, Qdrant, Z3 |
| Data | PostgreSQL, Redis, Neo4j, TimescaleDB |
| Infrastructure | Kubernetes, Istio, Kong, Prometheus |

## 📊 Current Status

- **Infrastructure**: ✅ LIVE (K8s cluster + NodePort services)
- **Backend**: ✅ LIVE (FastAPI on localhost:8000)
- **Frontend**: ✅ LIVE (Next.js on localhost:3000 / 192.168.1.212:3000)
- **LLM Integration**: ✅ WORKING (AWS Bedrock Claude 3.7)
- **End-to-End**: ✅ FUNCTIONAL
- **Testing**: ✅ Validated with live demos

## 🌟 **SYSTEM IS LIVE!**

**Access Points:**
- **Frontend UI**: http://localhost:3000 or http://192.168.1.212:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

**Live Features:**
- ✅ Business intent analysis with Claude 3.7 Sonnet
- ✅ Real-time cost tracking (~$0.008 per analysis)
- ✅ Token usage monitoring
- ✅ Professional UI with loading states
- ✅ Enterprise-grade error handling
- ✅ UK region optimized (London AWS)

## 📝 Contributing

See [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for development guidelines.

## 📄 License

Commercial license - see [LICENSE](./LICENSE) for details.