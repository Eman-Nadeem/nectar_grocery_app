# 🥕 Nectar Grocery App

<div align="center">

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![GetX](https://img.shields.io/badge/GetX-State_Management-8B5CF6?style=for-the-badge&logo=getx&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-Auth_%26_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Remote Config](https://img.shields.io/badge/Firebase-Remote_Config-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)
  ![In-App Messaging](https://img.shields.io/badge/Firebase-In--App_Messaging-039BE5?style=for-the-badge&logo=firebase&logoColor=white)
  ![Cloudinary](https://img.shields.io/badge/Cloudinary-Image_Storage-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)
  ![Status](https://img.shields.io/badge/Status-Phase_2_Complete-success?style=for-the-badge)

  <p align="center">
    <b>A modern, high-performance E-Commerce Grocery Application built with Flutter, GetX, and Firebase Cloud Services.</b>
  </p>

</div>

---

> ✅ **Project Status**: **Phase 2 Complete & Production-Ready** (`flutter analyze`: 0 errors / 0 warnings)  
> Integrated **Firebase Remote Config** and **In-App Events / Messaging** alongside full e-commerce flows, dynamic free delivery threshold progress tracking, admin management, real-time GPS location, Crashlytics, and Analytics.

---

## ✨ Key Features

- **🌐 Firebase Remote Config Integration (Phase 2)**:
  - Dedicated singleton wrapper [`RemoteConfigService`](file:///d:/nectar_grocery_app/lib/app/utils/remote_config_service.dart) with real-time `fetchAndActivate()` & local fallback defaults.
  - **3-Page Onboarding Walkthrough**: Dynamic headlines, subtitles, and CTA buttons customizable remotely with custom cropped background illustrations (`onboarding_bg.png`, `onboarding_bg2.jpg`, `onboarding_bg3.jpg`).
  - **Dynamic Shop Promo Banner**: Turn promotional banners on/off or update campaign copy live from Firebase Console.
  - **Free Delivery Threshold**: Dynamic cart target (`free_delivery_threshold`) to unlock free delivery across the store.
  - **Emergency Maintenance Mode**: Remotely lock app navigation and display a full-screen maintenance overlay during server migrations.

- **💬 Firebase In-App Events & Messaging (Phase 2)**:
  - Custom contextual event tracking using [`AnalyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/analytics_service.dart) with direct `FirebaseInAppMessaging.instance.triggerEvent` SDK calls for instant local evaluation.
  - Triggers in-app campaigns and modal sheets on events: `unlocked_free_delivery`, `order_placed_success`, `item_favorited`, and `onboarding_completed`.

- **🛒 Checkout, Free Delivery & Order Tracking**:
  - **Dynamic Free Delivery Progress Bar**: Live progress bar in [`CartView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/cart_view.dart) showing remaining amount required to unlock free delivery (`free_delivery_threshold`).
  - Interactive Cart with item quantity controls and swipe-to-delete.
  - **Checkout Bottom Sheet**: Select Delivery method, Payment option, Promo Code, Total Cost, and Place Order.
  - **Cloud Firestore Orders Collection**: Live order document creation storing items, subtotal, customer email, timestamp, and status.
  - **Celebration Screen ([`OrderAcceptedView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/order_accepted_view.dart))**: Centered checkmark celebration asset + **Track Order** button.
  - **My Orders Page ([`MyOrdersView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_orders_view.dart))**: Customer order tracking with status badges (🟢 *Accepted*, 🟠 *Processing*, 🔵 *Delivered*, 🔴 *Cancelled*).

- **🔐 Authentication & 3-Step Onboarding**:
  - 3-Page onboarding carousel with interactive step indicators.
  - Secure Email/Password Signup & Login with deferred account creation.
  - Mobile Number verification with custom country code selection.
  - 6-Digit PIN verification using **`pinput`** & Firebase Phone Auth.
  - **Real-Time GPS Location Detection**: Powered by **`geolocator`** & **`geocoding`** with a strict 4-second timeout safeguard.

- **🏠 Dynamic Shop & Navigation**:
  - **5-Tab Bottom Navigation**: Shop, Explore, Cart, Favourite, Account.
  - **Active Real-Time Search Bar**: Instant product search directly on both Shop and Explore screens.
  - **Dynamic Inter-Linked Collections**: Products are dynamically fetched from Cloud Firestore and linked to categories via `categoryId`.

- **👤 User Profile & My Details**:
  - **Profile Avatar with Username Initials**: Displays user initials (e.g. **`EN`** for `Eman Nadeem`) on a green avatar background.
  - **My Details Page ([`MyDetailsView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_details_view.dart))**: Edit profile info, phone number, and profile photo upload with camera overlay button.

- **🛡️ Real-Time Error Logging, Crashlytics & Analytics (Phase 1)**:
  - Integrated **Firebase Crashlytics** for real-time fatal crash tracking and unhandled async error capture.
  - Integrated **Firebase Analytics** ([`AnalyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/analytics_service.dart)) to record automatic screen view breadcrumbs, e-commerce events (`logAddToCart`, `logPurchase`, `logViewItem`, `logSearch`), and auth conversion metrics.

- **🛠️ Admin Dashboard (3-Tab Management)**:
  - **Tab 1: Products**: Catalog list with floating Add button, edit/delete actions, gallery image picker, Cloudinary upload, and mandatory Cloud Firestore category dropdown.
  - **Tab 2: Categories**: Line-by-line ListView layout displaying thumbnails, category title, edit pencil, delete trash icon, image picker, and 6 light primary theme color dropdown.
  - **Tab 3: Customer Orders**: Real-time list of customer orders with live status update dropdown.

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Backend & Database**: [Firebase Auth](https://firebase.google.com/), [Cloud Firestore](https://firebase.google.com/docs/firestore), [Firebase Remote Config](https://firebase.google.com/docs/remote-config), [Firebase In-App Messaging](https://firebase.google.com/docs/in-app-messaging), [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics), & [Firebase Analytics](https://firebase.google.com/docs/analytics)
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
│   └── utils/                 # AppColors, ImageStrings, RemoteConfigService, AnalyticsService, CrashlyticsService
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

3. **Run the App**:
   ```bash
   flutter run
   ```

4. **Build Release APK**:
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
