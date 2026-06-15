# Mosaic

A dating app built on accountability. Users can block — but if they don't give a reason, it shows on their profile. Verified users and profiles with photos surface first.

## Stack

- **iOS 17+** · SwiftUI
- **Firebase** — Auth, Firestore, Storage
- **Swift Package Manager** for dependencies

## Xcode Setup

### 1. Firebase
1. Go to [Firebase Console](https://console.firebase.google.com) → New project: **Mosaic**
2. Add iOS app with bundle ID `com.yourname.mosaic`
3. Enable **Authentication → Email/Password**, **Firestore**, **Storage**
4. Download `GoogleService-Info.plist` and replace the placeholder in this folder

### 2. Xcode Project
1. Xcode → **File → New → Project → iOS App**
2. Product Name: `Mosaic`, Interface: SwiftUI, Language: Swift
3. Add Firebase via **File → Add Package Dependencies**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Select: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseFirestoreSwift`, `FirebaseStorage`, `FirebaseMessaging`
4. Drag the `Sources/Mosaic/` folder contents into your Xcode project (check **Copy items if needed**)
5. Drag `GoogleService-Info.plist` into the project root (check **Add to target**)

### 3. Firestore Security Rules

Paste these into Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /blocks/{blockId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == request.resource.data.blockerId;
    }
    match /conversations/{convId} {
      allow read, write: if request.auth.uid in resource.data.participantIds;
      match /messages/{msgId} {
        allow read, write: if request.auth.uid in
          get(/databases/$(database)/documents/conversations/$(convId)).data.participantIds;
      }
    }
  }
}
```

## Project Structure

```
Sources/Mosaic/
├── MosaicApp.swift          Entry point
├── ContentView.swift        Auth gate → MainTabView
├── Models/                  Data structs (Codable + Firestore)
├── ViewModels/              ObservableObject per feature
├── Views/
│   ├── Auth/                Login + SignUp
│   ├── Discovery/           Grindr-style photo grid
│   ├── Profile/             View + edit profiles
│   ├── Blocking/            Reason picker sheet + flag badge
│   ├── Messaging/           Conversations list + real-time chat
│   └── Shared/              Design system, tab bar, loading
└── Services/                Firebase wrappers
```

## MVP Features

- Email sign-up / sign-in
- Profile creation (name, age, bio, photos)
- Discovery grid — verified + photo users sorted to the top
- Pull-to-refresh on grid
- Block with predefined reason picker; no-reason blocks add a visible flag
- Real-time messaging

## What's Stubbed / Deferred

| Feature | Status |
|---|---|
| Liveness verification (AI) | UI stub — alert shown, no camera yet |
| AdMob banners | Placeholder tiles every 5 grid rows |
| Location-based sorting | `location` GeoPoint field stored, not queried |
| Safety-concern block reason | Omitted — legal review needed |
| Android | iOS first |
