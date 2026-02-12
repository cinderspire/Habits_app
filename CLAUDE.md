# Habits_app

> Build better habits with streaks, rewards, and beautiful progress tracking

## Project Info
- **Type:** Flutter App
- **Version:** 1.0.0+1
- **Organization:** com.cinderspire
- **Platforms:** iOS, Android

## Commands
```bash
flutter pub get          # Install deps
flutter run              # Debug run
flutter test             # Run tests
flutter build ios --no-codesign  # iOS build
flutter build appbundle  # Android AAB
```

## Key Dependencies
flutter,sdk,cupertino_icons,flutter_riverpod,google_fonts,fl_chart,flutter_local_notifications,shared_preferences,intl,

## Architecture
- State management: Check lib/ for Provider/Riverpod/Bloc patterns
- Entry point: lib/main.dart

## Guidelines
- Follow existing code patterns
- Run tests before committing
- Keep pubspec.yaml clean
- Target iOS 15+ and Android API 24+
