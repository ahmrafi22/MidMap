# MidMap 🗺️

A Flutter-based map application for creating, viewing, and managing location-based entries with offline support and image caching.

## 📖 Overview

MidMap allows users to:
- **View locations** on an interactive OpenStreetMap
- **Create new entries** with title, coordinates, and optional images
- **Edit and delete** existing entries
- **Work offline** with locally cached data and images
- **Toggle dark/light themes**

The app follows a **Repository Pattern** with offline-first architecture, syncing data with a remote REST API when online and falling back to SQLite when offline.

---

## 🛠️ Tech Stack & Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_map` | ^6.1.0 | Interactive OpenStreetMap widget |
| `latlong2` | ^0.9.1 | Coordinate handling |
| `http` | ^1.6.0 | HTTP client for API calls |
| `http_parser` | ^4.0.0 | Multipart request support |
| `sqflite` | ^2.3.0 | SQLite local database |
| `path_provider` | ^2.0.0 | Access to device directories |
| `connectivity_plus` | ^6.0.0 | Network connectivity detection |
| `image_picker` | ^1.0.0 | Gallery/camera image selection |
| `image` | ^4.0.0 | Image resizing before upload |
| `provider` | ^6.0.0 | State management |
| `google_fonts` | ^6.1.0 | Custom typography |
| `cached_network_image` | ^3.3.1 | Network image caching |

---

## ⚙️ Key Mechanisms

### 1. **Offline-First Architecture**
```
Online  → Fetch from API → Save to SQLite → Cache Images → Display
Offline → Load from SQLite → Display cached images
```

### 2. **Repository Pattern**
- `MapEntryRepository` acts as single source of truth
- Coordinates between `ApiService`, `DatabaseHelper`, and `ImageCacheService`
- Automatically handles online/offline states

### 3. **Image Caching**
- Images are downloaded and stored locally in app documents
- Cached images are served when offline or on slow connections
- Images are resized to 800x600 before upload to save bandwidth

### 4. **State Management**
- Uses `Provider` package with `ChangeNotifier`
- `ThemeProvider` manages light/dark mode across the app

---

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point & theme setup
├── api/
│   └── api_service.dart   # REST API communication
├── db/
│   ├── database_helper.dart    # SQLite operations
│   └── image_cache_service.dart # Image caching logic
├── dialogs/
│   └── edit_entry_dialog.dart  # Edit entry modal
├── models/
│   └── map_entry.dart     # Data model
├── providers/
│   └── theme_provider.dart # Theme state
├── repository/
│   └── map_entry_repository.dart # Data layer coordinator
├── screens/
│   ├── overview_screen.dart    # Map view
│   ├── records_screen.dart     # List view
│   └── new_entry_screen.dart   # Create entry form
└── widgets/
    ├── custom_bottom_nav_bar.dart   # Navigation bar
    └── dark_mode_toggle_button.dart # Theme toggle
```

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK (^3.10.3)
- Android Studio / VS Code with Flutter extension
- Android device/emulator or iOS simulator

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/ahmrafi22/MidMap.git
   cd MidMap
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Debug mode
   flutter run

   # Release mode (Android)
   flutter run --release
   ```

4. **Build APK**
   ```bash
   flutter build apk --release
   ```
   The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 Documentation

See [explain.md](./explain.md) for detailed documentation including:
- Complete folder structure explanation
- Backend CRUD function details
- Offline storage and image caching flow diagrams
- SQLite database schema
- Navigation flow

---

## 🔗 API Endpoint

Backend: `https://labs.anontech.info/cse489/t3/api.php`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api.php` | Get all entries |
| POST | `/api.php` | Create new entry |
| PUT | `/api.php` | Update entry |
| DELETE | `/api.php?id=X` | Delete entry |

---

## 📱 Screenshots

| Overview (Map) | Records (List) | New Entry |
|----------------|----------------|-----------|
| Interactive map with markers | Scrollable list with cards | Form with image picker |

---

## 📝 License

This project is for educational purposes.
