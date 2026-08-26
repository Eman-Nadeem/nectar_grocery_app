import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _checkUserAuthStatus();
  }

  void _checkUserAuthStatus(){
    Future.delayed(const Duration(seconds: 3), (){
      final user = _auth.currentUser;
      if (user != null) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.offAllNamed(Routes.onboarding);
      }
    });
  }
}
