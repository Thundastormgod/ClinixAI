# ClinixAI Setup Guide

## Quick Start

Get ClinixAI running in 5 minutes.

### Prerequisites

- **Flutter SDK** 3.2.0 or higher
- **Dart SDK** 3.2.0 or higher
- **Android Studio** with Android SDK (for Android builds)
- **Xcode** 15+ (for iOS builds, macOS only)
- **Git**

---

## 1. Clone the Repository

```bash
git clone https://github.com/your-org/clinixai.git
cd clinixai
```

---

## 2. Environment Setup

### Create Environment File

```bash
cp .env.example .env
```

### Configure API Keys

Edit `.env` with your credentials:

```env
# OpenRouter API (Cloud AI fallback)
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxx

# Backend API (optional for cloud sync)
BACKEND_API_URL=https://api.clinixai.com
BACKEND_API_KEY=your-backend-key

# Model CDN (for downloading AI models)
MODEL_CDN_URL=https://cdn.clinixai.com/models
```

### Get API Keys

| Service | Purpose | Get Key |
|---------|---------|---------|
| OpenRouter | Cloud AI fallback | [openrouter.ai/keys](https://openrouter.ai/keys) |

---

## 3. Install Dependencies

### Flutter Dependencies

```bash
cd clinix_app
flutter pub get
```

### Generate Code (Isar, Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Platform Setup

### Android Setup

1. **Open Android Studio**
2. **Install SDK**: Tools → SDK Manager → Android 13 (API 33)
3. **Create Emulator**: Tools → Device Manager → Create Device

**Minimum Requirements:**
- minSdkVersion: 24 (Android 7.0)
- targetSdkVersion: 34 (Android 14)

### iOS Setup (macOS only)

1. **Install Xcode** from App Store
2. **Install CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```
3. **Install iOS dependencies**:
   ```bash
   cd ios && pod install && cd ..
   ```

---

## 5. Run the App

### Android Emulator

```bash
# List available devices
flutter devices

# Run on Android emulator
flutter run -d android
```

### iOS Simulator (macOS)

```bash
# Open iOS Simulator
open -a Simulator

# Run on iOS
flutter run -d ios
```

### Chrome (UI Testing Only)

```bash
flutter run -d chrome
```

> ⚠️ **Note:** Chrome mode does not support local AI (Cactus SDK). Only cloud fallback will work.

---

## 6. Download AI Models

### First Launch

On first launch, the app will prompt to download AI models:

1. **Qwen 0.5B Q4** (~350MB) - Language model for triage
2. **Whisper Tiny** (~75MB) - Speech-to-text model

### Manual Download (Optional)

```bash
# Create models directory
mkdir -p clinix_app/assets/models

# Download models (example URLs)
curl -o clinix_app/assets/models/qwen-0.5b-q4.gguf \
  https://cdn.clinixai.com/models/qwen-0.5b-q4.gguf

curl -o clinix_app/assets/models/whisper-tiny.bin \
  https://cdn.clinixai.com/models/whisper-tiny.bin
```

---

## 7. Backend Setup (Optional)

For full cloud sync functionality, run the backend services.

### Using Docker Compose

```bash
# From project root
docker-compose up -d
```

This starts:
- **API Gateway** (FastAPI) - Port 8000
- **PostgreSQL** - Port 5432
- **Ollama** (Local AI) - Port 11434

### Verify Backend

```bash
curl http://localhost:8000/health
# {"status": "healthy", "version": "1.0.0"}
```

---

## 8. Development Workflow

### Hot Reload

Flutter hot reload is enabled by default:
- Press `r` in terminal for hot reload
- Press `R` for hot restart

### Code Generation

After modifying models or providers:

```bash
dart run build_runner watch
```

### Linting

```bash
flutter analyze
```

### Run Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test file
flutter test test/core/ai/cactus_service_test.dart
```

---

## 9. Build for Release

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)

```bash
flutter build ios --release
# Then archive in Xcode for App Store
```

---

## Project Structure

```
clinixai/
├── clinix_app/              # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart        # App entry point
│   │   ├── core/            # Core services
│   │   │   ├── ai/          # AI services (Cactus, OpenRouter)
│   │   │   ├── database/    # Local database (Isar)
│   │   │   └── utils/       # Utilities
│   │   ├── features/        # Feature modules
│   │   │   ├── triage/      # Triage feature
│   │   │   ├── knowledge_base/
│   │   │   └── ehr_integration/
│   │   └── shared/          # Shared widgets
│   ├── test/                # Tests
│   ├── pubspec.yaml         # Dependencies
│   └── .env                 # Environment config
├── backend/                 # Backend services
│   ├── api-gateway/         # FastAPI gateway
│   ├── triage-service/      # Triage microservice
│   └── ehr-bridge/          # EHR integration
├── docs/                    # Documentation
├── docker-compose.yml       # Docker orchestration
└── .env                     # Root environment config
```

---

## Common Issues

### Issue: Isar build fails

**Solution:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Cactus SDK not found

**Solution:** Ensure you have the latest Cactus SDK:
```yaml
# pubspec.yaml
dependencies:
  cactus: ^1.2.0
```

### Issue: Android build fails with NDK error

**Solution:** Install NDK in Android Studio:
- Tools → SDK Manager → SDK Tools → NDK (Side by side)

### Issue: iOS pod install fails

**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### Issue: Model download fails

**Solution:** Check internet connection and try:
```dart
// In app, reset model status
await cactusService.dispose();
await cactusService.downloadModel('qwen-0.5b-q4');
```

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENROUTER_API_KEY` | Yes | OpenRouter API key for cloud AI |
| `BACKEND_API_URL` | No | Backend API URL |
| `BACKEND_API_KEY` | No | Backend authentication key |
| `MODEL_CDN_URL` | No | Custom model download URL |
| `DEBUG_MODE` | No | Enable debug logging |

---

## Next Steps

1. **Read the Architecture**: [ARCHITECTURE.md](./ARCHITECTURE.md)
2. **Explore the API**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
3. **Frontend Implementation**: [FRONTEND_IMPLEMENTATION_PLAN.md](./FRONTEND_IMPLEMENTATION_PLAN.md)

---

## Support

- **Issues**: [GitHub Issues](https://github.com/your-org/clinixai/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/clinixai/discussions)

---

*Document Version: 1.0.0*  
*Last Updated: November 29, 2025*
