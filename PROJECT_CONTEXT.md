# Nectar Grocery App - Project Context & Documentation 🛒📱

> **Last Updated**: August 28, 2026  
> **Framework**: Flutter 3.x (Dart)  
> **State Management & Routing**: GetX Pattern  
> **Backend**: Firebase Authentication & Cloud Firestore  
> **Media Storage**: Cloudinary (HTTP Multipart Upload API) & Firebase Storage  
> **Static Analysis**: 0 Errors / 0 Warnings (`flutter analyze` clean)

---

## 1. Project Overview & Feature Architecture

The application is structured using GetX Feature Modules (`lib/app/modules/`). Each feature contains its own `bindings/`, `controllers/`, and `views/`.

```text
lib/
├── app/
│   ├── components/            # Shared UI components (ProductCard, GroceryCategoryCard, CustomTextField)
│   ├── data/
│   │   ├── models/            # ProductModel, CategoryModel, OrderModel, UserModel, CartItemModel
│   │   └── repositories/      # ProductRepository, CategoryRepository, OrderRepository, StorageRepository
│   ├── modules/
│   │   ├── admin/             # Admin Dashboard 3-tab management (Products, Categories, Orders)
│   │   ├── auth/              # Login, SignUp, Onboarding (Number, Verification, Location with GPS)
│   │   ├── cart/              # Cart View, Checkout Bottom Sheet & OrderAcceptedView celebration
│   │   ├── category_products/ # Products list filtered by Category ID
│   │   ├── explore/           # Explore category grid & real-time product search
│   │   ├── favourite/         # Favorite products synced with Firestore
│   │   ├── home/              # Main Shop view with 5 BottomNav tabs & dynamic Location Header
│   │   ├── profile/           # User Profile, My Orders tracking, My Details & Role-based Admin link
│   │   └── splash/            # Splash screen & Auth State check
│   ├── routes/                # AppRoutes & AppPages
│   └── utils/                 # AppColors, ImageStrings, Utils (Toast feedback)
```

---

## 2. Completed Features & Implementation Details

### 🔐 A. Authentication & 3-Step Onboarding Flow with Real GPS
- **Deferred Account Creation**: Filling in Username, Email, and Password on `SignUpView` saves credentials locally. No account is created in Firebase Auth until the final location submission.
- **Screen 1: Mobile Number (`NumberView`)**:
  - Editable Country Code text field (`countryCodeController`, default `+92`).
  - Mobile number input field with circular green floating advance button (`>`).
- **Screen 2: Verification (`VerificationView`)**:
  - Powered by the **`pinput`** package (supporting 6-digit OTP codes).
  - Integrated with **Firebase Phone Auth** (`_auth.verifyPhoneNumber(...)`).
- **Screen 3: Select Location (`SelectLocationView`)**:
  - Location Illustration image asset (`assets/icons/location.png`), **Your Zone** dropdown, and **Your Area** dropdown.
  - **"Use Current GPS Location" Button**: Powered by `geolocator` and `geocoding` reverse geocoding with a **4-second strict timeout & fallback safeguard** so UI execution never hangs on Android emulators.
  - **Final Submit Button**: Executes `_auth.createUserWithEmailAndPassword(...)`, creates the `users/{user.uid}` document in Cloud Firestore, and redirects to `Routes.home`.

---

### 📦 B. E-Commerce Checkout & Customer Order Tracking
- **Interactive Cart (`CartView`)**: Item quantity controls, total calculation, and swipe-to-delete.
- **Checkout Sheet**: Full Figma mockup (Delivery method, Payment option, Promo Code, Total Cost, and Place Order button).
- **Cloud Firestore Orders Collection**: Tapping **Place Order** creates a document in `orders` storing:
  ```json
  orders / {orderId}
  {
    "id": "orderId",
    "userId": "userUid",
    "userEmail": "user@example.com",
    "totalAmount": 24.99,
    "status": "Accepted",
    "items": [...],
    "createdAt": "Timestamp"
  }
  ```
