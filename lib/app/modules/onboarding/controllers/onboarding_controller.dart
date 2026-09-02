import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/image_strings.dart';
import '../../../utils/remote_config_service.dart';
import '../../../utils/analytics_service.dart';

class OnboardingItem {
  final String image;
  final String title;
  final String subtitle;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  List<OnboardingItem> get items {
    final remoteConfig = RemoteConfigService.instance;
    return [
      OnboardingItem(
        image: ImageStrings.onboardingBackground1,
        title: remoteConfig.onboardingTitle1,
        subtitle: remoteConfig.onboardingSubtitle1,
      ),
      OnboardingItem(
        image: ImageStrings.onboardingBackground2,
        title: remoteConfig.onboardingTitle2,
        subtitle: remoteConfig.onboardingSubtitle2,
      ),
      OnboardingItem(
        image: ImageStrings.onboardingBackground3,
        title: remoteConfig.onboardingTitle3,
        subtitle: remoteConfig.onboardingSubtitle3,
      ),
    ];
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  String get buttonText {
    final remoteConfig = RemoteConfigService.instance;
    return currentPage.value == items.length - 1
        ? remoteConfig.onboardingBtnStart
        : remoteConfig.onboardingBtnNext;
  }

  void onButtonPressed() {
    if (currentPage.value < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AnalyticsService.logInAppEvent('onboarding_completed');
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}