# MTAG Queue Skipper

A Flutter app that lets riders in Islamabad register their motorcycle for an
MTAG card without waiting in the queue: register the bike, take a reference
selfie, pay the fee, get a queue token, then collect the card at the counter
after a quick face check.

- **App:** Flutter (Android/iOS), `provider` for state
- **Backend:** Firebase Auth, Cloud Firestore, Cloud Functions (TypeScript)
- **Payments:** Stripe Payment Sheet, with PaymentIntents created and
  verified server-side
- **Photos:** Cloudinary with server-signed uploads
- **Face matching:** on-device FaceNet embeddings (`face_verification`)

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): folder layout, the
  screen/controller/service pattern, flows, data model, how to add a screen
- [SECURITY.md](SECURITY.md): security review, fixes, remaining risks and
  the go-live checklist

## Project layout

```
lib/
  app/        root widget and routes
  config/     build configuration (Stripe publishable key, functions region)
  core/       theme, validators, error and state helpers
  data/       models and services (Firebase, Stripe, Cloudinary, face model)
  state/      app-wide controllers (auth, registration)
  features/   one folder per screen: *_screen.dart + *_controller.dart + widgets/
  shared/     design-system widgets and the shared camera
functions/        Cloud Functions: payments, queue tokens, card issuance, upload signing
firestore.rules   what the app may read and write
firestore-tests/  rules tests (Firestore emulator)
test/             Flutter tests
```

## Getting started

### Prerequisites

- Flutter 3.41+ (Dart 3.11+)
- Node.js 22 and the Firebase CLI (`npm i -g firebase-tools`) for the backend
- A Firebase project on the **Blaze** plan (needed for Cloud Functions)
- Stripe and Cloudinary accounts

### 1. Run the app

```bash
flutter pub get
cp lib/config/stripe_config.local.dart.example lib/config/stripe_config.local.dart
# put your Stripe publishable key (pk_...) in that file. Never a secret key.
flutter run
```

Firebase is configured by `lib/firebase_options.dart`,
`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.
For Google Sign-In on Android, add your debug SHA-1 to the Android app in
the Firebase console.

#### Running on an emulator

The app bundles ML Kit and a 94 MB face model, so a small emulator is slow.
For the "Medium Phone" AVD, open Device Manager → Edit → Advanced Settings,
give it at least 4 CPU cores and 4 GB RAM, and cold boot it. `flutter run`
builds in debug mode; use `flutter run --profile` to judge real speed, and
a real phone to test the camera and face check.

### 2. Deploy the backend

The app relies on the Cloud Functions for payment, queue tokens, card
issuance and photo uploads.

```bash
cd functions && npm install && cd ..

# Secrets live in Google Secret Manager, never in the app.
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set CLOUDINARY_API_SECRET

# Non-secret Cloudinary settings
cp functions/.env.example functions/.env.mtag-41516   # fill in the values

firebase deploy --only functions,firestore:rules
```

The registration fee is set in `functions/src/config.ts` (charged) and
`lib/config/stripe_config.dart` (displayed); keep them in sync. Stripe test
card: `4242 4242 4242 4242`, any future expiry, any CVC.

### 3. Release builds (Android)

Create an upload keystore and `android/key.properties` as described in
`android/key.properties.example`. Without it, release builds are signed with
the debug key and must not be published.

## Tests

```bash
flutter analyze && flutter test                  # app: models, controllers, screens
cd functions && npm test                         # Cloud Functions helpers
cd firestore-tests && npm install && npm test    # Firestore rules (emulator, needs Java)
```
