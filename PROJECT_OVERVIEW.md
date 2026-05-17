# MTAG Queue Skipper - Project Overview

## 1) What this project is for

`MTAG Queue Skipper` is a Flutter mobile app that simulates a user flow for:

- User account registration and login
- Bike registration
- Token generation and token status tracking
- Viewing bike details and user profile

The app currently uses **local device storage** (`SharedPreferences`) for persistence and is designed as an offline/local-first prototype (no backend API integration yet).

---

## 2) Core user journey

1. User opens app -> splash screen
2. User logs in or registers
3. User lands on home screen
4. User registers a bike
5. App generates a token and shows token status
6. User can view bike details and profile

---

## 3) Tech stack

- **Framework**: Flutter
- **Language**: Dart (SDK constraint: `>=3.11.0 <4.0.0`)
- **State management**: `provider` (`ChangeNotifier`)
- **Persistence**: `shared_preferences`
- **Form input masking**: `mask_text_input_formatter`

---

## 4) Architecture summary

This app follows a lightweight layered structure:

- **UI Layer**: `lib/screens/*`
- **State Layer**: `lib/providers/*`
- **Data Models**: `lib/models/*`
- **Design System**: `lib/constants/*`

State is centralized in providers and consumed through `Provider.of`, `context.read`, and `context.watch`.

### Provider setup

`lib/main.dart` initializes:

- `AuthProvider` for user/session state
- `BikeDetailsProvider` for bike + token state

Both are injected at app root via `MultiProvider`.

---

## 5) Folder and file map

## `lib/main.dart`
- App bootstrap
- Registers providers
- Configures named routes

## `lib/models`
- `user.dart`: user entity (`name`, `cnic`, `phoneNumber`, `email`, `password`)
- `bike_details.dart`: bike + owner registration fields

## `lib/providers`
- `auth_provider.dart`: registration/login/logout/session loading
- `bike_details_provider.dart`: in-memory bike/token state + per-user persistence

## `lib/screens`
- `splash_screen.dart`
- `login_screen.dart`
- `register_screen.dart`
- `home_screen.dart`
- `bike_register_screen.dart`
- `token_status_screen.dart`
- `bike_details_screen.dart`
- `profile_screen.dart`

## `lib/constants`
- `app_colors.dart`
- `app_fonts.dart`
- `app_theme.dart` (theme definitions; currently not wired in `MaterialApp`)

---

## 6) Routing and navigation

Configured routes in `main.dart`:

- `/login`
- `/register`
- `/home`
- `/profile`
- `/bike-register`
- `/bike-details`
- `/token-status`

`home` is set to `SplashScreen`, and navigation is mostly done via `Navigator.pushNamed` or `pushNamedAndRemoveUntil`.

---

## 7) Screen-by-screen behavior

## Splash Screen
- Animated intro
- Delays 5 seconds
- Navigates to login screen

## Login Screen
- Validates email/password
- Calls `AuthProvider.login`
- On success:
  - loads active user's bike/token data via `BikeDetailsProvider.loadForUser(email)`
  - navigates to home

## Register Screen
- Collects full profile details
- Validates fields (name, CNIC, phone, email, password)
- Calls `AuthProvider.register`
- On success:
  - session is set to newly registered user
  - loads bike/token data for that user (usually empty initially)
  - navigates to home

## Home Screen
- Greets current user
- Entry points to bike registration, token, bike details, and profile

## Bike Register Screen
- Collects owner + bike details
- Generates token metadata
- Stores data in `BikeDetailsProvider`
- Persists bike/token for logged-in user using `saveForUser(email)`
- Navigates to token status

## Token Status Screen
- Shows token and metadata from:
  - route arguments when present, else
  - provider state
- Handles no-token state and provides CTA to register bike

## Bike Details Screen
- Displays bike/owner details from provider
- Shows empty state if no bike is loaded

## Profile Screen
- Displays logged-in user details from `AuthProvider.user`

---

## 8) State management details

### `AuthProvider`

Responsibilities:
- Current in-memory user
- Register/login/logout
- Load persisted session
- Persist user directory (multi-user support)

Persistence keys:
- `users_v1`: JSON map of users keyed by normalized email
- `current_user_email`: active session email

Backward compatibility:
- Reads legacy single-user key `user` and migrates into map shape in memory

### `BikeDetailsProvider`

Responsibilities:
- Current in-memory bike details
- Current token state (`tokenNumber`, `tokenStatus`, `tokenEstimatedTime`, `tokenGeneratedAt`)
- Persist/load bike+token per active user

Persistence key format:
- `bike_data_<normalized_email>`

This ensures each user keeps independent bike/token data.

---

## 9) Data model design

## `User`
- Serializable via `toMap`/`fromMap` and `toJson`/`fromJson`
- Used in auth/session flow and profile display

## `BikeDetails`
- Serializable via `toMap`/`fromMap` and `toJson`/`fromJson`
- Stored as part of bike/token provider payload

## `BikeDetailsProvider` serialization
- Provider itself can serialize complete bike+token state
- Used for local persistence per user

---

## 10) Local storage behavior (important)

### What is persisted
- User directory (`users_v1`)
- Current logged-in user (`current_user_email`)
- Bike+token data per user (`bike_data_<email>`)

### What is not persisted
- UI-only states (password visibility toggles, form in-progress state, etc.)

### Current result
- Multiple users can register without overwriting each other
- Bike/token data remains linked to the user account and restores after re-login

---

## 11) Dependencies

From `pubspec.yaml`:

- `flutter` (SDK)
- `cupertino_icons`
- `provider`
- `mask_text_input_formatter`
- `shared_preferences`
- `flutter_test` (dev)
- `flutter_lints` (dev)

---

## 12) Theming and UI system

- Central colors defined in `app_colors.dart`
- Typography presets in `app_fonts.dart`
- Full `ThemeData` exists in `app_theme.dart`

Note: current `MaterialApp` does not yet attach `theme: AppTheme.lightTheme`, so screens currently rely mostly on local widget styling.

---

## 13) Build and run

Prerequisites:
- Flutter SDK installed
- Dart SDK compatible with project constraints
- Emulator/device available

Commands:

```bash
flutter pub get
flutter run
```

Optional:

```bash
flutter test
```

---

## 14) Known limitations

- No backend/API; all data is local-device only
- Passwords are stored as plain text in local storage (prototype-level only)
- Limited global error reporting and retry strategy
- Splash does not yet auto-redirect based on active session
- No dedicated repository/service layer (providers directly handle persistence)

---

## 15) Suggested next improvements

1. Introduce secure auth storage (token-based + encryption for sensitive data)
2. Add session-aware splash routing (`loadUser` + conditional navigation)
3. Add logout action that clears only in-memory user-linked provider state
4. Move persistence logic into dedicated services/repositories
5. Add tests for:
   - multi-user register/login
   - per-user bike/token restore
   - validation flows
6. Connect to backend API for real user and bike lifecycle

---

## 16) Quick glossary

- **Provider**: state container notifying UI listeners on updates
- **Session**: currently active logged-in user
- **Token**: generated queue identifier with status and ETA
- **Per-user keying**: storing data under email-based keys to avoid cross-user overwrite

