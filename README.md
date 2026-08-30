# 🥕 Nectar Grocery App

<div align="center">

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![GetX](https://img.shields.io/badge/GetX-State_Management-8B5CF6?style=for-the-badge&logo=getx&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-Auth_%26_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Cloudinary](https://img.shields.io/badge/Cloudinary-Image_Storage-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)
  ![Status](https://img.shields.io/badge/Status-Complete_%26_Verified-success?style=for-the-badge)

  <p align="center">
    <b>A modern, high-performance E-Commerce Grocery Application built with Flutter, GetX, and Firebase Cloud Firestore.</b>
  </p>

</div>

---

> ✅ **Project Status**: **Production-Ready & Fully Verified** (`flutter analyze`: 0 errors / 0 warnings)  
> All e-commerce flows, order tracking, dynamic admin management, real-time GPS location, and Cloud Firestore inter-linked architecture are fully operational.

---

## ✨ Key Features

- **🔐 Authentication & 3-Step Onboarding**:
  - Secure Email/Password Signup & Login with deferred account creation.
  - Mobile Number verification with custom country code selection.
  - 4 to 6-digit OTP code verification using **`pinput`** & Firebase Phone Auth.
  - **Real-Time GPS Location Detection**: "Use Current GPS Location" button using **`geolocator`** & **`geocoding`** reverse geocoding to auto-fill `Zone` and `Area`.

- **🏠 Dynamic Shop & Navigation**:
  - **5-Tab Bottom Navigation**: Shop, Explore, Cart, Favourite, Account.
  - **Active Real-Time Search Bar**: Instant product search directly on both Shop and Explore screens.
  - **Dynamic Inter-Linked Collections**: Products are dynamically fetched from Cloud Firestore and linked to categories via `categoryId`.

- **🛒 Checkout & Order Tracking**:
  - Interactive Cart with quantity controls and swipe-to-delete.
  - **Checkout Bottom Sheet**: Select Delivery, Payment, Promo Code, Total Cost, and Place Order.
  - **Cloud Firestore Orders Collection**: Order documents saved live with items, total price, customer email, timestamp, and status.
  - **Celebration Screen ([`OrderAcceptedView`](file:///d:/nectar_grocery_app/lib/app/modules/cart/views/order_accepted_view.dart))**: Perfectly centered checkmark celebration asset + **Track Order** button.
  - **My Orders Page ([`MyOrdersView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_orders_view.dart))**: Customer order tracking with status badges (🟢 *Accepted*, 🟠 *Processing*, 🔵 *Delivered*, 🔴 *Cancelled*).

- **👤 User Profile & My Details**:
  - **Profile Avatar with Username Initials**: Displays user initials (e.g. **`EN`** for `Eman Nadeem`) on a green avatar background when no profile photo is selected.
  - **My Details Page ([`MyDetailsView`](file:///d:/nectar_grocery_app/lib/app/modules/profile/views/my_details_view.dart))**: Edit profile info, phone number, and profile photo upload with camera overlay button.

- **🛡️ Real-Time Error Logging & Crash Reporting**:
  - Integrated **Firebase Crashlytics** for real-time fatal crash tracking and unhandled async error capture.
  - Custom [`CrashlyticsService`](file:///d:/nectar_grocery_app/lib/app/utils/crashlytics_service.dart) for selective non-fatal error logging across Firestore repositories, Cloudinary upload, and GPS location services.

- **🛠️ Admin Dashboard (3-Tab Management)**:
  - **Tab 1: Products**: Catalog list with floating Add button, edit/delete actions, gallery image picker, Cloudinary upload, and mandatory Cloud Firestore category dropdown.
  - **Tab 2: Categories**: Line-by-line ListView layout displaying thumbnails, category title, edit pencil, delete trash icon, image picker, and 6 light primary theme color dropdown.
  - **Tab 3: Customer Orders**: Real-time list of customer orders with live status update dropdown.

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Backend & Database**: [Firebase Auth](https://firebase.google.com/), [Cloud Firestore](https://firebase.google.com/docs/firestore), & [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
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
│   │   ├── cart/              # Cart view, checkout sheet & OrderAcceptedView
│   │   ├── category_products/ # Products filtered by Category ID
│   │   ├── explore/           # Explore grid & real-time product search
│   │   ├── favourite/         # Favorite products synced with Firestore
│   │   ├── home/              # Main shop tab & bottom navigation host
│   │   ├── profile/           # Profile, My Orders tracking & My Details editing
│   │   └── splash/            # Splash screen & auth listener
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
