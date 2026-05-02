# VRCMA (VRChat Management Automation)

![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.11.0-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.x-blue.svg)
![State Management](https://img.shields.io/badge/State_Management-Riverpod_3.x-orange.svg)

**VRCMA** is a multi-platform application built with Flutter, designed to automate and streamline VRChat social interactions. It acts as an intelligent companion app that handles incoming friend requests, world invites, custom message slots, and advanced friend categorization using customizable rule sets and background processing.

## 📖 About the Project

Managing a large friends list and handling a flood of invites/requests in VRChat can be overwhelming. VRCMA solves this by allowing users to create **Filter Profiles** and **Rules** based on VRChat Trust Ranks, custom tags, or manually assigned roles. 

Built with **Clean Architecture**, **SOLID principles**, and **DRY**, the application ensures highly maintainable, scalable, and testable code.

## ✨ Key Features

*   **🤖 Smart Automations:** Automatically accept, reject, or ignore incoming world invites and friend requests based on priority rules, user tags, or assigned roles.
*   **📩 Message Slot Management:** Create a library of custom VRChat messages (Invites, Responses, Requests). Automatically assign messages to your 12 VRChat slots when an automation triggers.
*   **👥 Advanced Friend Categorization:** Group your online friends by instance, favorite groups, or online status (Active, Join Me, Busy, etc.).
*   **🏷️ Custom Roles & Tagging:** Create local roles and assign them to users manually or automatically based on their VRChat public tags (e.g., Languages, Trust Ranks).
*   **🔄 Background Execution:** Keep your automations running quietly in the background even when the app is closed (Supported on Android/iOS).
*   **📋 Detailed Logging:** Keep a local history of every automated action, showing who sent the invite, what action was taken, and which rule was applied.
*   **🔐 Secure Authentication:** Full support for VRChat Login, including 2FA (Email OTP, TOTP, Recovery Codes).

## 🏗️ Architecture & Tech Stack

This project strictly follows **Clean Architecture** dividing the app into `Domain`, `Data`, and `Presentation` layers.

*   **Framework:** Flutter
*   **State Management & DI:** [Riverpod 3.x](https://riverpod.dev/) (with code generation)
*   **Local Database:** SQLite (`sqflite` for Mobile, `sqflite_common_ffi` for Desktop)
*   **API Wrapper:** `vrchat_dart`
*   **Networking:** `dio` & `cookie_jar` for session persistence.
*   **Background Tasks:** `flutter_background_service`

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.0` or higher)
*   Dart SDK
*   For Windows/Linux builds: C++ build tools (required for SQLite FFI).

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/GabrielgsdCIUwU/VRCMA.git
   cd vrcma
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Riverpod & Freezed files:**
   Because this project uses `riverpod_annotation`, you must run the build runner to generate the `.g.dart` files.
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
 ├── core/              # Core utilities, Theme, Error handling (Failures), DI, Database Init
 ├── data/              # Repositories implementations, Models, Mappers, API calls
 ├── domain/            # Entities, Use Cases, Repository Interfaces (Business Logic)
 ├── presentation/      # UI, Riverpod Providers, Widgets, Pages
 └── main.dart          # Entry point
```

## ⚙️ How to Use Automations

1. **Create Roles:** Go to `Config > Roles` and create custom roles (e.g., "Close Friends", "Streamers").
2. **Assign Roles:** Go to the `Friends` tab, tap on a friend, and assign them a role. Alternatively, set up **Friend Automations** to auto-assign roles when adding new friends or matching VRChat tags.
3. **Setup Profiles & Rules:** Go to `Config > Profiles`. Create a profile, add rules assigning priorities to your roles, and choose whether to `ACCEPT` or `REJECT` invites from them. You can also attach custom text messages to these rules.
4. **Enable the Profile:** Toggle the profile to "Active". The app will now listen to the VRChat WebSocket and handle incoming notifications automatically!

## 🧪 Testing

The project includes unit tests for Core components, Data Mappers, and Domain Use Cases. To run the tests:

```bash
flutter test
```

## ⚠️ Disclaimer

*This application is a third-party tool and is not affiliated with, endorsed by, or officially connected to VRChat Inc. Use of the VRChat API in third-party applications is done at your own risk. Please respect the VRChat Terms of Service and API rate limits.*

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
