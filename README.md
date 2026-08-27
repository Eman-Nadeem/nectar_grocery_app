# 🥕 Nectar Grocery App

<div align="center">

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![GetX](https://img.shields.io/badge/GetX-State_Management-8B5CF6?style=for-the-badge&logo=getx&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-Auth_%26_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Cloudinary](https://img.shields.io/badge/Cloudinary-Image_Storage-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)
  ![Status](https://img.shields.io/badge/Status-Under_Active_Development-orange?style=for-the-badge)

  <p align="center">
    <b>A modern, high-performance E-Commerce Grocery Application built with Flutter, GetX, and Firebase.</b>
  </p>

</div>

---

> ⚠️ **Project Status**: **Under Active Development (Work in Progress)**  
> New features, Firebase services, and UI enhancements are continuously being added.

---

## ✨ Key Features

- **🔐 Authentication & 3-Step Onboarding**:
  - Secure Email/Password Signup with deferred account creation.
  - Mobile Number verification with custom country code selection.
  - 4 to 6-digit OTP code verification using **`pinput`** & Firebase Phone Auth.
  - Interactive Location setup (Zone & Area selection) saved directly to Cloud Firestore.

- **🏠 Dynamic Home & Navigation**:
  - 5-tab Bottom Navigation (Shop, Explore, Cart, Favourite, Account).
  - Live Location Header dynamically rendering the user's saved `Zone, Area` from Firestore.
  - Fast single-pass product catalog fetching with offline fallback.

- **👤 User Profile & Role-Based Access**:
  - User details management & session logout.
  - Role-based security: **Admin Dashboard** option is visible **strictly to users with admin privileges** in Firestore (`isAdmin: true`).

- **🛠️ Admin Dashboard (Product CRUD)**:
  - Clean catalog list view with quick edit and delete actions.
  - **Modal Bottom Sheet Overlay** form for adding and updating products.
  - **Popup Confirmation Dialogs** (*"Are you sure?"*) before saving or deleting items.
  - **Cloudinary Integration**: Direct HTTP multipart image upload API (`nectar_preset`).

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Backend & Authentication**: [Firebase Auth](https://firebase.google.com/) & [Cloud Firestore](https://firebase.google.com/docs/firestore)
- **Image Cloud Storage**: [Cloudinary API](https://cloudinary.com/)
- **PIN Code Input**: [pinput](https://pub.dev/packages/pinput)
- **HTTP Networking**: [http](https://pub.dev/packages/http)
- **Image Picker**: [image_picker](https://pub.dev/packages/image_picker)

---

## 📁 Project Architecture

Following the **GetX Feature-First Architecture**:

```text
lib/
├── app/
│   ├── components/            # Reusable UI widgets (ProductCard, CategoryCard)
│   ├── data/
│   │   ├── models/            # ProductModel, UserModel, CategoryModel
│   │   └── repositories/      # ProductRepository, StorageRepository
│   ├── modules/
│   │   ├── admin/             # Admin catalog & product management
│   │   ├── auth/              # Auth & 3-step onboarding flow
│   │   ├── home/              # Main shop & bottom navigation host
│   │   ├── profile/           # User profile & role-based admin link
│   │   └── splash/            # Splash screen & auth state listener
│   ├── routes/                # AppRoutes & AppPages
│   └── utils/                 # AppColors, ImageStrings, Utils
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.x or higher)
- Android Studio / VS Code
- Android Emulator or physical device

### Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Eman-Nadeem/nectar_grocery_app.git
   cd nectar_grocery_app
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **🔥 Firebase Setup & Configuration**:
   To connect your own Firebase project:
   - Create a project in [Firebase Console](https://console.firebase.google.com/).
   - Enable **Authentication** (Email/Password & Phone providers).
   - Create a **Cloud Firestore** database.
   - Configure using FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```

4. **Run the App**:
   ```bash
   flutter run
   ```

5. **Build Release APK**:
   ```bash
   flutter build apk --split-per-abi
   ```
   *(Output path: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`)*

---

## 👩‍💻 Developed By

**Eman Nadeem**  
Flutter & Mobile Application Developer  

- 🐙 **GitHub**: [@Eman-Nadeem](https://github.com/Eman-Nadeem)  
- 💼 **LinkedIn**: [Emaan Nadeem](https://www.linkedin.com/in/emaan-nadeem/)  

---

<div align="center">
  <sub>Built with ❤️ using Flutter & GetX</sub>
</div>
