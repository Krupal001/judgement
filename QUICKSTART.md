# 🚀 Quick Start Guide

## ✅ Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)
- Device/Emulator or Chrome for web

## 📦 Installation

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Verify Installation
```bash
flutter doctor
```

## 🎮 Running the App

### On Mobile (Android/iOS)
```bash
# Connect your device or start an emulator
flutter devices

# Run the app
flutter run
```

### On Web
```bash
flutter run -d chrome
```

### On Desktop
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 🏗️ Project Structure

```
judgement/
├── lib/
│   ├── core/                    # Core utilities
│   ├── features/judgement/      # Main feature
│   │   ├── data/               # Data layer
│   │   ├── domain/             # Business logic
│   │   └── presentation/       # UI layer
│   ├── injection_container.dart # DI setup
│   └── main.dart               # Entry point
├── test/                        # Tests
├── pubspec.yaml                # Dependencies
└── README.md                   # Documentation
```

## 🎯 Quick Commands

```bash
# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Build APK (Android)
flutter build apk

# Build for web
flutter build web

# Clean build files
flutter clean
```

## 🐛 Troubleshooting

### Issue: Dependencies not found
```bash
flutter clean
flutter pub get
```

### Issue: Build fails
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Hot reload not working
- Press 'r' in terminal for hot reload
- Press 'R' for hot restart

## 📱 Testing the App

### Manual Testing Flow
1. Launch app → See home screen
2. Tap "START GAME" → Game screen loads
3. Read scenario → Make a choice
4. View outcome → Tap "CONTINUE"
5. Complete all 5 scenarios
6. View results → See alignment
7. Tap "PLAY AGAIN" → Return to home

### Expected Behavior
- ✅ Smooth animations on all screens
- ✅ Progress bar updates after each scenario
- ✅ Score increases with each choice
- ✅ Outcome dialog shows after selection
- ✅ Final alignment matches choice distribution

## 🎨 Customization

### Add New Scenarios
Edit: `lib/features/judgement/data/datasources/scenario_local_data_source.dart`

```dart
const ScenarioModel(
  id: '6',
  title: 'Your Scenario Title',
  description: 'Your scenario description...',
  imageUrl: '🎭', // Any emoji
  category: 'Your Category',
  choices: [
    // Add 3 choices here
  ],
),
```

### Change Colors
Edit gradient colors in:
- `lib/features/judgement/presentation/pages/home_page.dart`
- `lib/features/judgement/presentation/pages/game_page.dart`
- `lib/features/judgement/presentation/pages/result_page.dart`

### Modify Fonts
Edit: `lib/features/judgement/presentation/pages/*.dart`
Change `GoogleFonts.orbitron()` or `GoogleFonts.poppins()` to any Google Font

## 📚 Learn More

- **Clean Architecture**: See `PROJECT_OVERVIEW.md`
- **Features**: See `FEATURES.md`
- **Full Documentation**: See `README.md`

## 🎉 You're Ready!

Run `flutter run` and enjoy the game! 🎮
