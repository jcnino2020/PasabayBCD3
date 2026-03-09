# PasabayBCD - SME Logistics Hub

A Flutter mobile application that lets small market vendors in Bacolod City (Libertad, Burgos, Central Market) book empty truck space for cargo delivery.

---

## Project Info
- **Course**: ITP211 - Mobile Application Development 2
- **Team**: Mercado, Niñonuevo | BSIT 3-B
- **Flutter**: 3.x | Dart: 3.x

---

## How to Run

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build APK for Android
flutter build apk --release
```

---

## App Flow

```
Splash → Onboarding → Login → Trip Matching → Trip Details
                                                     ↓
                               Profile ← Savings ← Live Tracking ← Driver Confirmation ← Cargo Form
```

---

## Screen List

| # | Screen | File |
|---|--------|------|
| 01 | Splash Screen | `splash_screen.dart` |
| 02 | Onboarding | `onboarding_screen.dart` |
| 03 | Login / Auth | `login_screen.dart` |
| 04 | Trip Matching (Core) | `trip_matching_screen.dart` |
| 05 | Trip Details | `trip_details_screen.dart` |
| 06 | Cargo Form (Core) | `cargo_form_screen.dart` |
| 07 | Driver Confirmation | `driver_confirmation_screen.dart` |
| 08 | Live Tracking (Core) | `live_tracking_screen.dart` |
| 09 | Savings Dashboard | `savings_dashboard_screen.dart` |
| 10 | Merchant Profile | `profile_screen.dart` |

---

## Flutter Concepts Used

- **StatefulWidget + setState()** - All interactive state updates
- **StatelessWidget** - Pure display components like TruckCard
- **Navigator.push() / pop()** - Screen-to-screen navigation
- **Column, Row, Expanded** - Core layout widgets
- **ListView.builder** - Efficient scrollable truck list
- **Stack + CustomPaint** - Live tracking map overlay
- **AnimationController** - Splash fade, truck pulse, tracker animation
- **TextEditingController** - Login form input handling

---

## Project Structure

```
lib/
├── main.dart                          # App entry point + theme
├── models/
│   ├── truck.dart                     # Truck model + sample data
│   └── booking.dart                   # Booking + transaction model
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── trip_matching_screen.dart
│   ├── trip_details_screen.dart
│   ├── cargo_form_screen.dart
│   ├── driver_confirmation_screen.dart
│   ├── live_tracking_screen.dart
│   ├── savings_dashboard_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── bottom_nav_bar.dart            # Shared bottom navigation
    └── truck_card.dart                # Reusable truck list card
```

---

## Design Language

- **Primary color**: `#1A56DB` (Blue)
- **Dark text**: `#111827`
- **Background**: `#F8FAFF`
- **Success**: `#10B981` (Green)
- **Warning**: `#D97706` (Amber)
- **Error**: `#DC2626` (Red)
- **Border radius**: 12–20px
- **Shadow**: subtle `0.06` opacity black

---

*No external packages used beyond Flutter SDK and cupertino_icons.*
