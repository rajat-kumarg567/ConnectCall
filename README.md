# ConnectCall

*Connect with anyone, anywhere.*

## 1. Project description

ConnectCall is a 1-to-1 audio/video calling app built in Flutter, developed
as a Flutter Development Intern assignment. It lets users create an account,
see a list of other registered users with their online/offline status, and
place or receive real-time audio and video calls — with the usual controls
(mute, camera on/off, switch camera, end call) and a call history log.

The whole stack runs on free tiers: Firebase (Spark plan) for
authentication and data, and ZEGOCLOUD's Call UIKit (10,000 free
minutes/month) for the actual audio/video.

## 2. Features

- Splash screen with app branding, routes to Login or Home based on auth state
- Email/password Login and Registration (Firebase Authentication)
- Home screen: greeting, search, and a live contacts list
- Contacts screen: profile picture/initials avatar, name, online/offline
  status, audio-call and video-call buttons per user
- Real-time 1-to-1 audio calls: mute/unmute, speaker toggle, end call
- Real-time 1-to-1 video calls: mute/unmute, camera on/off, switch
  front/rear camera, end call
- Incoming call screen with Accept/Decline (provided by ZEGOCLOUD's UIKit)
- Call history: caller/callee name, date/time, call type (audio/video),
  incoming/outgoing direction, duration, and a missed/declined/busy
  indicator in place of duration when the call wasn't completed
- Profile screen: view and edit name, logout
- Runtime permission handling for microphone and camera, with user-facing
  messages if permission is denied
- Bold, gradient-based UI theme (violet → pink primary, cyan accent)

## 3. Flutter version

Developed and tested on Flutter's current **stable channel** (Flutter
3.24+ / Dart 3.5+). Check your own version with `flutter --version` — if
you're on an older Dart SDK (below 3.5.0), run `flutter upgrade` first, as
several of the packages below require it.

## 4. Packages used

| Package | Purpose |
|---|---|
| `provider` | App-wide state management (auth state, calling service) |
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Backend: authentication, user list, call history |
| `zego_uikit_prebuilt_call`, `zego_uikit_signaling_plugin` | Real-time audio/video calling + built-in ringing/accept/reject UI |
| `permission_handler` | Requesting microphone/camera permissions at runtime |
| `intl` | Formatting call history timestamps |
| `connectivity_plus` | Network status awareness |
| `shared_preferences` | Lightweight local storage |
| `cupertino_icons` | iOS-style icons |

Exact versions are pinned in `pubspec.yaml`.

## 5. Architecture

```
lib/
├── core/
│   ├── constants/app_constants.dart   # ZEGOCLOUD AppID/AppSign, collection names
│   └── theme/app_theme.dart           # Colors, gradients, ThemeData
├── models/
│   ├── user_model.dart
│   └── call_model.dart
├── services/
│   ├── auth_service.dart              # Firebase Auth (login/register/logout)
│   ├── user_service.dart              # Firestore user list/search/profile
│   └── calling_service.dart           # ZEGOCLOUD call-invitation service + Firestore call history
├── screens/
│   ├── splash/  auth/  home/  contacts/  profile/  history/
└── widgets/
    ├── user_tile.dart
    └── common_button.dart
```

- **State management: Provider.** `AuthService` is a `ChangeNotifier`;
  `CallingService` is a plain injected singleton (it doesn't need to notify
  listeners — the calling UI itself is owned by ZEGOCLOUD). Both are
  provided at the app root via `MultiProvider` and read with
  `context.read`/`context.watch` in the screens that need them. Chosen for
  simplicity and because it's straightforward to explain and reason about.
- **Business logic lives in `services/`, not in widgets.** Screens call
  methods on `AuthService`, `UserService`, and `CallingService` and render
  based on their streams/futures; the services own all Firebase and
  ZEGOCLOUD interaction.
- **Data flows one way:** Firestore streams → services → `StreamBuilder`s in
  the UI. Writes (register, login, start a call, update profile) go through
  the same services, so there's a single place each concern is handled.

## 6. Backend used

**Firebase** (Spark / no-cost plan):
- **Firebase Authentication** — email/password sign-in and sign-up.
- **Cloud Firestore** — two collections:
    - `users`: profile (name, email, photo URL, online status, last seen)
    - `calls`: one record per call (caller, callee, type, status, timestamps,
      duration) — this is what powers the Call History screen, since
      ZEGOCLOUD doesn't store call history for you.

