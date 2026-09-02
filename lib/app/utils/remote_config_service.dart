import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'crashlytics_service.dart';

class RemoteConfigService extends GetxService {
  static RemoteConfigService get instance => Get.find<RemoteConfigService>();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Remote Config Keys
  static const String keyOnboardingTitle1 = 'onboarding_title_1';
  static const String keyOnboardingSubtitle1 = 'onboarding_subtitle_1';
  static const String keyOnboardingTitle2 = 'onboarding_title_2';
  static const String keyOnboardingSubtitle2 = 'onboarding_subtitle_2';
  static const String keyOnboardingTitle3 = 'onboarding_title_3';
  static const String keyOnboardingSubtitle3 = 'onboarding_subtitle_3';
  static const String keyOnboardingBtnNext = 'onboarding_button_text_next';
  static const String keyOnboardingBtnStart =
      'onboarding_button_text_get_started';

  static const String keyShowPromoBanner = 'show_promo_banner';
  static const String keyPromoBannerText = 'promo_banner_text';
  static const String keyFreeDeliveryThreshold = 'free_delivery_threshold';
  static const String keyIsUnderMaintenance = 'is_under_maintenance';

  Future<RemoteConfigService> init() async {
    try {
      // 1. Set settings (fetch timeout and minimum fetch interval)
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 10)
              : const Duration(hours: 1),
        ),
      );

      // 2. Set default parameters for offline/immediate usage
      await _remoteConfig.setDefaults(const {
        keyOnboardingTitle1: 'Welcome\nto our store',
        keyOnboardingSubtitle1: 'Get your groceries in as fast as one hour',
        keyOnboardingTitle2: 'Fresh & Fast\nDelivery',
        keyOnboardingSubtitle2:
            'Handpicked fresh produce delivered directly to your doorstep',
        keyOnboardingTitle3: 'Exclusive Offers\n& Savings',
        keyOnboardingSubtitle3:
            'Get the best prices and daily discounts on organic products',
        keyOnboardingBtnNext: 'Next',
        keyOnboardingBtnStart: 'Get Started',
        keyShowPromoBanner: true,
        keyPromoBannerText:
            'Fresh Vegetables & Grocery Delivered to your doorstep',
        keyFreeDeliveryThreshold: 50.0,
        keyIsUnderMaintenance: false,
      });

      // 3. Fetch and activate from Firebase
      bool updated = await _remoteConfig.fetchAndActivate();
      if (kDebugMode) {
        print('[RemoteConfigService] Values fetched and activated: $updated');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('[RemoteConfigService] Exception during initialization: $error');
      }
      CrashlyticsService.recordError(
        error,
        stackTrace,
        reason: 'Firebase Remote Config Fetch & Activate Failure',
      );
    }
    return this;
  }

  // Typed Getters with fallbacks
  String get onboardingTitle1 => _remoteConfig.getString(keyOnboardingTitle1);
  String get onboardingSubtitle1 =>
      _remoteConfig.getString(keyOnboardingSubtitle1);
  String get onboardingTitle2 => _remoteConfig.getString(keyOnboardingTitle2);
  String get onboardingSubtitle2 =>
      _remoteConfig.getString(keyOnboardingSubtitle2);
  String get onboardingTitle3 => _remoteConfig.getString(keyOnboardingTitle3);
  String get onboardingSubtitle3 =>
      _remoteConfig.getString(keyOnboardingSubtitle3);
  String get onboardingBtnNext => _remoteConfig.getString(keyOnboardingBtnNext);
  String get onboardingBtnStart =>
      _remoteConfig.getString(keyOnboardingBtnStart);

  bool get showPromoBanner => _remoteConfig.getBool(keyShowPromoBanner);
  String get promoBannerText => _remoteConfig.getString(keyPromoBannerText);
  double get freeDeliveryThreshold =>
      _remoteConfig.getDouble(keyFreeDeliveryThreshold);
  bool get isUnderMaintenance => _remoteConfig.getBool(keyIsUnderMaintenance);
}
