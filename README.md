<p align="center">
  <img src="assets/dayz_hero_banner.png" alt="Dayz Banner" width="100%" />
</p>

<h1 align="center">🔥 Dayz</h1>

<p align="center">
  <strong>Track what matters. Build what lasts.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Riverpod-3.x-6C63FF?style=for-the-badge" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Hive-2.x-FF6F00?style=for-the-badge" alt="Hive" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

<p align="center">
  <em>A beautifully crafted Flutter app for tracking anniversaries and building daily habits — with a "Soft & Airy" design language that feels like a breath of fresh air.</em>
</p>

---

## ✨ What is Dayz?

**Dayz** is a personal companion app designed around two core ideas:

- 💕 **Anniversaries** — Never forget the milestones that matter. Track relationship anniversaries with beautiful countdowns.
- 🔥 **Streaks** — Build discipline through daily check-ins. Create multiple habits, assign them vibrant theme colors, and watch your calendar light up with progress.

Every pixel is intentionally designed with a **"Soft & Airy"** aesthetic — warm peach gradients for romance, calming mint tones for discipline, and large rounded cards that feel gentle to interact with.

---

## 🎨 Design Philosophy

| Principle | Implementation |
|---|---|
| **Soft & Airy** | Off-white backgrounds, pastel gradients, 24px rounded corners |
| **Haptic Feedback** | Light, medium, and heavy haptics on every interaction |
| **Color Identity** | Each streak gets its own theme color from a curated palette |
| **High-Contrast Calendar** | Checked-in dates pop with vivid color, drop shadows, and 🔥 icons |
| **Decluttered** | No harsh borders, minimal UI chrome, content-first layout |

### 🎨 Color Palette

```
Romantic        ██ Peach (#FDD6C4)  ██ Soft Pink (#FBC2EB)  ██ Blush (#F8B4B4)
Discipline      ██ Mint (#A8E6CF)   ██ Sky Blue (#CDE9F7)   ██ Teal (#5BB9A5)
Streak Themes   ██ Mint  ██ Peach  ██ Soft Blue  ██ Lavender  ██ Butter
Canvas          ██ Background (#F9F7F4)  ██ Text (#2D2D3A)
```

---

## 🏗️ Architecture

Dayz follows a **feature-first** architecture with clean separation of concerns:

```
lib/
├── core/
│   ├── router/           # GoRouter configuration
│   └── theme/            # "Soft & Airy" design tokens
├── features/
│   ├── anniversary/
│   │   ├── data/         # Anniversary model + Hive repository
│   │   └── presentation/ # AnniversaryCard, AddAnniversarySheet
│   ├── streak/
│   │   ├── data/         # Streak model + Hive repository
│   │   └── presentation/ # StreakCard, StreakDetailScreen, providers
│   ├── home/
│   │   └── presentation/ # HomeScreen with FAB + Add Streak dialog
│   └── shared/
│       └── presentation/ # CardOptionsSheet, SafeDeleteDialog
├── app.dart              # Root widget
└── main.dart             # Hive init + ProviderScope bootstrap
```

### Key Patterns

- **State Management** — [Riverpod 3.x](https://riverpod.dev/) with `Notifier` pattern
- **Persistence** — [Hive](https://docs.hivedb.dev/) for lightweight, zero-config local storage
- **Routing** — [GoRouter](https://pub.dev/packages/go_router) with dynamic `/streak/:id` paths
- **Immutability** — All models are immutable with `copyWith` factories
- **Testing** — Unit + Widget tests with [mocktail](https://pub.dev/packages/mocktail)

---

## 🚀 Features

### 💕 Anniversary Tracking
- Create anniversaries with title, date, and optional note
- Beautiful gradient countdown card with day counter
- Add via a themed bottom sheet with date picker

### 🔥 Streak Builder
- Create **multiple streaks** with unique names and theme colors
- 5 curated pastel colors to choose from (Mint, Peach, Blue, Lavender, Butter)
- Tap a card to view the **Streak Detail Screen**
- Visual **calendar** powered by `table_calendar` with high-contrast check-in markers
- One-tap daily check-in with heavy haptic feedback
- Longest streak tracking with badge display
- Long-press for edit/delete options with confirmation dialog

### 📅 Calendar UX
- Monthly view with custom `CalendarBuilders`
- Checked-in dates rendered as vibrant colored circles with drop shadow
- 🔥 fire emoji overlay on each completed day
- Bold white text for maximum contrast against the soft background
- Future dates are automatically disabled

---

## 📦 Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.10+ |
| **Language** | Dart 3.10+ |
| **State** | Riverpod 3.x (`Notifier`) |
| **Storage** | Hive 2.x (with `hive_flutter`) |
| **Routing** | GoRouter 17.x |
| **Calendar** | table_calendar 3.x |
| **IDs** | uuid 4.x |
| **Notifications** | flutter_local_notifications 17.x *(prepped)* |
| **Testing** | flutter_test + mocktail |
| **Code Gen** | build_runner + hive_generator |

---

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK `^3.10.4`
- Android Studio / VS Code
- A physical device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/dayz.git
cd dayz

# Install dependencies
flutter pub get

# Generate Hive adapters
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Running Tests

```bash
# Run all 60+ tests
flutter test

# Run with verbose output
flutter test --reporter expanded
```

---

## 📋 Development Phases

| Phase | Description | Status |
|---|---|---|
| **1** | Data models & Hive repositories | ✅ Complete |
| **2** | UI layer — Theme, Cards, HomeScreen | ✅ Complete |
| **3** | App assembly — Router, Providers, main.dart | ✅ Complete |
| **4** | Anniversary feature — AddAnniversarySheet | ✅ Complete |
| **5** | Edit & Delete — CardOptionsSheet, SafeDeleteDialog | ✅ Complete |
| **6** | Streak Detail Screen & Calendar UX | ✅ Complete |
| **6.5** | Multi-Streak Fix & Advanced UI Polish | ✅ Complete |
| **7** | Push Notifications *(planned)* | 🔜 Next |

---

## 🧪 Test Coverage

```
60+ tests across 6 test files:

✅ Anniversary model — creation, copyWith, toString
✅ Streak model — checkIn, reset, history, colorIndex
✅ StreakNotifier — add, checkIn, reset, delete, loadAll
✅ AnniversaryCard — empty state, rendering, interactions
✅ StreakCard — empty state, rendering, multi-streak display
✅ StreakDetailScreen — not found, detail view, check-in, checked state
✅ AddAnniversarySheet — form rendering, validation
```

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <strong>Built with 💕 and 🔥 in Flutter</strong>
</p>