## 7. Calling SDK used

**ZEGOCLOUD's Call UIKit** (`zego_uikit_prebuilt_call` +
`zego_uikit_signaling_plugin`), chosen because:
- Free tier covers 10,000 minutes/month with no card required.
- Its prebuilt invitation service ships the entire calling experience —
  ringing, incoming-call accept/reject, mute, camera on/off, switch camera,
  end call — out of the box, so the app doesn't need hand-built call
  screens or its own signaling server.
- `CallingService.init()` registers the current user with ZEGOCLOUD right
  after login/registration (and on app restart if already signed in), so
  incoming calls can reach them from anywhere in the app.
- Call history isn't provided by ZEGOCLOUD, so `CallingService` writes a
  "calling" record to Firestore the moment a call is placed, then updates
  that same record to `ended`/`missed`/`rejected`/`busy` via ZEGOCLOUD's
  event callbacks (`onCallEnd`, `onOutgoingCallDeclined`,
  `onOutgoingCallRejectedCauseBusy`, `onOutgoingCallTimeout`).

(Agora, Stream Video, LiveKit, or a raw WebRTC + custom signaling server
were the alternatives considered — all viable, but would need either more
manual call-screen/signaling code or a different pricing model.)

## 8. Setup instructions

### Prerequisites (all free)
- Flutter SDK 3.24+ with Android Studio (Flutter/Dart plugins installed)
- An Android phone or emulator (two devices needed to test calling)
- A free [Firebase](https://console.firebase.google.com) account
- A free [ZEGOCLOUD](https://console.zegocloud.com) account

### Steps
1. **Scaffold platform folders** (this project ships only `lib/` +
   `pubspec.yaml`):
   ```bash
   flutter create . --project-name connectcall --org com.example
   flutter pub get
   ```
2. **Firebase**: create a project → enable **Authentication → Email/Password**
   → enable **Cloud Firestore** (Standard edition, test mode). Install the
   FlutterFire CLI and connect the app:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Then uncomment the two `firebase_options.dart` lines in `lib/main.dart`.
3. **ZEGOCLOUD**: sign up → create a project (Video Call → "Start with
   UIKits" → For Flutter) → copy its **AppID** and **AppSign** into
   `lib/core/constants/app_constants.dart` (see section 9 below).
4. **Android permissions**: add to
   `android/app/src/main/AndroidManifest.xml`:
   ```xml
  / <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
/
   ```
   and set `minSdkVersion 24` in `android/app/build.gradle`.
5. **Run it**:
   ```bash
   flutter run
   ```
   Register two accounts (two devices, or one device + emulator) to test
   calling between them.
6. **Build the release APK for submission**:
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

## 9. Environment variables / configuration

This project doesn't use `.env` files — the two pieces of config it needs
are set directly in code (fine for an assignment; a production app would
fetch these from a server instead):

- **`lib/core/constants/app_constants.dart`**
  ```dart
  static const int zegoAppID = 0;              // your ZEGOCLOUD AppID
  static const String zegoAppSign = '';         // your ZEGOCLOUD AppSign
  ```
- **`lib/firebase_options.dart`** — generated automatically by
  `flutterfire configure` (step 8.2); not committed if you're using a
  public repo, since it contains your Firebase project's client config.

**Firestore security rules** (tighten before submitting/sharing publicly —
test mode is open to any authenticated-or-not client for 30 days):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /calls/{callId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 10. Known limitations

- Incoming calls ring while the app is open (foreground or backgrounded but
  not killed). Waking the app from a fully-killed state needs offline push
  notifications wired through an FCM project in the ZEGOCLOUD console
  (covers the assignment's Push/Background-call bonus points) — left out
  here to keep the base setup simple.
- ZEGOCLOUD's AppID/AppSign are bundled directly in the client. For
  production you'd fetch a short-lived token from your own server instead.
- Search is a simple client-side filter over the contacts list — fine at
  small scale, would move to an indexed query if the user base grew.
- Group calling, screen sharing, call recording, network-quality indicator,
  and dark mode (bonus features) are not implemented.

## 11. AI tools used

Built with the help of **Claude** (Anthropic) — architecture decisions,
screen implementation, the Firebase ↔ ZEGOCLOUD integration, UI styling,
debugging build/dependency errors, and this README. All code was reviewed
and understood before submission.