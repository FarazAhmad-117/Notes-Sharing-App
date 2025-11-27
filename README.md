# 📝 Notes Sharing App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A modern, collaborative notes sharing application built with Flutter**

[Features](#-features) • [Screenshots](#-screenshots) • [Demo](#-demo) • [Download](#-download) • [Architecture](#-architecture) • [Getting Started](#-getting-started)

</div>

---

## 📖 About

**Notes Sharing App** is a feature-rich, modern mobile application that allows users to create, manage, and share notes seamlessly. Built with Flutter and powered by Firebase, it provides a smooth, real-time collaborative experience for note-taking and sharing.

### ✨ Key Highlights

- 🎨 **Beautiful UI/UX** - Material Design 3 with smooth animations
- 🔄 **Real-time Sync** - Instant updates across all devices
- 📄 **PDF Generation** - Convert text and images to PDF documents
- 🔗 **Easy Sharing** - Share notes with friends and colleagues
- 💬 **In-App Messaging** - Communicate about shared notes
- 🔍 **Smart Search** - Advanced search and filtering capabilities
- 🔔 **Push Notifications** - Stay updated with real-time notifications
- ☁️ **Cloud Storage** - Secure cloud storage with Cloudinary

---

## 🎯 Features

### Core Features

- ✅ **User Authentication**

  - Email/Password signup and login
  - Email verification
  - Password reset functionality
  - Secure session management

- ✅ **Note Management**

  - Create, edit, and delete notes
  - Rich text editing
  - Image attachments
  - Category and tag organization
  - Pin and archive notes
  - Color-coded notes

- ✅ **PDF Generation**

  - Convert text to PDF
  - Convert images to PDF
  - Combine text and images
  - Preview and download PDFs

- ✅ **Sharing & Collaboration**

  - Share notes with specific users
  - View and edit permissions
  - Real-time updates on shared notes
  - Track shared notes activity

- ✅ **Search & Filter**

  - Full-text search in notes
  - Filter by category, tags, or date
  - Filter shared vs. own notes
  - Sort by various criteria

- ✅ **Messaging**

  - In-app real-time messaging
  - Chat about shared notes
  - Message notifications
  - Unread message indicators

- ✅ **Dashboard**

  - Statistics overview
  - Recent notes preview
  - Quick actions
  - Activity feed

- ✅ **Notifications**
  - Push notifications (FCM)
  - In-app notifications
  - Notification history
  - Customizable notification settings

---

## 📸 Screenshots

<div align="center">

### Coming Soon! 🚀

_Screenshots will be added here once the app is ready_

<!--
### Screenshot Gallery

| Login Screen | Home Dashboard | Notes List |
|:------------:|:--------------:|:----------:|
| ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Notes](screenshots/notes.png) |

| Note Detail | PDF Generator | Sharing |
|:-----------:|:-------------:|:-------:|
| ![Detail](screenshots/note_detail.png) | ![PDF](screenshots/pdf.png) | ![Share](screenshots/share.png) |

| Messages | Search | Profile |
|:--------:|:------:|:------:|
| ![Messages](screenshots/messages.png) | ![Search](screenshots/search.png) | ![Profile](screenshots/profile.png) |
-->

</div>

---

## 🎥 Demo

<div align="center">

### Video Walkthrough

**Coming Soon!** A Loom video demonstrating the app's features will be embedded here.

