# AIRings Mobile

Flutter mobile app for the **AIRings** AI-powered early detection platform. This build uses **mock data** (no backend API) and **stubbed Bluetooth** (GATT integration can be added later).

## Requirements

- Flutter 3.41+ (Dart 3.11+)

## Getting started

```bash
cd C:\Users\zaki\Documents\airings_mobile
flutter pub get
flutter run
```

## Demo credentials

| Field    | Value            |
|----------|------------------|
| Email    | `demo@airings.ai` |
| Password | `demo1234`        |

Or tap **Demo Access** on the login screen.

## Features (mock)

- Login / registration / onboarding with medical questionnaire
- Sign in with Google / Apple (mock), forgot password dialog
- Dashboard with Risk Score, metrics (incl. activity), 72h calibration banner, diary shortcuts
- Food & activity diary with chart annotations
- Analytics with multi-metric overlay, period filters, and event annotations
- Alerts feed with type + date filters, custom thresholds, resolve action
- Subscription plans: Basic ($99) and Plus Premium ($199)
- Notification settings (Push / Email / SMS toggles)
- Alert threshold customization (warning 70+, critical 90+)
- Light / dark theme toggle
- Device screen with mock BLE scan & sync
- Profile & settings with medical disclaimer (not a medical device)


