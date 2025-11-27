# 📁 Notes Sharing App - Folder Structure

> **Complete folder structure and organization principles**

---

## 📂 Complete Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config (generated)
│
├── app/                               # Application-level code
│   ├── app.dart                       # MaterialApp configuration
│   ├── router/
│   │   ├── app_router.dart           # GoRouter configuration
│   │   ├── router_provider.dart      # Riverpod router provider
│   │   └── route_guards.dart         # Auth guards
│   └── theme/
│       ├── app_theme.dart            # Main theme manager
│       ├── color_schemes.dart        # Light/Dark color schemes
│       ├── text_theme.dart           # Typography (Google Fonts)
│       ├── spacing.dart              # Spacing constants
│       ├── radius.dart               # Border radius constants
│       └── elevation.dart            # Shadow/elevation constants
│
├── core/                              # Core utilities & shared code
│   ├── constants/
│   │   ├── app_constants.dart        # App-wide constants
│   │   ├── firebase_constants.dart   # Collection names, etc.
│   │   ├── cloudinary_constants.dart # Cloudinary config
│   │   └── asset_constants.dart      # Asset paths
│   ├── utils/
│   │   ├── validators.dart           # Form validators
│   │   ├── date_formatter.dart       # Date utilities
│   │   ├── logger.dart               # Logging utility
│   │   └── file_utils.dart           # File operations
│   ├── extensions/
│   │   ├── context_extensions.dart   # BuildContext extensions
│   │   ├── string_extensions.dart    # String utilities
│   │   ├── datetime_extensions.dart  # DateTime utilities
│   │   └── file_extensions.dart      # File type utilities
│   └── errors/
│       ├── failures.dart             # Failure classes
│       ├── exceptions.dart           # Custom exceptions
│       └── error_handler.dart       # Global error handler
│
├── shared/                            # Shared across features
│   ├── models/
│   │   ├── result.dart               # Result<T> for error handling
│   │   └── paginated_response.dart   # Pagination wrapper
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── icon_button.dart
│   │   ├── inputs/
│   │   │   ├── custom_text_field.dart
│   │   │   ├── password_field.dart
│   │   │   ├── search_field.dart
│   │   │   └── rich_text_editor.dart
│   │   ├── cards/
│   │   │   ├── note_card.dart
│   │   │   ├── shared_note_card.dart
│   │   │   └── stat_card.dart
│   │   ├── loaders/
│   │   │   ├── skeleton_loader.dart
│   │   │   ├── page_loader.dart
│   │   │   └── shimmer_card.dart
│   │   ├── dialogs/
│   │   │   ├── confirmation_dialog.dart
│   │   │   ├── error_dialog.dart
│   │   │   ├── share_dialog.dart
│   │   │   └── pdf_preview_dialog.dart
│   │   ├── layouts/
│   │   │   ├── responsive_layout.dart
│   │   │   └── grid_layout.dart
│   │   └── common/
│   │       ├── app_bar.dart
│   │       ├── bottom_nav.dart
│   │       ├── empty_state.dart
│   │       ├── error_widget.dart
│   │       └── search_bar.dart
│   └── providers/
│       ├── theme_provider.dart       # Theme mode provider
│       └── connectivity_provider.dart # Network status
│
├── features/                          # Feature modules
│   │
│   ├── auth/                          # Authentication
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── auth_provider.dart
│   │       │   └── auth_state_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── signup_screen.dart
│   │       │   ├── forgot_password_screen.dart
│   │       │   └── email_verification_screen.dart
│   │       └── widgets/
│   │           ├── auth_text_field.dart
│   │           └── auth_button.dart
│   │
│   ├── onboarding/                    # First-time user flow
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── onboarding_screen.dart
│   │       └── widgets/
│   │           └── onboarding_page.dart
│   │
│   ├── home/                          # Home dashboard
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── dashboard_stats.dart
│   │   │   └── repositories/
│   │   │       └── dashboard_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dashboard_provider.dart
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       └── widgets/
│   │           ├── stats_grid.dart
│   │           ├── stat_card.dart
│   │           ├── recent_notes_section.dart
│   │           ├── shared_notes_section.dart
│   │           └── quick_actions.dart
│   │
│   ├── notes/                         # Notes management
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── note_model.dart
│   │   │   └── repositories/
│   │   │       └── note_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── notes_provider.dart
│   │       │   ├── note_detail_provider.dart
│   │       │   ├── note_form_provider.dart
│   │       │   └── notes_filter_provider.dart
│   │       ├── screens/
│   │       │   ├── notes_screen.dart
│   │       │   ├── note_detail_screen.dart
│   │       │   ├── create_note_screen.dart
│   │       │   └── edit_note_screen.dart
│   │       └── widgets/
│   │           ├── note_card.dart
│   │           ├── note_list_item.dart
│   │           ├── note_filter_bar.dart
│   │           ├── note_search_bar.dart
│   │           ├── category_chip.dart
│   │           └── note_actions_menu.dart
│   │
│   ├── pdf/                           # PDF generation
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── pdf_service.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── pdf_provider.dart
│   │       ├── screens/
│   │       │   ├── pdf_generator_screen.dart
│   │       │   └── pdf_preview_screen.dart
│   │       └── widgets/
│   │           ├── pdf_options_picker.dart
│   │           ├── image_picker_grid.dart
│   │           └── pdf_preview_widget.dart
│   │
│   ├── sharing/                       # Note sharing
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── shared_note_model.dart
│   │   │   └── repositories/
│   │   │       └── sharing_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── sharing_provider.dart
│   │       ├── screens/
│   │       │   ├── share_note_screen.dart
│   │       │   └── shared_notes_screen.dart
│   │       └── widgets/
│   │           ├── user_search_field.dart
│   │           ├── shared_user_list.dart
│   │           └── permission_badge.dart
│   │
│   ├── messaging/                     # In-app messaging
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── message_model.dart
│   │   │   └── repositories/
│   │   │       └── messaging_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── messages_provider.dart
│   │       │   └── chat_provider.dart
│   │       ├── screens/
│   │       │   ├── messages_screen.dart
│   │       │   └── chat_screen.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           ├── message_input.dart
│   │           ├── chat_header.dart
│   │           └── unread_badge.dart
│   │
│   ├── search/                        # Search functionality
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── search_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── search_provider.dart
│   │       ├── screens/
│   │       │   └── search_screen.dart
│   │       └── widgets/
│   │           ├── search_results_list.dart
│   │           ├── search_filter_chips.dart
│   │           └── search_history.dart
│   │
│   └── profile/                       # User profile
│       ├── data/
│       │   └── repositories/
│       │       └── profile_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── profile_provider.dart
│           ├── screens/
│           │   ├── profile_screen.dart
│           │   ├── edit_profile_screen.dart
│           │   └── settings_screen.dart
│           └── widgets/
│               ├── profile_header.dart
│               └── settings_tile.dart
│
└── services/                          # Global services (singletons)
    ├── firebase_service.dart         # Firebase initialization
    ├── cloudinary_service.dart       # Cloudinary integration
    ├── notification_service.dart     # FCM & local notifications
    ├── pdf_service.dart              # PDF generation service
    └── analytics_service.dart        # Firebase Analytics
