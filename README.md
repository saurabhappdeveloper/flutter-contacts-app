# Flutter Contacts App

A fully-featured contacts manager app built with Flutter, inspired by Google Contacts. Supports Android and iOS with a clean Material Design 3 UI and SQLite offline storage.

---

## Screenshots

<p float="left">
  <img src="screenshots/screenshot_1.png" width="180"/>
  <img src="screenshots/screenshot_2.png" width="180"/>
  <img src="screenshots/screenshot_3.png" width="180"/>
  <img src="screenshots/screenshot_4.png" width="180"/>
</p>
<p float="left">
  <img src="screenshots/screenshot_5.png" width="180"/>
  <img src="screenshots/screenshot_6.png" width="180"/>
  <img src="screenshots/screenshot_7.png" width="180"/>
  <img src="screenshots/screenshot_8.png" width="180"/>
</p>

---

## APK Download

📥 **[Download APK](releases/flutter-contacts-app.apk)** — Works on all Android devices (ARM 32-bit, ARM 64-bit, x86)

**Direct link:**
```
https://github.com/saurabhappdeveloper/flutter-contacts-app/raw/master/releases/flutter-contacts-app.apk
```

**To install:**
1. Download the APK to your Android device
2. Go to **Settings → Install unknown apps** and allow installation
3. Open the downloaded APK and tap **Install**

---

## Features

### User Interface
- Material Design 3 with a clean, modern look
- Responsive layout that adapts to all screen sizes
- Smooth navigation and intuitive interactions
- Color-coded avatars with auto-generated initials

### Home Screen
- **Bottom navigation bar** with two tabs:
  - **Contacts** — full list of all saved contacts
  - **Favorites** — grid view of starred contacts for quick access

### Core Features
- **View Contacts** — scrollable list with name, phone, and avatar
- **Add Contact** — form with name, phone, email, company, address, notes, and photo
- **Edit Contact** — update any contact's details
- **Delete Contact** — delete with a confirmation dialog to prevent accidental removal
- **Contact Profile** — full detail screen with all contact information
- **Call Contact** — tap Call to directly dial the contact from the app
- **Message Contact** — tap Message to open SMS app
- **Email Contact** — tap Email to open mail app
- **Favorite Contacts** — star/unstar contacts; starred contacts appear in the Favorites tab
- **Search** — real-time search by name, phone number, or email
- **Swipe Actions** — swipe left on any contact to Star or Delete

### Validation
- Phone: 7–15 digits, accepts international formats (ITU-T E.164)
- Email: RFC 5322 standard validation
- Errors shown inline as the user types

### Data Storage
- SQLite via `sqflite` — fully offline, no internet required
- Data persists across app restarts
- Auto-increment primary keys, alphabetically sorted contact list

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| Database | SQLite via `sqflite` |
| UI | Material Design 3 |
| Image Picker | `image_picker` |
| URL Actions | `url_launcher` |
| Swipe Actions | `flutter_slidable` |
| Permissions | `permission_handler` |

---

## Installation & Setup

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio or VS Code
- Android device or emulator (API 21+)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/saurabhappdeveloper/flutter-contacts-app.git

# 2. Navigate to the project folder
cd flutter-contacts-app

# 3. Install dependencies
flutter pub get

# 4. Run the app on a connected device or emulator
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, theme setup
├── database/
│   └── database_helper.dart           # SQLite CRUD operations (singleton)
├── models/
│   └── contact.dart                   # Contact data model with toMap/fromMap
├── screens/
│   ├── home_screen.dart               # Main scaffold with bottom navigation
│   ├── contacts_tab.dart              # Contacts list with search
│   ├── favorites_tab.dart             # Starred contacts grid view
│   ├── add_edit_contact_screen.dart   # Add and edit contact form
│   └── contact_detail_screen.dart     # Full contact profile screen
├── utils/
│   ├── app_colors.dart                # App-wide color constants
│   └── phone_utils.dart              # Call, SMS, and Email actions
└── widgets/
    ├── contact_avatar.dart            # Avatar with photo or initials fallback
    └── contact_list_tile.dart         # Swipeable contact list row
```

---

## Usage Guide

| Action | Steps |
|--------|-------|
| **Add a contact** | Tap the **＋** FAB button on the bottom right |
| **Edit a contact** | Open contact → tap the **edit** icon |
| **Delete a contact** | Open contact → tap **⋮** → Delete, OR swipe left → Delete |
| **Star a contact** | Open contact → tap **★**, OR swipe left → Star |
| **View favorites** | Tap the **Favorites** tab in the bottom nav |
| **Search contacts** | Type in the search bar at the top of the Contacts tab |
| **Call a contact** | Open contact → tap **Call** button |
| **Send a message** | Open contact → tap **Message** button |
| **Send an email** | Open contact → tap **Email** button |
| **Pick a photo** | Add/Edit contact → tap the avatar → choose from gallery |

---

## Permissions

| Permission | Platform | Purpose |
|-----------|----------|---------|
| `READ_PHONE_STATE` | Android | Required to make direct calls |
| `CALL_PHONE` | Android | Place calls without opening the dialer |
| Photo library access | iOS | Pick a contact photo from gallery |

---

## License

This project was built as part of a Flutter Developer assignment for **Houzeo India**.
