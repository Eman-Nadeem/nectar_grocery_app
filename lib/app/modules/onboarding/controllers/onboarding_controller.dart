import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  void onGetStartedPressed() {
    // Navigate to Login screen when implemented
    Get.offAllNamed(Routes.login);
  }
}