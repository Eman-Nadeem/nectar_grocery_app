# Nectar Grocery App - Project Context & Documentation 🛒📱

> **Last Updated**: September 02, 2026  
> **Framework**: Flutter 3.x (Dart)  
> **State Management & Routing**: GetX Pattern  
> **Backend**: Firebase Authentication & Cloud Firestore  
> **Media Storage**: Cloudinary (HTTP Multipart Upload API) & Firebase Storage  
> **Dynamic Config & Messaging**: Firebase Remote Config & Firebase In-App Messaging  
> **Observability & Analytics**: Firebase Crashlytics & Firebase Analytics  
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
│   │   ├── cart/              # Cart View, Free Delivery Progress Bar & Checkout Sheet
│   │   ├── category_products/ # Products list filtered by Category ID
│   │   ├── explore/           # Explore category grid & real-time product search
│   │   ├── favourite/         # Favorite products synced with Firestore
│   │   ├── home/              # Main Shop view with 5 BottomNav tabs & dynamic Location Header
│   │   ├── onboarding/        # 3-Page Onboarding Carousel with Remote Config copy & active dots
│   │   ├── profile/           # User Profile, My Orders tracking, My Details & Role-based Admin link
│   │   └── splash/            # Splash screen, Remote Config maintenance check & Auth State check
│   ├── routes/                # AppRoutes & AppPages
│   └── utils/                 # AppColors, ImageStrings, RemoteConfigService, AnalyticsService, CrashlyticsService
```

---

## 2. Completed Features & Implementation Details

### 🔐 A. Authentication & 3-Step Onboarding Flow with Real GPS
- **3-Page Onboarding Walkthrough (`OnboardingView` & `OnboardingController`)**:
  - 3 background illustrations (`onboarding_bg.png`, `onboarding_bg2.jpg`, `onboarding_bg3.jpg`).
  - Headlines, subtitles, and CTA button text dynamically fetched from **Firebase Remote Config** with local fallback defaults.
  - Unified single-column bottom layout eliminating text/dot overlap, featuring smooth `AnimatedSwitcher` page transitions.
  - Step completion event logging (`onboarding_completed`).
- **Deferred Account Creation**: Credentials saved locally on `SignUpView` and committed to Firebase Auth only after completing the location step.
- **Screen 1: Mobile Number (`NumberView`)**: Editable country code (`+92`) + mobile number input.
- **Screen 2: Verification (`VerificationView`)**: 6-digit OTP verification via **`pinput`** & Firebase Phone Auth.
- **Screen 3: Select Location (`SelectLocationView`)**: Zone & Area selection with **GPS reverse geocoding** (`geolocator` & `geocoding`) featuring a 4-second strict timeout safeguard.

---

### 📦 B. E-Commerce Checkout, Dynamic Free Delivery & Order Tracking
- **Dynamic Free Delivery Progress Banner (`CartView` & `CartController`)**:
  - Automatically calculates subtotal against `free_delivery_threshold` (default: `$50.0`).
  - Below threshold: Displays *"Add $XX.XX more for FREE Delivery!"* with a real-time progress indicator bar.
  - Threshold reached: Unlocks **`Standard Delivery (FREE)`** dynamically and fires the `unlocked_free_delivery` In-App Event.
  - Removed static "Free" string from standard shipping dropdowns so delivery fee is strictly conditional.
- **Interactive Cart**: Item quantity controls, live total updates, and swipe-to-delete.
- **Checkout Sheet**: Delivery method selection, Payment option, Promo Code, Total Cost, and Place Order button.
- **Cloud Firestore Orders Collection**: Saves order documents under `orders/{orderId}` with status, items breakdown, user email, and timestamp.
- **Celebration Screen ([`OrderAcceptedView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/order_accepted_view.dart))**: Centered checkmark celebration asset + **Track Order** button. Triggers In-App Event `order_placed_success`.
- **My Orders Page ([`MyOrdersView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_orders_view.dart))**: Status tracking badges: 🟢 *Accepted*, 🟠 *Processing*, 🔵 *Delivered*, 🔴 *Cancelled*.

---

### 👤 C. Profile & My Details Management
- **Avatar with Username Initials**: Displays user initials (e.g. **`EN`** for `Eman Nadeem`) on a green avatar background when no profile photo is uploaded.
- **My Details Page ([`MyDetailsView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_details_view.dart))**: Live Firestore profile editing with camera overlay photo selection.
- **Role-Based Admin Access**: Role verification checks `users/{uid}` in Cloud Firestore. Displays the **Admin Dashboard** tile **ONLY if** `isAdmin == true` or `role == 'admin'`.