```

---

## 📋 Folder Organization Principles

### 1. Feature-First Structure

**Why?**

- ✅ Easy to locate feature-related code
- ✅ Scalable - add features without touching existing code
- ✅ Clear boundaries between features
- ✅ Team-friendly - different developers can work on different features

**How?**

- Each feature has its own folder under `features/`
- Each feature contains its own data and presentation layers
- Shared code goes in `shared/` directory

### 2. Layer Separation

**Within Each Feature:**

```
feature_name/
├── data/           # Data layer (repositories, models)
└── presentation/   # Presentation layer (screens, widgets, providers)
```

**Why Separate?**

- ✅ Testable - can test data layer independently
- ✅ Swappable - can change data source without touching UI
- ✅ Clean - clear separation of concerns

### 3. Naming Conventions

**Files:**

- `snake_case.dart` for all files
- Descriptive names: `note_detail_screen.dart` not `detail.dart`
- Suffix by type: `_screen.dart`, `_widget.dart`, `_provider.dart`, `_model.dart`

**Folders:**

- `snake_case` for folders
- Plural for collections: `widgets/`, `screens/`, `providers/`
- Singular for specific: `auth/`, `home/`, `notes/`

### 4. Shared vs Feature-Specific

**Shared (`shared/`):**

- Used by multiple features
- Generic, reusable components
- Common utilities
- App-wide widgets

**Feature-Specific (`features/`):**

- Used only within one feature
- Feature-specific logic
- Feature-specific widgets

---

## 📁 Key Directories Explained

### `app/`

Application-level configuration that affects the entire app:

- Theme configuration
- Router setup
- App initialization

### `core/`

Core utilities and infrastructure:

- Constants
- Extensions
- Error handling
- Validators
- Logging

### `shared/`

Reusable components and models:

- Common widgets
- Shared models
- Common providers

### `features/`

Feature modules (business logic):

- Each feature is self-contained
- Has its own data and presentation layers
- Can be developed independently

### `services/`

Global singleton services:

- Firebase initialization
- Cloudinary service
- Notification service
- PDF service

---

## 🎯 File Organization Best Practices

### 1. One Class Per File

```dart
// ✅ Good
// note_model.dart
class NoteModel { ... }

