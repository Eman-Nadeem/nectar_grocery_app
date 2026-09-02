import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/utils/analytics_service.dart';
import 'package:nectar_grocery/app/utils/notification_service.dart';
import 'package:nectar_grocery/app/utils/remote_config_service.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

/// Top-level background message handler annotated with @pragma('vm:entry-point') to prevent tree-shaking
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM Background Message Received]: ${message.messageId} - ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase Remote Config service
  await Get.putAsync(() => RemoteConfigService().init());

  // Initialize FCM Notification Service
  await NotificationService.instance.init();

  // Enable Crashlytics data collection for both debug and release testing
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught fatal errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nectar',
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: AnalyticsService.instance),
      ],
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
