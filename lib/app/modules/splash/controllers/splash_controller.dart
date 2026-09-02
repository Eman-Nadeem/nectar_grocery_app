import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/remote_config_service.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _checkUserAuthStatus();
  }

  void _checkUserAuthStatus() {
    Future.delayed(const Duration(seconds: 3), () {
      // 1. App Maintenance Check from Remote Config
      if (RemoteConfigService.instance.isUnderMaintenance) {
        Get.defaultDialog(
          title: 'Store Maintenance 🛠️',
          middleText: 'Nectar Grocery is currently undergoing scheduled maintenance. Please check back shortly!',
          barrierDismissible: false,
          confirm: TextButton(
            onPressed: () => _checkUserAuthStatus(),
            child: const Text('Retry'),
          ),
        );
        return;
      }

      // 2. Auth State Check
      final user = _auth.currentUser;
      if (user != null) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.offAllNamed(Routes.onboarding);
      }
    });
  }
}
