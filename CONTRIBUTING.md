# Contributing to TinyFal

Thank you for your interest in contributing to TinyFal! This document outlines the process for contributing to this Flutter project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Project Structure](#project-structure)
- [Making Contributions](#making-contributions)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.8.1 or higher)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Git](https://git-scm.com/)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for Firebase features)

### Platform-specific requirements:

- **Android**: Android Studio or VS Code with Flutter/Dart extensions
- **iOS**: Xcode (macOS only)
- **Web**: Chrome browser for testing

## Development Environment

1. **Fork the repository** and clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/tinyfal.git
   cd tinyfal
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify your Flutter installation**:
   ```bash
   flutter doctor
   ```

4. **Set up Firebase** (if working on Firebase-related features):
   ```bash
   firebase login
   flutter packages pub run build_runner build
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── firebase_options.dart  # Firebase configuration
└── src/
    └── app.dart          # Main app widget

functions/                 # Firebase Cloud Functions (Python)
├── main.py
└── requirements.txt

android/                  # Android-specific code
ios/                     # iOS-specific code
web/                     # Web-specific code
test/                    # Unit and widget tests
```

## Making Contributions

### Types of Contributions

We welcome the following types of contributions:

- 🐛 **Bug fixes**
- ✨ **New features**
- 📚 **Documentation improvements**
- 🧪 **Test additions/improvements**
- 🎨 **UI/UX enhancements**
- ⚡ **Performance optimizations**

### Before You Start

1. **Check existing issues** to see if your contribution is already being worked on
2. **Create an issue** for new features or major changes to discuss the approach
3. **Assign yourself** to the issue you're working on

## Code Style Guidelines

### Dart/Flutter Code Style

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).

#### Key Points:

- Use `dart format` to format your code
- Follow `lowerCamelCase` for variables and functions
- Use `UpperCamelCase` for classes and enums
- Prefer `final` over `var` where possible
- Add meaningful comments for complex logic

#### Example:

```dart
// Good
class UserProfile {
  final String userName;
  final int userAge;
  
  const UserProfile({
    required this.userName,
    required this.userAge,
  });
  
  // Calculate user status based on age
  String getUserStatus() {
    return userAge >= 18 ? 'adult' : 'minor';
  }
}

// Run formatter before committing
flutter format lib/
```

### Python Code Style (Cloud Functions)

For Firebase Cloud Functions in the `functions/` directory:

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guidelines
- Use meaningful variable and function names
- Add docstrings for functions
- Format code with `black` or similar formatter

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run tests for a specific file
flutter test test/widget_test.dart
```

### Writing Tests

- **Unit tests**: Test individual functions and classes
- **Widget tests**: Test UI components
- **Integration tests**: Test app workflows

Example test structure:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyfal/src/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('should create user with valid data', () {
      // Arrange
      const userName = 'John Doe';
      const userAge = 25;
      
      // Act
      final user = User(name: userName, age: userAge);
      
      // Assert
      expect(user.name, equals(userName));
      expect(user.age, equals(userAge));
    });
  });
}
```

## Pull Request Process

### Before Submitting

1. **Ensure your code follows the style guidelines**
2. **Run tests and ensure they pass**:
   ```bash
   flutter test
   flutter analyze
   dart format --set-exit-if-changed lib/
   ```
3. **Update documentation** if necessary
4. **Test on multiple platforms** if your changes affect UI

### Submitting a Pull Request

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit them with descriptive messages:
   ```bash
   git add .
   git commit -m "feat: add user authentication feature"
   ```

3. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request** with:
   - Clear title and description
   - Reference to related issues
   - Screenshots for UI changes
   - Testing instructions

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing completed
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested on Web

## Screenshots (if applicable)
Add screenshots here

## Related Issues
Fixes #123
```

## Reporting Issues

When reporting issues, please include:

1. **Clear description** of the problem
2. **Steps to reproduce** the issue
3. **Expected vs actual behavior**
4. **Device/platform information**:
   - Flutter version (`flutter --version`)
   - Platform (Android/iOS/Web)
   - Device model (if applicable)
5. **Screenshots or screen recordings** (if applicable)
6. **Error logs or stack traces**

### Issue Template

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Environment:**
 - Flutter version: [e.g., 3.8.1]
 - Platform: [e.g., Android, iOS, Web]
 - Device: [e.g., iPhone 12, Pixel 5]

**Additional context**
Add any other context about the problem here.
```

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow:

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Help

If you need help or have questions:

1. Check the existing issues and discussions
2. Create a new issue with the `question` label
3. Reach out to maintainers

## Recognition

Contributors will be recognized in:
- The project's README.md file
- Release notes for significant contributions
- GitHub's contributor insights

Thank you for contributing to TinyFal! 🚀
