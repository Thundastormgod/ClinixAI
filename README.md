# ClinixAI

<div align="center">

![ClinixAI Logo](docs/assets/logo.png)

**AI-Powered Emergency Medical Triage for Africa**

[![Flutter](https://img.shields.io/badge/Flutter-3.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#features) • [Quick Start](#quick-start) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## Overview

ClinixAI is an AI-powered mobile application that provides emergency medical triage to underserved communities in Africa. Using on-device AI inference, it works offline in areas with limited connectivity while providing enhanced capabilities when online.

### Key Highlights

- 🏥 **Medical Triage** - AI-powered symptom analysis with urgency classification
- 🎤 **Voice-First** - Natural language symptom description via voice
- 📱 **Offline-First** - Full functionality without internet connection
- 🔒 **Privacy-Focused** - On-device AI processing, no data leaves the phone
- 🌍 **Built for Africa** - Designed for low-bandwidth, resource-constrained environments

---

## Features

### 🤖 On-Device AI

- **Local LLM** (Qwen 0.5B) for medical triage analysis
- **Speech-to-Text** (Whisper) for voice input
- **RAG System** for medical knowledge retrieval
- No internet required for core functionality

### 🔄 Hybrid Architecture

- Automatic switching between local and cloud AI
- Cloud fallback (GPT-4o, Claude, Gemini) for complex cases
- Seamless offline-to-online sync

### 📊 Triage System

| Urgency | Color | Action Required |
|---------|-------|-----------------|
| Level 1 | 🔴 | Immediate emergency care |
| Level 2 | 🟠 | Emergency within 1 hour |
| Level 3 | 🟡 | Medical attention within 4 hours |
| Level 4 | 🟢 | Scheduled care acceptable |
| Level 5 | 🔵 | Self-care or routine visit |

### 🏗️ Clean Architecture

- Feature-based modular structure
- Riverpod state management
- Isar local database
- Comprehensive test coverage

---

## Quick Start

### Prerequisites

- Flutter 3.2.0+
- Dart 3.2.0+
- Android Studio / Xcode

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/clinixai.git
cd clinixai

# Setup environment
cp .env.example .env
# Edit .env with your OpenRouter API key

# Install dependencies
cd clinix_app
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

See [SETUP_GUIDE.md](docs/SETUP_GUIDE.md) for detailed instructions.

---

## Documentation

| Document | Description |
|----------|-------------|
| [Setup Guide](docs/SETUP_GUIDE.md) | Installation and configuration |
| [Architecture](docs/ARCHITECTURE.md) | System design and components |
| [API Documentation](docs/API_DOCUMENTATION.md) | API reference |
| [Frontend Plan](docs/FRONTEND_IMPLEMENTATION_PLAN.md) | UI/UX implementation details |

---

## Tech Stack

### Mobile App
- **Framework**: Flutter 3.2+
- **Language**: Dart 3.2+
- **State Management**: Riverpod
- **Local Database**: Isar
- **On-Device AI**: Cactus SDK (llama.cpp)

### Backend
- **API**: FastAPI (Python)
- **Database**: PostgreSQL + pgvector
- **AI**: Ollama, OpenRouter
- **EHR**: DHIS2/OpenMRS integration

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **CI/CD**: GitHub Actions

---

## Project Structure

```
clinixai/
├── clinix_app/          # Flutter mobile application
│   ├── lib/
│   │   ├── core/        # Core services (AI, database)
│   │   ├── features/    # Feature modules
│   │   └── shared/      # Shared components
│   └── test/            # Tests
├── backend/             # Backend microservices
│   ├── api-gateway/     # FastAPI gateway
│   ├── triage-service/  # Triage processing
│   └── ehr-bridge/      # EHR integration
├── docs/                # Documentation
└── docker-compose.yml   # Container orchestration
```

---

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Install dev dependencies
flutter pub get

# Run tests
flutter test

# Check code style
flutter analyze

# Format code
dart format lib test
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **Cactus SDK** for on-device LLM inference
- **Nothing Phone** design inspiration
- **Mobile Agent Hackathon** for the opportunity

---

<div align="center">

**Built with ❤️ for healthcare accessibility in Africa**

</div>
