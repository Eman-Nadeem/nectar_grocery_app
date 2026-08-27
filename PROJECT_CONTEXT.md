# Nectar Grocery App - Project Context & Documentation 🛒📱

> **Last Updated**: August 27, 2026  
> **Framework**: Flutter 3.x (Dart)  
> **State Management & Routing**: GetX Pattern  
> **Backend**: Firebase Authentication & Cloud Firestore  
> **Media Storage**: Cloudinary (HTTP Multipart Upload API)  
> **Static Analysis**: 0 Errors / 0 Warnings (`flutter analyze` clean)

---

## 1. Project Overview & Feature Architecture

The application is structured using GetX Feature Modules (`lib/app/modules/`). Each feature contains its own `bindings/`, `controllers/`, and `views/`.

```text
lib/
├── app/
│   ├── components/            # Shared UI components (ProductCard, GroceryCategoryCard, CustomTextField)
│   ├── data/
│   │   ├── models/            # ProductModel, UserModel, CategoryModel
│   │   └── repositories/      # ProductRepository, StorageRepository
│   ├── modules/
│   │   ├── admin/             # Admin Product Catalog & Modal Overlay CRUD
│   │   ├── auth/              # Login, SignUp, Onboarding (Number, Verification, Location)
│   │   ├── home/              # Main Shop view with 5 BottomNav tabs & dynamic Location Header
│   │   ├── profile/           # User Profile, Logout & Role-based Admin link
│   │   ├── splash/            # Splash screen & Auth State check
│   │   └── onboarding/        # Initial app onboarding
│   ├── routes/                # AppRoutes & AppPages
│   └── utils/                 # AppColors, ImageStrings, Utils (Toast feedback)
```

---

## 2. Completed Features & Implementation Details

### 🔐 A. Authentication & 3-Step Onboarding Flow
- **Deferred Account Creation**: Filling in Username, Email, and Password on `SignUpView` saves credentials locally. **No account is created in Firebase Auth until the final location submission.**
- **Screen 1: Mobile Number (`NumberView`)**:
  - Editable Country Code text field (`countryCodeController`, default `+92`) without hardcoded flag icons.
  - Mobile number input field with circular green floating advance button (`>`).
- **Screen 2: Verification (`VerificationView`)**:
  - Powered by the **`pinput`** package (supporting 6-digit OTP codes).
  - Integrated with **Firebase Phone Auth** (`_auth.verifyPhoneNumber(...)`) with automatic demo code (`1234`) fallback for instant testing.
- **Screen 3: Select Location (`SelectLocationView`)**:
  - Map Pin graphic, **Your Zone** dropdown, and **Your Area** dropdown.
  - **Final Submit Button**: Executes `_auth.createUserWithEmailAndPassword(...)`, creates the `users/{user.uid}` document in Cloud Firestore, and redirects to `Routes.home`.

---

### 👤 B. User Model & Cloud Firestore Schema
File: [`user_models.dart`](file:///d:/nectar_grocery_app/lib/app/data/models/user_models.dart)

```json
users / {user.uid}
{
  "uid": "USER_FIREBASE_UID",
  "username": "Eman Nadeem",
  "email": "eman@nectargrocery.com",
  "phone": "+923001234567",
  "zone": "Satiana Road",
  "area": "Block A",
  "isAdmin": false,
  "role": "user",
  "createdAt": "2026-08-27T20:30:00.000Z"
}
```

---

### 👤 C. Profile / Account Screen
- Displays User Profile Avatar, Display Name, and Email.
- Includes **Orders**, **My Details**, and **Delivery Address** tiles.
- **Role-Based Admin Access**: Queries `users/{uid}` in Cloud Firestore. Displays the **Admin Dashboard** tile **ONLY if** `isAdmin == true` or `role == 'admin'`. Hidden for all normal users.
- **Log Out Button**: Signs out from Firebase Auth (`_auth.signOut()`), clears sessions, and redirects to `Routes.login`.

---

### 🛠️ D. Admin Dashboard & Product Management (CRUD)
Files: [`admin_view.dart`](file:///d:/nectar_grocery_app/lib/app/modules/admin/views/admin_view.dart) & [`admin_controller.dart`](file:///d:/nectar_grocery_app/lib/app/modules/admin/controllers/admin_controller.dart)

- **Clean Product Catalog**: Clean list of existing products with thumbnail images, prices, units, and categories.
- **Modal Bottom Sheet Overlay**: Tapping `+ Add Product` or `Edit` opens an overlay containing:
  - Image Picker (selects gallery image).
  - Product Name, Price, Unit, Description text fields.
  - Category Selector Dropdown (`groceries`, `pulses`, `rice`, `meat`, etc.).
  - Feature Toggles (**Exclusive Offer**, **Best Selling Item**).
- **Confirmation Popups**:
  - **Before Saving**: Triggers `confirmSaveProduct()` asking *"Are you sure you want to save/update [Product Name]?"*
  - **Before Deleting**: Triggers `confirmDeleteProduct()` asking *"Are you sure you want to delete [Product Name]?"*
- **Cloudinary Image Upload Integration**:
  - Endpoint: `POST https://api.cloudinary.com/v1_1/dclaxglms/image/upload`
  - Upload Preset: `nectar_preset` (Unsigned)
  - Returns `secure_url` saved directly to Firestore.

---

### 🏠 E. Home & Navigation Architecture
- **5 Bottom Navigation Tabs**:
  1. **Shop** (`HomeController`)
  2. **Explore**
  3. **Cart**
  4. **Favourite**
  5. **Account** (`ProfileView` embedded directly via `HomeBinding`).
- **Dynamic Header Location**: `HomeController.loadUserLocation()` queries Firestore (`users/{uid}`) and dynamically displays the user's saved location (`Zone, Area`) under the carrot logo.
- **Fast Performance & Image Fallbacks**:
  - 5-second single-pass Firestore fetch timeout (`.timeout(Duration(seconds: 5))`) with `fallbackProducts` so the UI loads immediately even offline.
  - Lightweight image placeholder boxes replacing heavy spinning progress indicators.

---

## 3. Registered Routes Sitemap

| Route Constant | Path | View | Binding | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Routes.splash` | `/splash` | `SplashView` | `SplashBinding` | Initial Auth state check |
| `Routes.onboarding` | `/onboarding` | `OnboardingView` | `OnboardingBinding` | Welcome walkthrough |
| `Routes.login` | `/login` | `LoginView` | `AuthBinding` | Login screen |
| `Routes.signup` | `/signup` | `SignUpView` | `AuthBinding` | SignUp credentials input |
| `Routes.number` | `/number` | `NumberView` | `AuthBinding` | Onboarding Step 1: Phone |
| `Routes.verification` | `/verification` | `VerificationView` | `AuthBinding` | Onboarding Step 2: 6-Digit PIN (`pinput`) |
| `Routes.selectLocation` | `/location` | `SelectLocationView` | `AuthBinding` | Onboarding Step 3: Zone & Area selection |
| `Routes.home` | `/home` | `HomeView` | `HomeBinding` | Main Shop & 5-tab Navigation Host |
| `Routes.admin` | `/admin` | `AdminView` | `AdminBinding` | Product CRUD & Catalog |

---

## 4. Useful Terminal Commands

- **Run Analysis**: `flutter analyze`
- **Run Dev Server / Emulator**: `flutter run`
- **Build Release Split APKs (Faster Downloads)**:
  ```bash
  flutter build apk --split-per-abi
  ```
  *(Output file: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`)*