// ❌ Bad
// models.dart
class NoteModel { ... }
class UserModel { ... }
```

### 2. Group Related Files

```
notes/
├── data/
│   ├── models/
│   │   └── note_model.dart
│   └── repositories/
│       └── note_repository.dart
```

### 3. Use Barrel Files (Optional)

```dart
// notes/notes.dart
export 'data/models/note_model.dart';
export 'data/repositories/note_repository.dart';
export 'presentation/screens/notes_screen.dart';
```

### 4. Keep Files Focused

- One responsibility per file
- If a file gets too long (>300 lines), consider splitting
- Group related functionality

---

## 📦 Asset Organization

```
assets/
├── images/
│   ├── logos/
│   ├── illustrations/
│   └── placeholders/
├── icons/
│   ├── app_icon.png
│   └── ...
├── animations/
│   └── lottie/
└── fonts/
    └── (if custom fonts)
```

---

## 🔧 Generated Files

These files are auto-generated and should not be edited manually:

- `*.g.dart` - Code generation (Riverpod, JSON)
- `*.freezed.dart` - Freezed models
- `firebase_options.dart` - Firebase configuration

**Location:**

- Generated files stay next to their source files
- Use `.gitignore` to exclude if needed (but usually commit them)

---

## 📝 Import Organization

### Import Order

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. App imports (absolute paths)
import 'package:notes_sharing_app/core/constants/app_constants.dart';
import 'package:notes_sharing_app/features/notes/data/models/note_model.dart';

// 5. Relative imports (within same feature)
import '../widgets/note_card.dart';
```

### Import Rules

- ✅ Use absolute imports for cross-feature imports
- ✅ Use relative imports within the same feature
- ✅ Group imports as shown above
- ✅ Remove unused imports

---

## 🎨 Widget Organization

### Widget File Structure

```dart
// 1. Imports
import 'package:flutter/material.dart';
// ...

// 2. Main widget class
class NoteCard extends StatelessWidget {
  // Constructor
  // Properties
  // Build method
}

// 3. Helper widgets (private)
class _NoteCardHeader extends StatelessWidget { ... }
```

### Widget Naming

- Public widgets: `PascalCase` (NoteCard)
- Private widgets: `_PascalCase` (\_NoteCardHeader)
- Constants: `lowerCamelCase` (defaultPadding)

---

## ✅ Checklist for New Features

When adding a new feature:

- [ ] Create feature folder under `features/`
- [ ] Add `data/` and `presentation/` subfolders
- [ ] Create models in `data/models/`
- [ ] Create repository in `data/repositories/`
- [ ] Create providers in `presentation/providers/`
- [ ] Create screens in `presentation/screens/`
- [ ] Create widgets in `presentation/widgets/`
- [ ] Add routes in `app/router/app_router.dart`
- [ ] Update navigation if needed
- [ ] Add feature-specific constants if needed

---

## 🚀 Quick Reference

### Common Paths

- **Screens:** `features/{feature}/presentation/screens/`
- **Widgets:** `features/{feature}/presentation/widgets/`
- **Providers:** `features/{feature}/presentation/providers/`
- **Models:** `features/{feature}/data/models/`
- **Repositories:** `features/{feature}/data/repositories/`
- **Shared Widgets:** `shared/widgets/`
- **Constants:** `core/constants/`
- **Services:** `services/`

### File Naming Examples

- Screen: `notes_screen.dart`
- Widget: `note_card.dart`
- Provider: `notes_provider.dart`
- Model: `note_model.dart`
- Repository: `note_repository.dart`
- Service: `pdf_service.dart`

---

This folder structure ensures:

- ✅ Scalability
- ✅ Maintainability
- ✅ Testability
- ✅ Team collaboration
- ✅ Code organization

Follow this structure consistently throughout development! 🎯