- **Celebration Screen ([`OrderAcceptedView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/order_accepted_view.dart))**: Perfectly centered checkmark graphic + **Track Order** button.
- **My Orders Page ([`MyOrdersView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_orders_view.dart))**: Customer order tracking screen with color-coded status badges:
  - 🟢 **Accepted**
  - 🟠 **Processing**
  - 🔵 **Delivered**
  - 🔴 **Cancelled**

---

### 👤 C. Profile & My Details Management
- **Avatar with Username Initials**: Displays user initials (e.g. **`EN`** for `Eman Nadeem`) on a green avatar background when no profile photo is uploaded.
- **My Details Page ([`MyDetailsView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_details_view.dart))**: Form to update Full Name, Phone Number, and Profile Photo with a camera overlay button, saving live updates to Cloud Firestore `users/{userId}`.
- **Role-Based Admin Access**: Queries `users/{uid}` in Cloud Firestore. Displays the **Admin Dashboard** tile **ONLY if** `isAdmin == true` or `role == 'admin'`. Hidden for all normal users.

---

### 🛠️ D. Admin Dashboard (3-Tab Management)
Files: [`admin_view.dart`](file:///d:/nectar_grocery_app/lib/app/modules/admin/views/admin_view.dart) & [`admin_controller.dart`](file:///d:/nectar_grocery_app/lib/app/modules/admin/controllers/admin_controller.dart)

- **Tab 1: Products Management**:
  - Catalog list with floating Add button, edit/delete actions, gallery image picker, Cloudinary upload, and mandatory Cloud Firestore category dropdown.
- **Tab 2: Categories Management**:
  - Line-by-line ListView layout displaying thumbnails, category title, edit pencil, delete trash icon, gallery image picker, and 6 light primary theme color dropdown.
- **Tab 3: Customer Orders**:
  - Real-time list of customer orders with live status update dropdown updating Firestore `orders`.

---

### 🔍 E. Dynamic Search & Inter-Linked Categories
- **Shop & Explore Live Search**: Active search bars on both Shop and Explore screens filtering products dynamically from Cloud Firestore.
- **Inter-Linked Categories**: Products linked via `categoryId` matching category IDs in Cloud Firestore (`products` and `categories` collections).

---

### 🛡️ F. Real-Time Crash Reporting & Error Logging (Firebase Crashlytics)
- **Automatic Error Interception**: `FlutterError.onError` captures UI/framework fatal crashes, while `PlatformDispatcher.instance.onError` intercepts unhandled async background errors in `main.dart`.
- **Selective Non-Fatal Error Logging ([`CrashlyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/crashlytics_service.dart))**:
  - `StorageRepository`: Logs Cloudinary image upload network errors and HTTP status failures.
  - `ProductRepository`: Logs Firestore read/write/delete/favorite errors and model deserialization crashes.
  - `OrderRepository`: Logs order creation and admin order update failures.
  - `CategoryRepository`: Logs category query and mutation errors.
  - `AuthController`: Logs GPS Geolocator location timeouts and reverse geocoding failures.
- **Android Native Gradle Setup**: Plugin IDs added in `android/settings.gradle.kts` and applied in `android/app/build.gradle.kts` for release mapping file upload and native crash symbolication.

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
| `Routes.selectLocation` | `/location` | `SelectLocationView` | `AuthBinding` | Onboarding Step 3: Zone & Area with GPS |
| `Routes.home` | `/home` | `HomeView` | `HomeBinding` | Main Shop & 5-tab Navigation Host |
| `Routes.admin` | `/admin` | `AdminView` | `AdminBinding` | Admin Dashboard 3-Tab Management |

---

## 4. Useful Terminal Commands

- **Run Analysis**: `flutter analyze`
- **Run Dev Server / Emulator**: `flutter run`
- **Build Release Split APKs**:
  ```bash
  flutter build apk --split-per-abi
  ```
  *(Output file: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`)*
