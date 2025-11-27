# 🎨 Notes Sharing App - Design System

> **Complete design system: colors, typography, spacing, components, and theme**

---

## 📑 Table of Contents

1. [Design Principles](#design-principles)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing System](#spacing-system)
5. [Component Library](#component-library)
6. [Theme Configuration](#theme-configuration)
7. [Icons & Assets](#icons--assets)

---

## 🎯 Design Principles

### Material Design 3

We follow **Material Design 3** guidelines for:
- ✅ Consistent UI components
- ✅ Accessibility standards
- ✅ Responsive design
- ✅ Dark mode support
- ✅ Motion and animations

### Design Values

1. **Clarity** - Clear, readable interfaces
2. **Consistency** - Consistent patterns across the app
3. **Efficiency** - Quick access to common actions
4. **Beauty** - Modern, polished appearance
5. **Accessibility** - Usable by everyone

---

## 🎨 Color System

### Color Palette

#### Light Theme Colors

```dart
// app/theme/color_schemes.dart

// Primary Colors
static const Color primary = Color(0xFF6366F1);      // Indigo
static const Color primaryLight = Color(0xFF818CF8);
static const Color primaryDark = Color(0xFF4F46E5);

// Secondary Colors
static const Color secondary = Color(0xFF8B5CF6);    // Purple
static const Color secondaryLight = Color(0xFFA78BFA);
static const Color secondaryDark = Color(0xFF7C3AED);

// Accent Colors
static const Color accent = Color(0xFF06B6D4);      // Cyan
static const Color accentLight = Color(0xFF22D3EE);
static const Color accentDark = Color(0xFF0891B2);

// Semantic Colors
static const Color success = Color(0xFF10B981);      // Green
static const Color warning = Color(0xFFF59E0B);      // Amber
static const Color error = Color(0xFFEF4444);       // Red
static const Color info = Color(0xFF3B82F6);        // Blue

// Neutral Colors
static const Color background = Color(0xFFF8FAFC);  // Slate 50
static const Color surface = Color(0xFFFFFFFF);      // White
static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100

// Text Colors
static const Color textPrimary = Color(0xFF0F172A);  // Slate 900
static const Color textSecondary = Color(0xFF475569); // Slate 600
static const Color textTertiary = Color(0xFF94A3B8); // Slate 400

// Border Colors
static const Color border = Color(0xFFE2E8F0);       // Slate 200
static const Color divider = Color(0xFFCBD5E1);      // Slate 300
```

#### Dark Theme Colors

```dart
// Dark Theme
static const Color darkPrimary = Color(0xFF818CF8);     // Indigo Light
static const Color darkPrimaryDark = Color(0xFF6366F1);
static const Color darkPrimaryLight = Color(0xFFA5B4FC);

static const Color darkSecondary = Color(0xFFA78BFA);   // Purple Light
static const Color darkAccent = Color(0xFF22D3EE);      // Cyan Light

static const Color darkSuccess = Color(0xFF34D399);
static const Color darkWarning = Color(0xFFFBBF24);
static const Color darkError = Color(0xFFF87171);
static const Color darkInfo = Color(0xFF60A5FA);

static const Color darkBackground = Color(0xFF0F172A);  // Slate 900
static const Color darkSurface = Color(0xFF1E293B);      // Slate 800
static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700

static const Color darkTextPrimary = Color(0xFFF1F5F9);  // Slate 100
static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300
static const Color darkTextTertiary = Color(0xFF94A3B8);   // Slate 400

static const Color darkBorder = Color(0xFF334155);      // Slate 700
static const Color darkDivider = Color(0xFF475569);     // Slate 600
```

### Color Usage Guidelines

**Primary Color:**
- Main actions (buttons, links)
- Active states
- Brand elements

**Secondary Color:**
- Secondary actions
- Accent elements
- Highlights

**Error Color:**
- Error messages
- Destructive actions
- Validation errors

**Success Color:**
- Success messages
- Positive feedback
- Completed states

**Text Colors:**
- Primary: Main content
- Secondary: Supporting text
- Tertiary: Hints, placeholders

---

## 📝 Typography

### Font Families

```dart
// app/theme/text_theme.dart

// Primary Font: Inter (for body text)
// Headings Font: Poppins (for headings)
// Monospace Font: JetBrains Mono (for code/numbers)
```

### Type Scale

```dart
// Display (Large headings)
static const TextStyle displayLarge = TextStyle(
  fontSize: 57,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.25,
  height: 1.12,
);

static const TextStyle displayMedium = TextStyle(
  fontSize: 45,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
  height: 1.16,
);

static const TextStyle displaySmall = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
  height: 1.22,
);

// Headline (Section headings)
static const TextStyle headlineLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
  height: 1.25,
);

static const TextStyle headlineMedium = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
  height: 1.29,
);

static const TextStyle headlineSmall = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
  height: 1.33,
);

// Title (Card titles, list items)
static const TextStyle titleLarge = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w500,
  letterSpacing: 0,
  height: 1.27,
);

static const TextStyle titleMedium = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.15,
  height: 1.5,
);

static const TextStyle titleSmall = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.1,
  height: 1.43,
);

// Label (Buttons, form labels)
static const TextStyle labelLarge = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.1,
  height: 1.43,
);

static const TextStyle labelMedium = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
  height: 1.33,
);

static const TextStyle labelSmall = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
  height: 1.45,
);

// Body (Main content)
static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.5,
  height: 1.5,
);

static const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.25,
  height: 1.43,
);

static const TextStyle bodySmall = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.4,
  height: 1.33,
);
```

### Typography Usage

**Headings:**
- Use for section titles
- Screen titles
- Card headers

**Body:**
- Main content text
- Descriptions
- Paragraphs

**Label:**
- Button text
- Form labels
- Navigation items

**Caption:**
- Metadata
- Timestamps
- Hints

---

## 📏 Spacing System

### Spacing Scale

```dart
// app/theme/spacing.dart

class AppSpacing {
  // Base unit: 4px
  static const double xs = 4.0;    // 4px
  static const double sm = 8.0;     // 8px
  static const double md = 16.0;    // 16px
  static const double lg = 24.0;    // 24px
  static const double xl = 32.0;     // 32px
  static const double xxl = 48.0;    // 48px
  static const double xxxl = 64.0;  // 64px
}
```

### Spacing Usage

**XS (4px):**
- Tight spacing between related elements
- Icon padding

**SM (8px):**
- Small gaps
- Checkbox/radio spacing

**MD (16px):**
- Standard padding
- Card padding
- Section spacing

**LG (24px):**
- Large gaps
- Section margins
- Card margins

**XL (32px):**
- Screen margins
- Large section spacing

**XXL (48px):**
- Page margins
- Major section breaks

---

## 🎭 Border Radius

```dart
// app/theme/radius.dart

class AppRadius {
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0; // Circular
}
```

### Radius Usage

- **XS (4px):** Small badges, chips
- **SM (8px):** Buttons, input fields
- **MD (12px):** Cards, containers
- **LG (16px):** Large cards, modals
- **XL (24px):** Extra large containers
- **Full:** Circular avatars, pills

---

## 📦 Elevation & Shadows

```dart
// app/theme/elevation.dart

class AppElevation {
  static const double none = 0.0;
  static const double sm = 1.0;
  static const double md = 2.0;
  static const double lg = 4.0;
  static const double xl = 8.0;
  static const double xxl = 16.0;
}

// Shadow presets
class AppShadows {
  static List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
```

---

## 🧩 Component Library

### Buttons

#### Primary Button

```dart
// shared/widgets/buttons/primary_button.dart

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const PrimaryButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        elevation: AppElevation.none,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              text,
              style: Theme.of(context).textTheme.labelLarge,
            ),
    );
  }
}
```

#### Secondary Button

```dart
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const SecondaryButton({
    required this.text,
    this.onPressed,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
```

### Cards

#### Note Card

```dart
// shared/widgets/cards/note_card.dart

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  
  const NoteCard({
    required this.note,
    this.onTap,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (note.category != null)
                    CategoryChip(category: note.category!),
                  const Spacer(),
                  Text(
                    _formatDate(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Input Fields

#### Custom Text Field

```dart
// shared/widgets/inputs/custom_text_field.dart

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  
  const CustomTextField({
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
```

---

## 🎨 Theme Configuration

### Theme Setup

```dart
// app/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_schemes.dart';
import 'text_theme.dart';
import 'spacing.dart';
import 'radius.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorSchemes.primary,
        brightness: Brightness.light,
        primary: ColorSchemes.primary,
        secondary: ColorSchemes.secondary,
        error: ColorSchemes.error,
        surface: ColorSchemes.surface,
        background: ColorSchemes.background,
      ),
      textTheme: AppTextTheme.textTheme,
      scaffoldBackgroundColor: ColorSchemes.background,
      cardTheme: CardTheme(
        elevation: AppElevation.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppElevation.none,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorSchemes.darkPrimary,
        brightness: Brightness.dark,
        primary: ColorSchemes.darkPrimary,
        secondary: ColorSchemes.darkSecondary,
        error: ColorSchemes.darkError,
        surface: ColorSchemes.darkSurface,
        background: ColorSchemes.darkBackground,
      ),
      textTheme: AppTextTheme.textTheme,
      scaffoldBackgroundColor: ColorSchemes.darkBackground,
      // ... similar configuration for dark theme
    );
  }
}
```

### Text Theme Setup

```dart
// app/theme/text_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(/* ... */),
    displayMedium: GoogleFonts.poppins(/* ... */),
    displaySmall: GoogleFonts.poppins(/* ... */),
    headlineLarge: GoogleFonts.poppins(/* ... */),
    headlineMedium: GoogleFonts.poppins(/* ... */),
    headlineSmall: GoogleFonts.poppins(/* ... */),
    titleLarge: GoogleFonts.inter(/* ... */),
    titleMedium: GoogleFonts.inter(/* ... */),
    titleSmall: GoogleFonts.inter(/* ... */),
    bodyLarge: GoogleFonts.inter(/* ... */),
    bodyMedium: GoogleFonts.inter(/* ... */),
    bodySmall: GoogleFonts.inter(/* ... */),
    labelLarge: GoogleFonts.inter(/* ... */),
    labelMedium: GoogleFonts.inter(/* ... */),
    labelSmall: GoogleFonts.inter(/* ... */),
  );
}
```

---

## 🎯 Icons & Assets

### Icon Usage

```dart
// Use Material Icons
Icon(Icons.note)
Icon(Icons.share)
Icon(Icons.message)
Icon(Icons.person)

