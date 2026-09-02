# 🥕 Nectar Grocery App

<div align="center">

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![GetX](https://img.shields.io/badge/GetX-State_Management-8B5CF6?style=for-the-badge&logo=getx&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-Auth_%26_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![FCM](https://img.shields.io/badge/Firebase-FCM_Notifications-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Cloud Functions](https://img.shields.io/badge/Firebase-Cloud_Functions_v2-4285F4?style=for-the-badge&logo=firebase&logoColor=white)
  ![Remote Config](https://img.shields.io/badge/Firebase-Remote_Config-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)
  ![In-App Messaging](https://img.shields.io/badge/Firebase-In--App_Messaging-039BE5?style=for-the-badge&logo=firebase&logoColor=white)
  ![Status](https://img.shields.io/badge/Status-Phase_3_Complete-success?style=for-the-badge)

  <p align="center">
    <b>A modern, high-performance E-Commerce Grocery Application built with Flutter, GetX, Firebase Cloud Messaging, Cloud Functions, and Firebase Cloud Services.</b>
  </p>

</div>

---

> ✅ **Project Status**: **Phase 3 Complete & Production-Ready** (`flutter analyze`: 0 errors / 0 warnings)  
> Integrated **Firebase Cloud Messaging (FCM)** and **Firebase Cloud Functions (v2)** alongside **Firebase Remote Config**, **In-App Messaging**, **Crashlytics**, **Analytics**, dynamic free delivery tracking, role-based admin dashboard, real-time GPS, and full e-commerce flows.

---

## ✨ Key Features

- **🔔 Firebase Cloud Messaging (FCM) & Push Notifications (Phase 3)**:
  - Centralized singleton service [`NotificationService`](file:///d:/nectar_grocery_app/lib/app/utils/notification_service.dart) managing permissions, device FCM tokens, token refresh events, and topic subscriptions (`all_users`).
  - Automatically saves/syncs device `fcmToken` under Firestore `users/{uid}/fcmToken`.
  - Top-level `@pragma('vm:entry-point')` background message handler in [`main.dart`](file:///d:/nectar_grocery_app/lib/main.dart) preventing tree-shaking crashes in release builds.
  - Handles foreground notification toast banners and background/terminated notification tap routing.

- **⚡ Firebase Cloud Functions Backend (Phase 3)**:
  - **`onOrderStatusUpdated`**: Automatically sends targeted push notifications to buyers when an admin updates their order status (`Accepted` ➔ `Processing` ➔ `Delivered`).
  - **`onNewProductAdded`**: Automatically broadcasts push notifications to topic `/topics/all_users` whenever a new product is added in the Admin Dashboard.

- **🌐 Firebase Remote Config Integration (Phase 2)**:
  - Dedicated singleton wrapper [`RemoteConfigService`](file:///d:/nectar_grocery_app/lib/app/utils/remote_config_service.dart) with real-time `fetchAndActivate()` & local fallback defaults.
  - **3-Page Onboarding Walkthrough**: Remotely customizable copy and CTA buttons.
  - **Dynamic Shop Promo Banner**: Toggle banner visibility and campaign copy live from Firebase Console.
  - **Free Delivery Threshold**: Dynamic cart target (`free_delivery_threshold`) to unlock free delivery across the store.
  - **Emergency Maintenance Mode**: Remotely lock app navigation and display a full-screen maintenance overlay.

- **💬 Firebase In-App Events & Messaging (Phase 2)**:
  - Custom contextual event tracking using [`AnalyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/analytics_service.dart) triggering in-app campaigns on: `unlocked_free_delivery`, `order_placed_success`, `item_favorited`, and `onboarding_completed`.

- **🛒 Checkout, Free Delivery & Order Tracking**:
  - **Dynamic Free Delivery Progress Bar**: Live progress bar in [`CartView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/cart_view.dart) showing remaining amount to unlock free delivery.
  - Interactive Cart with item quantity controls and swipe-to-delete.
  - **Checkout Bottom Sheet**: Select Delivery method, Payment option, Promo Code, Total Cost, and Place Order.
  - **Cloud Firestore Orders Collection**: Live order document creation under `orders/{orderId}`.
  - **Celebration Screen ([`OrderAcceptedView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/order_accepted_view.dart))**: Centered checkmark celebration asset + **Track Order** button.
  - **My Orders Page ([`MyOrdersView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_orders_view.dart))**: Customer order tracking with status badges (🟢 *Accepted*, 🟠 *Processing*, 🔵 *Delivered*, 🔴 *Cancelled*).

- **🔐 Authentication & 3-Step Onboarding**:
  - 3-Page onboarding carousel with interactive step indicators.
  - Deferred account creation committing credentials only after location selection.
  - Mobile Number verification & 6-Digit PIN verification using **`pinput`** & Firebase Phone Auth.
  - **Real-Time GPS Location Detection**: Powered by **`geolocator`** & **`geocoding`** with a strict 4-second timeout safeguard.

- **🏠 Dynamic Shop & Navigation**:
  - **5-Tab Bottom Navigation**: Shop, Explore, Cart, Favourite, Account.
  - **Active Real-Time Search Bar**: Instant product search directly on both Shop and Explore screens.
  - **Dynamic Inter-Linked Collections**: Products dynamically fetched from Cloud Firestore.

- **👤 User Profile & My Details**:
  - **Profile Avatar with Username Initials**: Displays user initials on a green avatar background.
  - **My Details Page ([`MyDetailsView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_details_view.dart))**: Edit profile info, phone number, and photo upload.

- **🛡️ Real-Time Error Logging, Crashlytics & Analytics**:
  - Integrated **Firebase Crashlytics** capturing fatal crashes and unhandled async exceptions.
  - Integrated **Firebase Analytics** ([`AnalyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/analytics_service.dart)) recording screen view breadcrumbs and e-commerce conversion metrics.

- **🛠️ Admin Dashboard (3-Tab Management)**:
  - **Tab 1: Products**: Catalog list, Add/Edit/Delete actions, gallery image picker, Cloudinary upload.
  - **Tab 2: Categories**: Thumbnail ListView, title editor, 6 primary theme color pickers.
  - **Tab 3: Customer Orders**: Real-time customer order list with status updates triggering automated Cloud Functions push notifications.

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Backend & Database**: [Firebase Auth](https://firebase.google.com/), [Cloud Firestore](https://firebase.google.com/docs/firestore), [Firebase Cloud Functions (v2)](https://firebase.google.com/docs/functions), [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging), [Firebase Remote Config](https://firebase.google.com/docs/remote-config), [Firebase In-App Messaging](https://firebase.google.com/docs/in-app-messaging), [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics), & [Firebase Analytics](https://firebase.google.com/docs/analytics)
- **Location & GPS**: [geolocator](https://pub.dev/packages/geolocator) & [geocoding](https://pub.dev/packages/geocoding)
- **Image Storage**: [Cloudinary API](https://cloudinary.com/) & [image_picker](https://pub.dev/packages/image_picker)
- **Formatting & Utils**: [intl](https://pub.dev/packages/intl) & [pinput](https://pub.dev/packages/pinput)

---

## 📁 Project Architecture

Following the **GetX Feature-First Architecture**:

```text
lib/
├── app/
│   ├── components/            # Reusable UI widgets (ProductCard, CategoryCard)
│   ├── data/
│   │   ├── models/            # ProductModel, CategoryModel, OrderModel, UserModel
│   │   └── repositories/      # ProductRepository, CategoryRepository, OrderRepository, StorageRepository
│   ├── modules/
│   │   ├── admin/             # Admin dashboard 3-tab management (Products, Categories, Orders)
│   │   ├── auth/              # Auth, signup, login, OTP & GPS Location selection
│   │   ├── cart/              # Cart view, free delivery progress bar, checkout sheet & OrderAcceptedView
│   │   ├── category_products/ # Products filtered by Category ID
│   │   ├── explore/           # Explore grid & real-time product search
│   │   ├── favourite/         # Favorite products synced with Firestore
│   │   ├── home/              # Main shop tab & bottom navigation host
│   │   ├── onboarding/        # 3-Page Remote Config Onboarding walkthrough
│   │   ├── profile/           # Profile, My Orders tracking & My Details editing
│   │   └── splash/            # Splash screen, Remote Config maintenance check & auth listener
│   ├── routes/                # AppRoutes & AppPages
│   └── utils/                 # AppColors, ImageStrings, RemoteConfigService, AnalyticsService, CrashlyticsService, NotificationService
functions/
├── index.js                   # Cloud Functions (Order Status Push & New Product Broadcast)
├── package.json               # Node.js dependencies (firebase-admin, firebase-functions v2)
└── firebase.json              # Workspace Firebase deployment descriptor
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.x or higher)
- Node.js (v18 or higher for Cloud Functions)
- Firebase CLI (`npm install -g firebase-tools`)

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

3. **Deploy Firebase Cloud Functions**:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   cd ..
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

5. **Build Release APK**:
   ```bash
   flutter build apk --split-per-abi
   ```

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