---

### 🛠️ D. Admin Dashboard (3-Tab Management)
Files: [`admin_view.dart`](file:///d:/nectar_grocery_app/lib/app/modules/admin/views/admin_view.dart) & [`admin_controller.dart`](file:///d:/nectar_grocery_app/lib/app/modules/admin/controllers/admin_controller.dart)
- **Tab 1: Products**: Catalog list with floating Add button, edit/delete actions, gallery image picker, Cloudinary upload, and category dropdown.
- **Tab 2: Categories**: ListView displaying thumbnails, title, edit pencil, delete trash icon, image picker, and 6 primary theme color pickers.
- **Tab 3: Customer Orders**: Real-time list of customer orders with live status modifier dropdown updating Firestore `orders`.

---

### 🌐 E. Phase 2: Firebase Remote Config & In-App Events / Messaging
- **`RemoteConfigService` ([`remote_config_service.dart`](file:///d:/nectar_grocery_app/lib/app/utils/remote_config_service.dart))**:
  - Initialized on startup via `Get.putAsync(() => RemoteConfigService().init())`.
  - Configures safe local fallback parameters with real-time `fetchAndActivate()` logic.
  - Captures fetch failures gracefully using `CrashlyticsService.recordError(...)`.
- **12 Remote Config Parameters**:
  - `onboarding_title_1..3`, `onboarding_subtitle_1..3`: Dynamic copy for 3 onboarding pages.
  - `onboarding_button_text_next` & `onboarding_button_text_get_started`: Dynamic CTA buttons.
  - `show_promo_banner` (bool) & `promo_banner_text` (string): Dynamic shop promo banner controls.
  - `free_delivery_threshold` (double, default: `50.0`): Dynamic cart value target for free delivery.
  - `is_under_maintenance` (bool, default: `false`): Full-screen app maintenance mode toggle.
- **In-App Messaging & Events ([`AnalyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/analytics_service.dart))**:
  - Direct SDK trigger via `FirebaseInAppMessaging.instance.triggerEvent(eventName)`.
  - `order_placed_success`: Fires when a customer places an order.
  - `unlocked_free_delivery`: Fires when cart subtotal reaches the Remote Config free delivery threshold.
  - `item_favorited`: Fires when a user favorites a product.
  - `onboarding_completed`: Fires when completing onboarding.

---

### 🛡️ F. Real-Time Error Logging & Analytics (Crashlytics & Analytics)
- **Automatic Error Interception**: `FlutterError.onError` captures fatal UI crashes, while `PlatformDispatcher.instance.onError` captures unhandled async background errors.
- **Selective Non-Fatal Error Logging ([`CrashlyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/crashlytics_service.dart))**:
  - Logs Cloudinary image upload failures, Firestore read/write errors, order creation errors, geolocator timeouts, and Remote Config fetch exceptions.
- **Analytics Service ([`AnalyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/analytics_service.dart))**:
  - Screen transition breadcrumbs (`FirebaseAnalyticsObserver`), `logAddToCart`, `logPurchase`, `logViewItem`, `logSearch`, `logLogin`, and `logSignUp`.

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
- **Build Release Split APKs**:
  ```bash
  flutter build apk --split-per-abi
  ```
  *(Output file: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`)*
