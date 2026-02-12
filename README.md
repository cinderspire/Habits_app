# Gabby — Goals, Streaks & Accountability

> A beautiful Flutter app for building better habits with streaks, community challenges, and RevenueCat-powered premium features.

**Built for the RevenueCat Hackathon — "Gabby" Brief**

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![RevenueCat](https://img.shields.io/badge/RevenueCat-Integrated-FF6B35)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android-green)

---

## 🎯 What is Gabby?

Gabby is a goal-setting and accountability app that helps users build lasting habits through:

- **Habit Tracking** — Create and track daily, weekly, or custom-frequency habits
- **Streak System** — Visual streak counters with fire animations and milestone rewards
- **Habit Strength** — A unique 0-100% strength meter showing how ingrained each habit is
- **Community Challenges** — Join 7, 14, 21, or 30-day challenges (Premium)
- **Habit Stacking** — Chain habits together for maximum efficiency (Premium)
- **Weekly Reviews** — AI-generated insights on your performance (Premium)
- **Streak Freezes** — Protect your streak on off days (1 per week per habit)

## 💰 RevenueCat Integration

Gabby uses RevenueCat (`purchases_flutter`) to power its freemium model:

### Free Tier
- Up to **3 habits**
- Basic streak tracking
- Calendar view
- Statistics dashboard

### Premium ($4.99/mo or $29.99/yr)
- **Unlimited habits**
- **Community Challenges** — 6 pre-built challenges (meditation, reading, exercise, etc.)
- **AI Insights** — Smart suggestions based on your completion patterns
- **Weekly Review** — Detailed performance analysis with actionable tips
- **Habit Stacking** — Chain habits into routines
- **Streak Freezes** — Protect your streaks

### Implementation Details
- `purchases_flutter: ^8.1.0` and `purchases_ui_flutter: ^8.1.0`
- RevenueCat service singleton (`lib/core/services/revenue_cat_service.dart`)
- Riverpod-based subscription state management
- Paywall screen with package selection and restore purchases
- Feature gating throughout the app via `isPremiumProvider`

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/     # App constants, colors, icons
│   ├── models/        # Habit data model with JSON serialization
│   ├── providers/     # Riverpod providers (habits, theme, computed)
│   ├── services/      # Storage, notifications, RevenueCat
│   ├── theme/         # Colors, text styles
│   └── widgets/       # Reusable animated widgets
├── features/
│   ├── add_habit/     # Create new habit screen
│   ├── calendar/      # Monthly calendar view
│   ├── challenges/    # Community challenges (Premium)
│   ├── habit_detail/  # Individual habit stats & history
│   ├── habit_stacking/# Chain habits into routines (Premium)
│   ├── home/          # Main dashboard with habit cards
│   ├── onboarding/    # First-launch onboarding flow
│   ├── paywall/       # RevenueCat paywall screen
│   ├── settings/      # App settings & subscription management
│   ├── statistics/    # Charts and analytics
│   └── weekly_review/ # Performance review (Premium)
└── main.dart
```

**State Management:** Flutter Riverpod  
**Persistence:** SharedPreferences (JSON serialization)  
**Charts:** fl_chart  
**Notifications:** flutter_local_notifications  

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Xcode (for iOS)
- Android Studio (for Android)

### Setup

```bash
# Clone and install dependencies
cd Habits_app
flutter pub get

# Run in debug mode
flutter run

# Build for iOS
flutter build ios --no-codesign

# Build for Android
flutter build appbundle
```

### RevenueCat Configuration

1. Create a project at [app.revenuecat.com](https://app.revenuecat.com)
2. Create products: `gabby_premium_monthly` and `gabby_premium_yearly`
3. Create an entitlement called `premium`
4. Replace the API keys in `lib/core/services/revenue_cat_service.dart`:

```dart
static const String appleApiKey = 'appl_YOUR_KEY';
static const String googleApiKey = 'goog_YOUR_KEY';
```

## 📱 Screenshots

The app features:
- Gradient streak cards with fire animations
- Habit strength meters (seed → tree progression)
- Beautiful paywall with package selection
- Challenge cards with progress bars
- Dark mode support

## 🧪 Key Features Deep Dive

### Habit Model
Each habit tracks: name, icon, color, frequency, completion dates, streak freeze dates, completion times (for smart reminders), and habit stacking metadata.

### Streak Calculation
Streaks are calculated from consecutive completed or frozen dates, counting backwards from today. Longest streak is also tracked for motivation.

### Habit Strength (0-100%)
A weighted score over the last 30 days where recent days count more. Completed days get full weight, frozen days get 50%.

### Community Challenges
Pre-built templates for meditation, reading, hydration, exercise, journaling, and digital detox. Each tracks daily completion with a visual progress bar.

## 📄 License

MIT License — built for the RevenueCat Hackathon.

---

**Made with ❤️ and Flutter**
