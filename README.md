<<<<<<< HEAD
# Calley — Automatic Call Dialer (Flutter Machine Test)

Flutter implementation of the **Get Calley** mobile application built for the **C S Tech Infosolutions** Flutter Mobile App Developer Machine Test.

## Implemented Screens (Figma Reference)

| # | Screen | Source File |
|---|--------|-------------|
| 01 | **Choose Your Language** (9 languages with radio selection) | `lib/ui/screens/language_screen.dart` |
| 02 | **Register (`Welcome!`)** (Name, Email, Password, `+91` Country Code, Mobile, Terms checkbox) | `lib/ui/screens/register_screen.dart` |
| 03 | **Whatsapp OTP Verification** (6-digit OTP boxes, Resend OTP, Verify CTA) | `lib/ui/screens/otp_verification_screen.dart` |
| 04 | **Login (`Welcome`)** (Email, Password, Forgot Password, Sign In CTA) | `lib/ui/screens/login_screen.dart` |
| 05 | **Onboarding (`2 Minute Challenge`)** (Greeting card, tutorial card, WhatsApp + Start Calling CTA) | `lib/ui/screens/onboarding_screen.dart` |
| 06 | **Dashboard — Empty State (`LOAD NUMBER TO CALL`)** (Greeting card, web-panel link, illustration, custom 5-tab bottom bar) | `lib/ui/screens/dashboard_screen.dart` |
| 07 | **Calling Lists Bottom Sheet & Profile Settings** (`Select Calling List`, `Refresh` button, `Test List`, Profile Settings) | `lib/ui/screens/calling_lists_sheet.dart`, `lib/ui/screens/settings_screen.dart` |
| 08 | **Dashboard — Active List Analytics** (`Test List / 50 CALLS`, custom 3-segment Donut Chart, `Pending`, `Done`, `Schedule` stat cards) | `lib/ui/screens/dashboard_screen.dart`, `lib/ui/widgets/donut_chart.dart` |
| 09 | **Side Navigation Drawer** (Profile header, Getting Started, Sync Data, Gamification, Send Logs, Settings, Help, App Info, Logout) | `lib/ui/screens/app_drawer.dart` |
| + | **Interactive Call Records List & Dialer** (Filter by All / Pending / Done / Schedule from `GET /list/{listId}`) | `lib/ui/screens/calls_list_screen.dart` |

## REST API Integration (Mock API V2)

Base URL: `https://mock-api.calleyacd.com/api`

- `POST /auth/register` — Registers a new user (`username`, `email`, `password`)
- `POST /auth/login` — Authenticates an existing user (`email`, `password`)
- `POST /auth/send-otp` — Sends a verification OTP (`email`)
- `POST /auth/verify-otp` — Verifies the 6-digit OTP (`email`, `otp`)
- `GET /list?userId={userId}` — Fetches calling lists for the user
- `GET /list/{listId}` — Fetches pending/called/rescheduled counts and the 50 call records

> **Resilient Offline Fallback:** Every request hits `https://mock-api.calleyacd.com/api` first (`lib/data/services/remote_calley_data_source.dart`). If the remote mock host is unreachable or offline, `CalleyRepository` transparently falls back to `LocalMockCalleyDataSource` (`lib/data/services/local_mock_calley_data_source.dart`), which serves the exact JSON payloads from the Postman collection (`assets/mock/list_details.json`).

## Running the Project

```bash
cd calley_app
flutter pub get
flutter run
```

### Building the Debug APK

```bash
cd calley_app
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```
=======
# calley_app
>>>>>>> 6e03ab7ab1d3e8335db8aa9fb1a260b947e80f42
