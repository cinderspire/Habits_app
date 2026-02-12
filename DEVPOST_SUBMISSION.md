# Habitly — RevenueCat Shipyard 2026 Submission

## Project Title

**Habitly — Beautiful Habit Tracking That Grows With You**

## Tagline

Streaks, challenges, and habit stacking — wrapped in warm earth tones that make building better habits feel like tending a garden.

---

## Inspiration

Most habit trackers feel like spreadsheets with a coat of paint. They nag you, guilt-trip you when you miss a day, and treat every habit the same — whether it's "drink water" or "meditate for 30 minutes."

We wanted something different. Something that feels **warm and encouraging**, not cold and transactional. Something designed by "Gabby" — our internal brief for an app that feels like a supportive friend who celebrates your wins and gently nudges you back when you stumble.

The research is clear: **habit formation isn't about willpower — it's about systems.** James Clear's *Atomic Habits* showed that stacking habits, tracking streaks, and making progress visible are the three most effective levers. Habitly brings all three together in one beautifully crafted experience.

---

## What It Does

Habitly is a premium habit tracking app built around three core pillars: **streaks, challenges, and habit stacking.**

### 🔥 Streaks & Progress

- **Visual streak tracking** with animated streak cards that celebrate consistency
- **Progress rings** showing daily, weekly, and monthly completion rates
- **Calendar heatmap** — see your habit history at a glance, like GitHub's contribution graph but for your life

### 🏆 Challenges

- **Built-in habit challenges** with progressive difficulty — 7-day, 21-day, and 66-day programs
- **Challenge provider system** that tracks progress, milestones, and completion
- Each challenge is backed by behavioral science on habit formation timelines

### 🔗 Habit Stacking

- **Habit stacking screen** — link habits together so completing one triggers the next
- Based on the proven "after I [current habit], I will [new habit]" framework
- Visual chains show your habit stacks and daily flow

### 📊 Statistics & Insights

- **Detailed statistics screen** with charts powered by fl_chart
- Weekly review system that summarizes your wins and areas for improvement
- Habit detail views with per-habit analytics and history

### 🎨 Design Philosophy

Earth-tone palette (#1B4332 deep forest, #F5E6CA warm cream, #C67C4E terracotta) creates a calming, organic feel. Custom text styles via Google Fonts. Animated widgets throughout for delightful micro-interactions.

### 💰 Monetization (RevenueCat-Powered)

| Tier | Price | What You Get |
|------|-------|-------------|
| **Free** | $0 | Core habit tracking, 5 habits, basic streaks |
| **Pro** | $5.99/mo | Unlimited habits, challenges, habit stacking, advanced stats, weekly reviews |

---

## How We Built It

### Architecture

- **Flutter + Dart** — Single codebase targeting iOS and Android
- **Riverpod** — Reactive state management with providers for habits, challenges, and premium state
- **SharedPreferences** — Local-first storage keeping all habit data on-device
- **fl_chart** — Beautiful, animated charts for the statistics dashboard
- **RevenueCat (purchases_flutter ^8.1.0)** — Subscription management and entitlement gating
- **flutter_local_notifications** — Smart reminders that keep users on track

### RevenueCat Integration

RevenueCat powers Habitly's entire premium experience:

1. **Premium Gate Widget** — A reusable `PremiumGate` widget wraps every Pro feature. It checks RevenueCat entitlements in real-time and presents the paywall when free users tap locked features.

2. **Dedicated Paywall Screen** — Beautiful upgrade flow with feature highlights, powered by RevenueCat's purchase infrastructure.

3. **Revenue Cat Service** — Centralized service handling initialization, purchase flow, restore purchases, and entitlement checks. Clean separation from business logic.

4. **Entitlement-Gated Features** — Challenges, habit stacking, advanced statistics, and weekly reviews all check premium status through RevenueCat before rendering.

### Key Technical Decisions

- **Local-first privacy** — All habit data stays on-device. No accounts, no cloud sync, no data collection.
- **Notification service** — Custom notification scheduling for habit reminders with smart timing.
- **Onboarding flow** — Guided setup that helps users create their first habits and understand stacking.

---

## Challenges We Ran Into

1. **Making streaks motivating, not punishing.** We iterated on streak break handling — instead of resetting to zero, we show "longest streak" alongside "current streak" so users never feel like they've lost all progress.

2. **Habit stacking UX.** Visualizing linked habits in a way that's intuitive took several iterations. The chain metaphor worked best.

3. **Notification fatigue.** Finding the right balance between helpful reminders and annoying spam required careful default settings and easy customization.

4. **Calendar performance.** Rendering months of habit completion data with smooth scrolling required optimized data structures and lazy loading.

---

## Accomplishments We're Proud Of

- 🔥 **Streak system** that motivates without guilt-tripping
- 🔗 **Habit stacking** — a feature most habit apps ignore despite strong scientific backing
- 🏆 **Challenge system** with progressive difficulty based on habit formation research
- 🎨 **Earth-tone design** that feels warm and organic — users describe it as "cozy"
- 📊 **Rich statistics** that make progress tangible and satisfying
- 💰 **Clean RevenueCat integration** with reusable PremiumGate widget pattern
- 🔒 **100% local data** — zero privacy concerns

---

## What's Next

- 🤖 **AI Habit Coach** — Personalized suggestions based on completion patterns
- 👥 **Social Accountability** — Share challenges with friends
- ⌚ **Apple Watch Complications** — Quick habit check-offs from your wrist
- 🌍 **Widget Support** — iOS and Android home screen widgets for at-a-glance progress
- 📊 **RevenueCat Experiments** — A/B test pricing and trial lengths
- 🔄 **iCloud Sync** — Optional cloud backup for multi-device users

---

## Built With

- **Flutter** — Cross-platform UI framework
- **Dart** — Application language
- **RevenueCat (purchases_flutter ^8.1.0)** — Subscription management & monetization
- **Riverpod** — Reactive state management
- **fl_chart** — Data visualization
- **flutter_local_notifications** — Smart reminders
- **SharedPreferences** — Local data persistence
- **Google Fonts** — Typography
- **Material Design 3** — Adaptive UI system

---

## Try It

- **Bundle ID:** `com.cinderspire.habits`
- **Privacy Policy:** https://playtools.top/privacy-policy.html
- **Developer:** MUSTAFA BILGIC

---

*Habitly: Small habits, big changes. One streak at a time.* 🌱