// Custom icons (if needed)
// Place in assets/icons/
```

### Asset Organization

```
assets/
├── images/
│   ├── logos/
│   │   └── app_logo.png
│   ├── illustrations/
│   │   ├── empty_notes.svg
│   │   └── onboarding_1.svg
│   └── placeholders/
│       └── note_placeholder.png
├── icons/
│   └── (custom icons if needed)
└── animations/
    └── lottie/
        ├── loading.json
        └── success.json
```

---

## ✅ Design System Checklist

### Colors
- [ ] Primary color defined
- [ ] Secondary color defined
- [ ] Error/Success colors defined
- [ ] Light theme colors complete
- [ ] Dark theme colors complete
- [ ] Text colors defined

### Typography
- [ ] Font families selected
- [ ] Type scale defined
- [ ] Text styles created
- [ ] Google Fonts integrated

### Spacing
- [ ] Spacing scale defined
- [ ] Consistent spacing used
- [ ] Padding/margin constants

### Components
- [ ] Buttons created
- [ ] Cards created
- [ ] Input fields created
- [ ] Dialogs created
- [ ] Loaders created

### Theme
- [ ] Light theme configured
- [ ] Dark theme configured
- [ ] Theme provider setup
- [ ] Theme switching works

---

This design system ensures:
- ✅ Visual consistency
- ✅ Accessibility
- ✅ Maintainability
- ✅ Scalability
- ✅ Professional appearance

Follow this design system for all UI components! 🎨

