# ClinixAI Enterprise Mobile Application

## Overview
This is the enterprise-grade codebase for the ClinixAI Emergency Triage Tool, designed for the Mobile Agent Hackathon. It is built using Flutter and integrates with the Cactus SDK for on-device AI inference.

## Architecture
The project follows a **Clean Architecture** approach to ensure scalability, testability, and maintainability.

### Folder Structure
- `lib/core`: Core utilities, constants, and error handling shared across the app.
- `lib/features`: Feature-based modules (Triage, Knowledge Base, EHR Integration).
  - Each feature contains `data`, `domain`, and `presentation` layers.
- `lib/shared`: Shared UI components and widgets.

## Key Features
1.  **Local Triage Engine:** Uses LiquidAI models via Cactus SDK.
2.  **Hybrid Router:** Intelligently routes requests between local device and cloud.
3.  **EHR Integration:** Connects with systems like DHIS2/OpenMRS (planned).

## Setup
1.  Install Flutter SDK.
2.  Run `flutter pub get`.
3.  Configure Cactus SDK (see `docs/cactus_setup.md`).
4.  Run `flutter run`.

## Enterprise Standards
- **Linting:** Strict linting rules applied.
- **Testing:** Unit and Widget tests required for all new features.
- **CI/CD:** GitHub Actions configured for automated testing and build.
