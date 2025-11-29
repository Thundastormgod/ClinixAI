# Contributing to ClinixAI

Thank you for your interest in contributing to ClinixAI! This document provides guidelines and instructions for contributing.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment. We expect all contributors to:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

---

## Getting Started

### Prerequisites

- Flutter 3.2.0+
- Dart 3.2.0+
- Git
- A GitHub account

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/clinixai.git
   cd clinixai
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/your-org/clinixai.git
   ```

### Setup Development Environment

```bash
# Install dependencies
cd clinix_app
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run tests to verify setup
flutter test
```

---

## Development Workflow

### Branch Naming

Use descriptive branch names:

| Type | Format | Example |
|------|--------|---------|
| Feature | `feature/description` | `feature/voice-input-improvements` |
| Bug Fix | `fix/description` | `fix/triage-crash-on-empty-input` |
| Documentation | `docs/description` | `docs/api-reference-update` |
| Refactor | `refactor/description` | `refactor/ai-service-architecture` |

### Creating a Branch

```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name
```

### Making Changes

1. Make your changes in small, logical commits
2. Write clear commit messages:
   ```
   feat: add voice recording timeout handling
   
   - Add 30-second timeout for voice recording
   - Show warning toast at 25 seconds
   - Auto-stop recording at timeout
   
   Closes #123
   ```

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Use For |
|--------|---------|
| `feat:` | New features |
| `fix:` | Bug fixes |
| `docs:` | Documentation changes |
| `style:` | Code style changes (formatting, etc.) |
| `refactor:` | Code refactoring |
| `test:` | Adding/updating tests |
| `chore:` | Maintenance tasks |

---

## Pull Request Process

### Before Submitting

1. ✅ Ensure all tests pass: `flutter test`
2. ✅ Run linting: `flutter analyze`
3. ✅ Format code: `dart format lib test`
4. ✅ Update documentation if needed
5. ✅ Add tests for new features

### Creating a Pull Request

1. Push your branch:
   ```bash
   git push origin feature/your-feature-name
   ```
2. Open a Pull Request on GitHub
3. Fill out the PR template completely
4. Link related issues

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### Review Process

1. At least one maintainer must approve
2. All CI checks must pass
3. Resolve all review comments
4. Squash commits before merging (if requested)

---

## Coding Standards

### Dart/Flutter Style

Follow the [Effective Dart](https://dart.dev/effective-dart) guidelines.

#### Naming Conventions

```dart
// Classes: PascalCase
class TriageService {}

// Variables/Functions: camelCase
final triageResult = await performTriage();

// Constants: lowerCamelCase
const defaultTimeout = Duration(seconds: 30);

// Private: prefix with underscore
String _internalState;
```

#### File Organization

```dart
// 1. Imports (sorted)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clinix_app/core/ai/cactus_service.dart';

// 2. Part directives
part 'triage_state.dart';

// 3. Constants
const kDefaultMaxTokens = 512;

// 4. Classes
class TriageScreen extends StatelessWidget {
  // ...
}
```

#### Widget Structure

```dart
class MyWidget extends StatelessWidget {
  // 1. Static constants
  static const defaultPadding = 16.0;
  
  // 2. Final fields
  final String title;
  final VoidCallback onTap;
  
  // 3. Constructor
  const MyWidget({
    super.key,
    required this.title,
    required this.onTap,
  });
  
  // 4. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 5. Helper methods
  Widget _buildHeader() {
    return Text(title);
  }
}
```

### Project Architecture

Follow Clean Architecture principles:

```
features/
└── feature_name/
    ├── data/               # Data layer
    │   ├── models/         # Data transfer objects
    │   ├── datasources/    # API clients, local storage
    │   └── repositories/   # Repository implementations
    ├── domain/             # Domain layer
    │   ├── entities/       # Business objects
    │   ├── repositories/   # Repository interfaces
    │   └── usecases/       # Business logic
    └── presentation/       # Presentation layer
        ├── screens/        # Full screens
        ├── widgets/        # Feature-specific widgets
        └── providers/      # Riverpod providers
```

---

## Testing

### Test Coverage Requirements

| Layer | Minimum Coverage |
|-------|------------------|
| Use Cases | 95% |
| Repositories | 85% |
| Services | 90% |
| Widgets | 70% |

### Writing Tests

#### Unit Tests

```dart
// test/core/ai/cactus_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:clinix_app/core/ai/cactus_service.dart';

void main() {
  group('CactusService', () {
    late CactusService service;
    
    setUp(() {
      service = CactusService();
    });
    
    tearDown(() async {
      await service.dispose();
    });
    
    test('should return false when model not loaded', () {
      expect(service.isLMLoaded, false);
    });
    
    test('should run inference successfully', () async {
      await service.loadModel('/path/to/model.gguf');
      final result = await service.runInference('Hello');
      expect(result.success, true);
      expect(result.text, isNotEmpty);
    });
  });
}
```

#### Widget Tests

```dart
// test/features/triage/presentation/voice_triage_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:clinix_app/features/triage/presentation/voice_triage_screen.dart';

void main() {
  testWidgets('displays microphone button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VoiceTriageScreen(),
      ),
    );
    
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
```

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/core/ai/cactus_service_test.dart

# With coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Documentation

### Code Documentation

Use DartDoc comments for public APIs:

```dart
/// Performs medical triage analysis on the given symptoms.
/// 
/// Takes a list of [symptoms] and returns a [TriageResult] with
/// urgency classification and recommendations.
/// 
/// Example:
/// ```dart
/// final result = await performTriage(['headache', 'fever']);
/// print('Urgency: ${result.urgencyLevel}');
/// ```
/// 
/// Throws [TriageException] if analysis fails.
Future<TriageResult> performTriage(List<String> symptoms);
```

### Updating Documentation

When making changes that affect documentation:

1. Update relevant markdown files in `docs/`
2. Update code comments
3. Update README if needed
4. Add changelog entry

---

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for questions
- Contact maintainers for security issues

---

Thank you for contributing to ClinixAI! 🎉
