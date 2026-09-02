# Nectar App - Project Context & Documentation 🛒📱

> **App Display Name**: `Nectar`  
> **App Launcher Icon**: Carrot asset (`assets/icons/carrot.png`) over primary green background (`#53B175`)  
> **Last Updated**: September 02, 2026  
> **Framework**: Flutter 3.x (Dart SDK ^3.11.5)  
> **State Management & Routing**: GetX Pattern  
> **Backend**: Firebase Authentication, Cloud Firestore & Firebase Cloud Functions (v2)  
> **Push Notifications**: Firebase Cloud Messaging (FCM) & Topics  
> **Media Storage**: Cloudinary (HTTP Multipart Upload API) & Firebase Storage  
> **Dynamic Config & Messaging**: Firebase Remote Config & Firebase In-App Messaging  
> **Observability & Analytics**: Firebase Crashlytics & Firebase Analytics  
> **Static Analysis**: 0 Errors / 0 Warnings (`flutter analyze` clean)

---

## 1. Project Overview & Feature Architecture

The application is structured using GetX Feature Modules (`lib/app/modules/`). Each feature contains its own `bindings/`, `controllers/`, and `views/`.

```text
lib/
├── firebase_options.dart
├── main.dart                          # App Entrypoint, FCM Background Handler & Error Interceptors
└── app/
    ├── components/                    # Shared UI components (ProductCard, GroceryCategoryCard, CustomTextField)
    ├── data/
    │   ├── models/                    # ProductModel, CategoryModel, OrderModel, UserModel, CartItemModel
    │   └── repositories/              # ProductRepository, CategoryRepository, OrderRepository, StorageRepository
    ├── modules/
    │   ├── admin/                     # Admin Dashboard 3-tab management (Products, Categories, Orders)
    │   ├── auth/                      # Login, SignUp, Onboarding (Number, Verification, Location with GPS)
    │   ├── cart/                      # Cart View, Free Delivery Progress Bar & Checkout Sheet
    │   ├── category_products/         # Products list filtered by Category ID
    │   ├── explore/                   # Explore category grid & real-time product search
    │   ├── favourite/                 # Favorite products synced with Firestore
    │   ├── home/                      # Main Shop view with 5 BottomNav tabs & dynamic Location Header
    │   ├── onboarding/                # 3-Page Onboarding Carousel with Remote Config copy & active dots
    │   ├── profile/                   # User Profile, My Orders tracking, My Details & Role-based Admin link
    │   └── splash/                    # Splash screen, Remote Config maintenance check & Auth State check
    ├── routes/                        # AppRoutes & AppPages
    └── utils/                         # AppColors, ImageStrings, RemoteConfigService, AnalyticsService, CrashlyticsService, NotificationService
functions/
├── index.js                           # Cloud Functions (Order Status Push & New Product Broadcast)
├── package.json                       # Node.js dependencies (firebase-admin, firebase-functions v2)
└── firebase.json                      # Workspace Firebase deployment descriptor
```

---

## 2. Completed Features & Implementation Details

