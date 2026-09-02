import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/crashlytics_service.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM Service, Local Notifications, Request Permissions, Setup Listeners & Save Token
  Future<void> init() async {
    try {
      // 1. Request Notification Permissions (iOS & Android 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      // 2. Setup Local Notifications Channel & Plugin
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[Local Notification Tapped]: ${response.payload}');
          Get.toNamed(Routes.home);
        },
      );

      // Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      // Enable Foreground Presentation
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Fetch FCM Token
      _fcmToken = await _messaging.getToken();
      debugPrint('[FCM] Device FCM Token: $_fcmToken');

      // 4. Save token to Firestore if user is authenticated
      if (_fcmToken != null) {
        await saveTokenToFirestore(_fcmToken!);
      }

      // 5. Listen for Token Refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        await saveTokenToFirestore(newToken);
      });

      // 6. Subscribe to broadcast channel for all app users
      await _messaging.subscribeToTopic('all_users');
      debugPrint('[FCM] Subscribed to topic: all_users');

      // 7. Handle Foreground Push Notifications with Native System Heads-up Banner + Toast
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground Message]: ${message.notification?.title} - ${message.notification?.body}');
        final notification = message.notification;
        if (notification != null) {
          // Show Native Heads-up Banner with sound
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: message.data['route'],
          );

          Utils.toastMessage(
            '🔔 ${notification.title}: ${notification.body}',
            backgroundColor: const Color(0xFF53B175),
          );
        }
      });

      // 8. Handle Notification Taps when App is in Background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM App Opened From Background Notification]: ${message.data}');
        _handleNotificationNavigation(message);
      });

      // 9. Handle Notification Tap when App was Terminated
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM App Opened From Terminated Notification]: ${initialMessage.data}');
        _handleNotificationNavigation(initialMessage);
      }
    } catch (e, stack) {
      debugPrint('[FCM Init Error]: $e');
      CrashlyticsService.recordError(e, stack, reason: 'FCM NotificationService initialization failed');
    }
  }

  /// Save FCM Token to Firestore under `users/{uid}/fcmToken`
  Future<void> saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('[FCM] Saved FCM token for user: ${user.uid}');
      } catch (e, stack) {
        debugPrint('[FCM Save Token Error]: $e');
        CrashlyticsService.recordError(e, stack, reason: 'Saving FCM Token to Firestore failed');
      }
    }
  }

  /// Route user based on notification payload data
  void _handleNotificationNavigation(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null && route.toString().isNotEmpty) {
      Get.toNamed(route.toString());
    } else {
      Get.toNamed(Routes.home);
    }
  }
}
