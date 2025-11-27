# 🔥 Firebase Setup Guide

This guide will help you set up Firebase Authentication for the Notes Sharing App.

## Prerequisites

1. A Firebase account (create one at [firebase.google.com](https://firebase.google.com))
2. FlutterFire CLI installed

## Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name: `notes-sharing-app` (or your preferred name)
   - Enable Google Analytics (optional)
   - Complete the project creation

## Step 3: Add Apps to Firebase Project

### For Android:

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.notes_sharing_app`
   - (Check `android/app/build.gradle` for your actual package name)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### For iOS:

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.example.notesSharingApp`
   - (Check `ios/Runner/Info.plist` for your actual bundle ID)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

## Step 4: Configure FlutterFire

Run the FlutterFire CLI to automatically configure your project:

```bash
flutterfire configure
```

This command will:

- Detect your Firebase projects
- Let you select which project to use
- Automatically generate `lib/core/services/firebase_options.dart`
- Configure your apps for Firebase

**Note:** If you're prompted to select platforms, choose the ones you're developing for (Android, iOS, etc.)

## Step 5: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Email/Password**
3. Enable the first toggle (Email/Password)
4. Click **Save**

## Step 6: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (choose closest to your users)
5. Click **Enable**

## Step 7: Set Up Firestore Security Rules

Go to **Firestore Database** → **Rules** and add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Notes collection
    match /notes/{noteId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.isShared == true
      );
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Shared notes collection
    match /shared_notes/{sharedNoteId} {
      allow read: if request.auth != null && (
        resource.data.ownerId == request.auth.uid ||
        resource.data.sharedWithId == request.auth.uid
      );
      allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid;
      allow update: if request.auth != null && (
        resource.data.ownerId == request.auth.uid ||
        resource.data.sharedWithId == request.auth.uid
      );
    }

    // Messages collection
    match /messages/{messageId} {
      allow read: if request.auth != null && (
        resource.data.senderId == request.auth.uid ||
        resource.data.receiverId == request.auth.uid
      );
      allow create: if request.auth != null && request.resource.data.senderId == request.auth.uid;
      allow update: if request.auth != null && (
        resource.data.senderId == request.auth.uid ||
        resource.data.receiverId == request.auth.uid
      );
    }

    // Notifications collection
    match /notifications/{userId}/items/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Important:** These are test rules. For production, you'll need more restrictive rules.

## Step 8: Test the Setup

1. Run the app:

   ```bash
   flutter run
   ```

2. Try to sign up with a new email
3. Check Firebase Console → Authentication to see if the user was created
4. Check Firestore Database → users collection to see if user document was created

## Troubleshooting

### Error: "Firebase not configured"

- Make sure you've run `flutterfire configure`
- Check that `lib/core/services/firebase_options.dart` exists
- Verify `google-services.json` is in `android/app/`
- Verify `GoogleService-Info.plist` is in `ios/Runner/`

### Error: "Platform not configured"

- Run `flutterfire configure` again
- Make sure you selected the correct platforms

### Authentication not working

- Verify Email/Password is enabled in Firebase Console
- Check that Firestore is created and rules are set
- Check app logs for specific error messages

### Package name mismatch

- Update package name in `android/app/build.gradle`
- Or update package name in Firebase Console to match your app

## Next Steps

After Firebase is set up:

1. ✅ Authentication is ready to use
2. 🔄 Next: Set up Firestore data repositories
3. 🔄 Next: Set up Firebase Cloud Messaging for push notifications
4. 🔄 Next: Set up Cloudinary for image/file storage

## Support

If you encounter issues:

1. Check Firebase Console for error logs
2. Check Flutter logs: `flutter run -v`
3. Verify all configuration files are in place
4. Ensure Firebase services are enabled in Firebase Console