### 🔔 A. Phase 3: Firebase Cloud Messaging (FCM) & Push Notifications
- **Centralized Service ([`NotificationService`](file:///d:/nectar_grocery_app/lib/app/utils/notification_service.dart))**:
  - Handles permission requests, device FCM token retrieval (`getToken()`), token refresh listeners, and topic subscription (`all_users`).
  - Stores/syncs device `fcmToken` to Cloud Firestore under `users/{uid}/fcmToken`.
  - Displays toast banner for foreground push messages and handles deep-link route navigation on notification tap from background or terminated states.
- **Top-Level Background Handler ([`main.dart`](file:///d:/nectar_grocery_app/lib/main.dart))**:
  - Annotated with `@pragma('vm:entry-point')` to prevent Dart VM isolate tree-shaking in release builds.

---

### ⚡ B. Phase 3: Firebase Cloud Functions Backend (`functions/`)
- **Order Status Update Trigger (`onOrderStatusUpdated`)**:
  - Triggers automatically when an Admin updates an order document (`orders/{orderId}`).
  - Retrieves buyer's `userId`, queries their `fcmToken` from Firestore `users/{userId}`, and dispatches a high-priority targeted push notification: *"Your order #XXXXXXXX status has been updated to Processing/Delivered"*.
- **New Product Broadcast Trigger (`onNewProductAdded`)**:
  - Triggers automatically when a new product is added in the Admin Dashboard (`products/{productId}`).
  - Sends a broadcast push notification to topic `/topics/all_users`: *"New Item Alert 🛒 [Product Name] ($XX.XX) is now available!"*.

---

### 🔐 C. Authentication & 3-Step Onboarding Flow with Real GPS
- **3-Page Onboarding Walkthrough (`OnboardingView` & `OnboardingController`)**:
  - Headlines, subtitles, and CTA text dynamically fetched from **Firebase Remote Config**.
  - Fixed parent data layout issue inside `PageView.builder` to guarantee 0 framework rendering crashes.
  - Step completion event logging (`onboarding_completed`).
- **Deferred Account Creation**: Credentials saved locally on `SignUpView` and committed to Firebase Auth only after completing the location step.
- **Screen 1: Mobile Number (`NumberView`)**: Editable country code (`+92`) + mobile number input.
- **Screen 2: Verification (`VerificationView`)**: 6-digit OTP verification via **`pinput`** & Firebase Phone Auth.
- **Screen 3: Select Location (`SelectLocationView`)**: Zone & Area selection with **GPS reverse geocoding** (`geolocator` & `geocoding`) featuring a 4-second strict timeout safeguard.

---

### 📦 D. E-Commerce Checkout, Dynamic Free Delivery & Order Tracking
- **Dynamic Free Delivery Progress Banner (`CartView` & `CartController`)**:
  - Automatically calculates subtotal against `free_delivery_threshold` (default: `$50.0`).
  - Below threshold: Displays *"Add $XX.XX more for FREE Delivery!"* with a real-time progress indicator bar.
  - Threshold reached: Unlocks **`Standard Delivery (FREE)`** dynamically and fires the `unlocked_free_delivery` In-App Event.
- **Interactive Cart**: Quantity modifiers, subtotal calculations, and item deletion.
- **Checkout Sheet & Orders**: Saves order documents under `orders/{orderId}`.
- **Celebration Screen ([`OrderAcceptedView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/order_accepted_view.dart))**: Triggers `order_placed_success`.
- **My Orders Page ([`MyOrdersView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_orders_view.dart))**: Status badges: 🟢 *Accepted*, 🟠 *Processing*, 🔵 *Delivered*, 🔴 *Cancelled*.

---

### 👤 E. Profile & My Details Management
- **Avatar with Username Initials**: Displays user initials on a green avatar background.
- **My Details Page ([`MyDetailsView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_details_view.dart))**: Live Firestore profile editing with photo selection.
- **Role-Based Admin Access**: Displays Admin Dashboard tile **ONLY if** `isAdmin == true` or `role == 'admin'`.

---

### 🛠️ F. Admin Dashboard (3-Tab Management)
- **Tab 1: Products**: Catalog list, Add/Edit/Delete actions, gallery image picker, Cloudinary upload.
- **Tab 2: Categories**: Thumbnail ListView, title editor, 6 primary theme color pickers.
- **Tab 3: Customer Orders**: Real-time customer order management with status updates triggering Cloud Functions push notifications.

---

### 🌐 G. Firebase Remote Config, Analytics & Crashlytics
- **`RemoteConfigService`**: 12 parameters including dynamic onboarding copy, promo banners, free delivery thresholds, and maintenance mode.
- **Crash Interception**: Framework fatal errors logged to Crashlytics via `FlutterError.onError` and `PlatformDispatcher.instance.onError`. Non-fatal network and repository errors captured via `CrashlyticsService`.
- **Analytics Service**: E-commerce funnel analytics (`logAddToCart`, `logPurchase`, `logViewItem`, `logSearch`, `logLogin`, `logSignUp`).

---

## 3. Registered Routes Sitemap

| Route Constant | Path | View | Binding | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Routes.splash` | `/splash` | `SplashView` | `SplashBinding` | Initial Auth state check & Remote Config maintenance check |
| `Routes.onboarding` | `/onboarding` | `OnboardingView` | `OnboardingBinding` | 3-Page Remote Config Onboarding walkthrough |
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
- **Deploy Cloud Functions**:
  ```bash
  cd functions
  firebase deploy --only functions
  ```
- **Build Release Split APKs**:
  ```bash
  flutter build apk --split-per-abi
  ```
