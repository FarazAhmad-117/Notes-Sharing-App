# 🎨 Notes Sharing App - Features & Screens

> **Complete feature breakdown, screen specifications, and user flows**

---

## 📑 Table of Contents

1. [Feature Overview](#feature-overview)
2. [Authentication Feature](#authentication-feature)
3. [Home/Dashboard Feature](#homedashboard-feature)
4. [Notes Management Feature](#notes-management-feature)
5. [PDF Generation Feature](#pdf-generation-feature)
6. [Sharing Feature](#sharing-feature)
7. [Messaging Feature](#messaging-feature)
8. [Search Feature](#search-feature)
9. [Profile Feature](#profile-feature)

---

## 🎯 Feature Overview

### Feature List

1. **Authentication** - Login, Signup, Password Reset
2. **Home/Dashboard** - Overview, stats, quick actions
3. **Notes Management** - Create, edit, delete, view notes
4. **PDF Generation** - Text/Image to PDF conversion
5. **Sharing** - Share notes with other users
6. **Messaging** - In-app chat for shared notes
7. **Search** - Search and filter notes
8. **Profile** - User profile and settings

---

## 🔐 Authentication Feature

### Screens

#### 1. **Login Screen** (`login_screen.dart`)

**Purpose:** User authentication

**UI Elements:**

- App logo/branding
- Email text field
- Password text field (with show/hide toggle)
- "Forgot Password?" link
- "Login" button
- "Don't have an account? Sign up" link

**User Flow:**

1. User enters email and password
2. Tap "Login" button
3. Show loading indicator
4. On success: Navigate to home
5. On error: Show error message

**Validation:**

- Email format validation
- Password not empty
- Minimum password length (6 characters)

**State Management:**

- `auth_provider.dart` - Handles login logic

---

#### 2. **Signup Screen** (`signup_screen.dart`)

**Purpose:** New user registration

**UI Elements:**

- App logo/branding
- Display name text field
- Email text field
- Password text field (with show/hide toggle)
- Confirm password text field
- "Sign up" button
- "Already have an account? Login" link
- Terms and conditions checkbox

**User Flow:**

1. User enters details
2. Tap "Sign up" button
3. Show loading indicator
4. Create Firebase Auth account
5. Create user document in Firestore
6. Send verification email
7. Navigate to email verification screen

**Validation:**

- Display name not empty
- Email format validation
- Password strength (min 6 characters)
- Password confirmation match
- Terms accepted

**State Management:**

- `auth_provider.dart` - Handles signup logic

---

#### 3. **Forgot Password Screen** (`forgot_password_screen.dart`)

**Purpose:** Password reset

**UI Elements:**

- Email text field
- "Send Reset Link" button
- Back to login link

**User Flow:**

1. User enters email
2. Tap "Send Reset Link"
3. Show success message
4. User receives email
5. User resets password via email link

**State Management:**

- `auth_provider.dart` - Handles password reset

---

#### 4. **Email Verification Screen** (`email_verification_screen.dart`)

**Purpose:** Email verification status

**UI Elements:**

- Verification icon/illustration
- "Verify your email" message
- Instructions text
- "Resend verification email" button
- "Continue" button (enabled after verification)
- "Check email" button

**User Flow:**

1. Show verification pending state
2. User checks email and clicks verification link
3. App detects verification
4. Enable "Continue" button
5. Navigate to home

**State Management:**

- `auth_provider.dart` - Checks verification status

---

## 🏠 Home/Dashboard Feature

### Screen

#### **Home Screen** (`home_screen.dart`)

**Purpose:** Dashboard with overview and quick actions

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar (with search, profile) │
├─────────────────────────────────┤
│  Stats Grid (2x2)                │
│  ┌─────────┬─────────┐          │
│  │ Total   │ Shared  │          │
│  │ Notes   │ Notes   │          │
│  ├─────────┼─────────┤          │
│  │ Recent  │ Messages│          │
│  │ Updates │ Unread  │          │
│  └─────────┴─────────┘          │
├─────────────────────────────────┤
│  Quick Actions                   │
│  [Create Note] [Generate PDF]    │
├─────────────────────────────────┤
│  Recent Notes (Horizontal List)  │
│  ┌────┐ ┌────┐ ┌────┐          │
│  │Note│ │Note│ │Note│          │
│  └────┘ └────┘ └────┘          │
├─────────────────────────────────┤
│  Shared Notes (Horizontal List)  │
│  ┌────┐ ┌────┐ ┌────┐          │
│  │Note│ │Note│ │Note│          │
│  └────┘ └────┘ └────┘          │
└─────────────────────────────────┘
```

**UI Elements:**

- App bar with:
  - App title/logo
  - Search icon (navigate to search)
  - Profile icon (navigate to profile)
- Stats grid (4 cards):
  - Total Notes count
  - Shared Notes count
  - Recent Updates count
  - Unread Messages count
- Quick actions:
  - "Create Note" button
  - "Generate PDF" button
- Recent Notes section:
  - Horizontal scrollable list
  - Note cards with preview
  - "View All" button
- Shared Notes section:
  - Horizontal scrollable list
  - Shared note cards
  - "View All" button

**User Interactions:**

- Tap stat card → Navigate to relevant screen
- Tap "Create Note" → Navigate to create note screen
- Tap "Generate PDF" → Navigate to PDF generator
- Tap note card → Navigate to note detail
- Pull to refresh → Refresh all data

**State Management:**

- `dashboard_provider.dart` - Fetches stats and recent notes

**Data Sources:**

- Notes count from Firestore
- Shared notes count
- Recent notes (last 5)
- Unread messages count

---

## 📝 Notes Management Feature

### Screens

#### 1. **Notes Screen** (`notes_screen.dart`)

**Purpose:** List all user's notes with search and filter

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar                        │
├─────────────────────────────────┤
│  Search Bar                     │
├─────────────────────────────────┤
│  Filter Chips                   │
│  [All] [Work] [Personal] [Tags] │
├─────────────────────────────────┤
│  Sort Dropdown                  │
│  [Newest First ▼]               │
├─────────────────────────────────┤
│  Notes List (Grid/List View)    │
│  ┌──────┐ ┌──────┐             │
│  │ Note │ │ Note │             │
│  │ Card │ │ Card │             │
│  └──────┘ └──────┘             │
│  ┌──────┐ ┌──────┐             │
│  │ Note │ │ Note │             │
│  │ Card │ │ Card │             │
│  └──────┘ └──────┘             │
└─────────────────────────────────┘
│  FAB: Create Note               │
└─────────────────────────────────┘
```

**UI Elements:**

- App bar with title "My Notes"
- Search bar (with clear button)
- Filter chips:
  - All Notes
  - By Category (Work, Personal, etc.)
  - By Tag
  - Shared Notes
  - Own Notes
- Sort dropdown:
  - Newest First
  - Oldest First
  - Recently Updated
  - Alphabetical
- Notes grid/list (toggle view):
  - Grid view (2 columns)
  - List view (1 column)
- Empty state (when no notes)
- Floating Action Button: "Create Note"

**User Interactions:**

- Type in search → Filter notes in real-time
- Tap filter chip → Apply filter
- Tap sort → Change sort order
- Tap note card → Navigate to note detail
- Long press note card → Show context menu (Edit, Delete, Share)
- Tap FAB → Navigate to create note
- Pull to refresh → Refresh notes

**State Management:**

- `notes_provider.dart` - Fetches notes
- `notes_filter_provider.dart` - Handles filtering
- `search_provider.dart` - Handles search

**Filter Options:**

- All notes
- By category
- By tag
- Shared notes only
- Own notes only
- Pinned notes
- Archived notes

---

#### 2. **Note Detail Screen** (`note_detail_screen.dart`)

**Purpose:** View full note content

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar (with actions)         │
├─────────────────────────────────┤
│  Note Title                     │
│  Note Metadata (date, category) │
├─────────────────────────────────┤
│  Note Content (scrollable)      │
│  - Rich text                    │
│  - Images (if any)              │
│  - Attachments (if any)         │
├─────────────────────────────────┤
│  Tags                           │
│  [tag1] [tag2] [tag3]           │
├─────────────────────────────────┤
│  Actions                        │
│  [Edit] [Share] [PDF] [Delete]  │
└─────────────────────────────────┘
```

**UI Elements:**

- App bar with:
  - Back button
  - Note title
  - More menu (Edit, Share, Delete, Archive)
- Note metadata:
  - Created date
  - Updated date
  - Category badge
  - Pinned indicator
- Note content:
  - Rich text display
  - Images (if any) - gallery view
  - Attachments (if any) - downloadable
- Tags section:
  - Tag chips
- Action buttons:
  - Edit button
  - Share button
  - Generate PDF button
  - Delete button

**User Interactions:**

- Tap Edit → Navigate to edit screen
- Tap Share → Open share dialog
- Tap PDF → Generate and preview PDF
- Tap Delete → Show confirmation dialog
- Tap image → Full screen image viewer
- Tap attachment → Download/open file
- Swipe to delete (optional)

**State Management:**

- `note_detail_provider.dart` - Fetches note details

---

#### 3. **Create Note Screen** (`create_note_screen.dart`)

**Purpose:** Create new note

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar (Cancel, Save)         │
├─────────────────────────────────┤
│  Title Text Field               │
├─────────────────────────────────┤
│  Rich Text Editor               │
│  (with formatting toolbar)      │
├─────────────────────────────────┤
│  Options                        │
│  [Category] [Tags] [Color]     │
│  [Add Image] [Add File]         │
└─────────────────────────────────┘
```

**UI Elements:**

- App bar with:
  - Cancel button
  - "Save" button (disabled until title entered)
- Title text field
- Rich text editor:
  - Formatting toolbar (Bold, Italic, etc.)
  - Text input area
- Options section:
  - Category picker
  - Tags input (chip input)
  - Color picker (optional)
  - Add image button
  - Add file button
- Image previews (if images added)
- File list (if files added)

**User Interactions:**

- Type title → Enable save button
- Format text → Apply formatting
- Add image → Open image picker
- Add file → Open file picker
- Select category → Show category picker
- Add tags → Add tag chips
- Tap Save → Create note and navigate back
- Tap Cancel → Show discard confirmation

**State Management:**

- `note_form_provider.dart` - Manages form state

**Validation:**

- Title required
- Content optional (but recommended)

---

#### 4. **Edit Note Screen** (`edit_note_screen.dart`)

**Purpose:** Edit existing note

**Same as Create Note Screen, but:**

- Pre-filled with existing note data
- "Update" button instead of "Save"
- Shows note metadata
- Handles permission check (for shared notes)

**User Interactions:**

- Same as create note
- Additional: Check edit permission for shared notes

---

## 📄 PDF Generation Feature

### Screens

#### 1. **PDF Generator Screen** (`pdf_generator_screen.dart`)

**Purpose:** Generate PDF from text or images

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar                        │
├─────────────────────────────────┤
│  Options                        │
│  ○ Text to PDF                  │
│  ○ Image to PDF                 │
├─────────────────────────────────┤
│  Content Area                   │
│  (Text input OR Image picker)   │
├─────────────────────────────────┤
│  Preview (if available)         │
├─────────────────────────────────┤
│  [Generate PDF] Button          │
└─────────────────────────────────┘
```

**UI Elements:**

- App bar with title "Generate PDF"
- Option selector:
  - Text to PDF (radio button)
  - Image to PDF (radio button)
- Content area:
  - **Text mode:** Rich text editor
  - **Image mode:** Image picker grid (multiple images)
- Preview section (if content added)
- "Generate PDF" button
- Generated PDF preview (after generation)

**User Interactions:**

- Select option → Switch content area
- Enter text → Show preview
- Pick images → Show image grid
- Remove images → Remove from grid
- Reorder images → Drag to reorder
- Tap Generate → Show loading, generate PDF
- Tap Preview → Open PDF preview screen
- Tap Download → Save PDF to device

**State Management:**

- `pdf_provider.dart` - Handles PDF generation

**PDF Options:**

- Page size (A4, Letter, etc.)
- Orientation (Portrait, Landscape)
- Margins
- Font size (for text)

---

#### 2. **PDF Preview Screen** (`pdf_preview_screen.dart`)

**Purpose:** Preview generated PDF

**UI Elements:**

- PDF viewer (full screen)
- App bar with:
  - Back button
  - Download button
  - Share button
- Bottom bar with:
  - Page number
  - Zoom controls

**User Interactions:**

- Scroll → Navigate pages
- Pinch → Zoom in/out
- Tap Download → Save PDF
- Tap Share → Share PDF

---

## 🔗 Sharing Feature

### Screens

#### 1. **Share Note Screen** (`share_note_screen.dart`)

**Purpose:** Share note with other users

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar                        │
├─────────────────────────────────┤
│  Note Preview                   │
│  [Note Title]                   │
├─────────────────────────────────┤
│  Search Users                   │
│  [Search bar]                   │
├─────────────────────────────────┤
│  User List                      │
│  ┌─────────────────────────┐   │
│  │ [ ] User 1              │   │
│  │ [ ] User 2              │   │
│  │ [x] User 3 (selected)   │   │
│  └─────────────────────────┘   │
├─────────────────────────────────┤
│  Permission                     │
│  ○ View Only                    │
│  ● Edit                         │
├─────────────────────────────────┤
│  [Share] Button                 │
└─────────────────────────────────┘
```

**UI Elements:**

- Note preview card
- User search bar
- User list with checkboxes
- Permission selector:
  - View Only (radio)
  - Edit (radio)
- "Share" button
- Already shared users list (if any)

**User Interactions:**

- Search users → Filter user list
- Select users → Check/uncheck
- Select permission → Change permission
- Tap Share → Share note and show success
- Tap user → View user profile (optional)

**State Management:**

- `sharing_provider.dart` - Handles sharing logic

---

#### 2. **Shared Notes Screen** (`shared_notes_screen.dart`)

**Purpose:** View notes shared with user

**Layout Structure:**
Similar to Notes Screen, but:

- Shows only shared notes
- Shows owner information
- Shows permission badge (View/Edit)

**UI Elements:**

- Same as Notes Screen
- Additional: Owner name on each card
- Permission badge

**User Interactions:**

- Same as Notes Screen
- Additional: Tap to view note (respects permission)

---

## 💬 Messaging Feature

### Screens

#### 1. **Messages Screen** (`messages_screen.dart`)

**Purpose:** List of conversations

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar "Messages"             │
├─────────────────────────────────┤
│  Conversation List              │
│  ┌─────────────────────────┐   │
│  │ Avatar | Name           │   │
│  │         Last message    │   │
│  │         Time | [Badge]  │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

**UI Elements:**

- Conversation list items:
  - User avatar
  - User name
  - Last message preview
  - Timestamp
  - Unread badge (if unread)
- Empty state (no conversations)

**User Interactions:**

- Tap conversation → Navigate to chat screen
- Long press → Delete conversation (optional)
- Pull to refresh → Refresh conversations

**State Management:**

- `messages_provider.dart` - Fetches conversations

---

#### 2. **Chat Screen** (`chat_screen.dart`)

**Purpose:** Real-time chat interface

**Layout Structure:**

```
┌─────────────────────────────────┐
│  App Bar (User name, avatar)    │
├─────────────────────────────────┤
│  Messages (scrollable)           │
│  ┌──────────────┐              │
│  │ Sent msg     │              │
│  └──────────────┘              │
│  ┌──────────────┐              │
│  │ Received msg │              │
│  └──────────────┘              │
├─────────────────────────────────┤
│  Message Input                  │
│  [Text field] [Send] [Attach]  │
└─────────────────────────────────┘
```

**UI Elements:**

- Chat header with:
  - User name
  - User avatar
  - Online status (optional)
- Message bubbles:
  - Sent messages (right aligned)
  - Received messages (left aligned)
  - Timestamp
  - Read receipts (optional)
- Message input:
  - Text field
  - Send button
  - Attach button (image/file)
- Typing indicator (optional)

**User Interactions:**

- Type message → Enable send button
- Tap Send → Send message
- Tap Attach → Open file picker
- Scroll → Load older messages (pagination)
- Tap message → Show options (copy, delete)

**State Management:**

- `chat_provider.dart` - Handles chat logic
- Real-time listener for messages

---

## 🔍 Search Feature

### Screen

#### **Search Screen** (`search_screen.dart`)

**Purpose:** Advanced search and filter

**Layout Structure:**

```
┌─────────────────────────────────┐
│  Search Bar (with back)         │
├─────────────────────────────────┤
│  Filter Options                 │
│  [All] [Notes] [Shared] [Tags] │
├─────────────────────────────────┤
│  Recent Searches                │
│  [tag1] [tag2] [tag3]          │
├─────────────────────────────────┤
│  Search Results                 │
│  ┌──────┐ ┌──────┐            │
│  │ Note │ │ Note │            │
│  └──────┘ └──────┘            │
└─────────────────────────────────┘
```

**UI Elements:**

- Search bar (with clear button)
- Filter chips
- Recent searches (chips)
- Search results (grid/list)
- Empty state (no results)

**User Interactions:**

- Type query → Search in real-time
- Tap filter → Apply filter
- Tap recent search → Use as query
- Tap result → Navigate to note detail

**State Management:**

- `search_provider.dart` - Handles search logic

**Search Scope:**

- Note titles
- Note content
- Tags
- Categories

---

## 👤 Profile Feature

### Screens

#### 1. **Profile Screen** (`profile_screen.dart`)

**Purpose:** User profile and settings

**UI Elements:**

- Profile header:
  - Avatar
  - Display name
  - Email
  - Edit button
- Stats section:
  - Total notes
  - Shared notes
  - Messages
- Settings list:
  - Edit Profile
  - Notifications
  - Theme
  - Language
  - About
  - Logout

**User Interactions:**

- Tap Edit Profile → Navigate to edit screen
- Tap settings item → Navigate to settings
- Tap Logout → Show confirmation, logout

**State Management:**

- `profile_provider.dart` - Fetches user data

---

#### 2. **Edit Profile Screen** (`edit_profile_screen.dart`)

**Purpose:** Edit user profile

**UI Elements:**

- Avatar picker
- Display name field
- Email (read-only)
- Save button

**User Interactions:**

- Tap avatar → Change avatar
- Edit name → Update name
- Tap Save → Update profile

---

#### 3. **Settings Screen** (`settings_screen.dart`)

**Purpose:** App settings

**UI Elements:**

- Theme selector (Light/Dark/System)
- Language selector
- Notification settings:
  - Push notifications toggle
  - Message notifications toggle
  - Note update notifications toggle
- About section:
  - App version
  - Terms of service
  - Privacy policy

**User Interactions:**

- Change theme → Apply theme
- Toggle notifications → Update settings
- Tap About items → Open links

---

## 🎨 UI/UX Guidelines

### Design Principles

1. **Material Design 3:** Follow Material Design guidelines
2. **Consistency:** Use consistent components across screens
3. **Feedback:** Provide visual feedback for all actions
4. **Loading States:** Show loading indicators for async operations
5. **Error Handling:** Show user-friendly error messages
6. **Empty States:** Show helpful empty states with actions
7. **Animations:** Use smooth transitions and animations

### Color Usage

- **Primary:** For main actions (buttons, links)
- **Secondary:** For secondary actions
- **Surface:** For cards and containers
- **Error:** For error messages and destructive actions
- **Success:** For success messages

### Typography

- **Headings:** Bold, larger size
- **Body:** Regular, readable size
- **Captions:** Smaller, for metadata

### Spacing

- Consistent spacing using spacing constants
- Adequate padding in cards and containers
- Proper margins between elements

---

This feature breakdown ensures:

- ✅ Clear screen specifications
- ✅ Defined user flows
- ✅ Consistent UI/UX
- ✅ Complete feature coverage

Follow these specifications when building each screen! 🎯