<!--
[![Watch the demo](https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://www.loom.com/share/VIDEO_ID)

**Or watch directly on Loom:** [Click here to watch the demo](https://www.loom.com/share/VIDEO_ID)
-->

</div>

---

## 📥 Download

<div align="center">

### Get the App

**APK Download will be available here soon!**

<!--
### Latest Release

[![Download APK](https://img.shields.io/badge/Download-APK-brightgreen?style=for-the-badge&logo=android)](https://github.com/yourusername/notes_sharing_app/releases/latest/download/app-release.apk)

**Version:** 1.0.0
**Size:** ~25 MB
**Minimum Android Version:** Android 6.0 (API 23)

### Installation

1. Download the APK file from the link above
2. Enable "Install from Unknown Sources" in your device settings
3. Open the downloaded APK file
4. Tap "Install" and follow the on-screen instructions

**Note:** The app is currently available for Android only. iOS version coming soon!
-->

</div>

---

## 🏗️ Architecture

This project follows **Feature-First Clean Architecture** principles with modern Flutter best practices.

### Architecture Highlights

- 🏛️ **Clean Architecture** - Separation of concerns with clear layers
- 📁 **Feature-First Structure** - Organized by features, not by type
- 🔄 **Riverpod State Management** - Type-safe state management with code generation
- 🗺️ **GoRouter Navigation** - Declarative routing with deep linking
- 🔥 **Firebase Backend** - Authentication, Firestore, and Cloud Messaging
- ☁️ **Cloudinary Integration** - Image and file storage
- 📄 **PDF Generation** - Text and image to PDF conversion

### Documentation

Comprehensive architecture documentation is available in the [`architecture/`](architecture/) directory:

- 📋 [Architecture Overview](architecture/Architecture-Overview.md)
- 📁 [Folder Structure](architecture/Architecture-Folder-Structure.md)
- 🔥 [Firebase Setup](architecture/Architecture-Firebase.md)
- 🎨 [Features & Screens](architecture/Architecture-Features.md)
- 🔄 [State Management](architecture/Architecture-State-Management.md)
- 🗺️ [Navigation](architecture/Architecture-Navigation.md)
- 🎨 [Design System](architecture/Architecture-Design-System.md)
- 📊 [Data Models](architecture/Architecture-Data-Models.md)
- ⚙️ [Services](architecture/Architecture-Services.md)

---

## 🛠️ Tech Stack

### Frontend

- **Flutter** 3.10+ - UI Framework
- **Dart** 3.0+ - Programming Language
- **Material Design 3** - Design System

### State Management

- **Riverpod** 2.x - State management with code generation
- **flutter_hooks** - Widget lifecycle management

### Backend & Services

- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Cloud Messaging** - Push notifications
- **Cloudinary** - Image and file storage

### Navigation & Routing

- **GoRouter** - Declarative routing

### Utilities

- **Freezed** - Immutable models
- **json_serializable** - JSON serialization
- **pdf** - PDF generation
- **image_picker** - Image selection
- **Google Fonts** - Typography

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase project setup
- Cloudinary account

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/notes_sharing_app.git
   cd notes_sharing_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Setup Firebase**

   - Create a Firebase project
   - Add Android/iOS apps to Firebase
   - Download configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Run `flutterfire configure`

4. **Setup Cloudinary**

   - Create a Cloudinary account
   - Get your cloud name, API key, and API secret
   - Update `core/constants/cloudinary_constants.dart`

5. **Generate code**

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── app/                    # App-level configuration
│   ├── router/            # Navigation setup
│   └── theme/             # Theme configuration
├── core/                   # Core utilities
│   ├── constants/         # App constants
│   ├── utils/             # Utility functions
│   └── extensions/        # Extension methods
├── shared/                 # Shared components
│   ├── widgets/           # Reusable widgets
│   └── models/            # Shared models
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── home/              # Dashboard
│   ├── notes/             # Notes management
│   ├── pdf/               # PDF generation
│   ├── sharing/           # Note sharing
│   ├── messaging/         # In-app messaging
│   ├── search/            # Search functionality
│   └── profile/           # User profile
└── services/              # Global services
    ├── firebase_service.dart
    ├── cloudinary_service.dart
    ├── pdf_service.dart
    └── notification_service.dart
```

---

## 📱 Platform Support

|  Platform  |       Status       |
| :--------: | :----------------: |
| 🤖 Android | ✅ Fully Supported |
|   🍎 iOS   |    ✅ Supported    |
|   🌐 Web   |   🔜 Coming Soon   |
| 🪟 Windows |   🔜 Coming Soon   |
|  🐧 Linux  |   🔜 Coming Soon   |
|  🖥️ macOS  |   🔜 Coming Soon   |

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**

- GitHub: [@FarazAhmad-117](https://github.com/FarazAhmad-117)
- Email: farazahmad31048@gmail.com
- LinkedIn: [Faraz Ahmad](https://linkedin.com/in/faraz_ahmad_dev)

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - Amazing UI framework
- [Firebase](https://firebase.google.com/) - Backend infrastructure
- [Cloudinary](https://cloudinary.com/) - Media management
- [Riverpod](https://riverpod.dev/) - State management
- [Material Design](https://m3.material.io/) - Design system

---

## 📊 Project Status

<div align="center">

![Progress](https://img.shields.io/badge/Status-In%20Development-yellow?style=for-the-badge)

**Current Version:** 1.0.0 (Development)  
**Last Updated:** November 2025

</div>

---

<div align="center">

### ⭐ Star this repo if you find it helpful!

Made with ❤️ using Flutter

[⬆ Back to Top](#-notes-sharing-app)

</div>
