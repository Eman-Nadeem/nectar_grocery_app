import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/cart/bindings/cart_bindings.dart';
import 'package:nectar_grocery/app/modules/explore/bindings/explore_binding.dart';
import 'package:nectar_grocery/app/modules/favourite/bindings/favourite_binding.dart';
import 'package:nectar_grocery/app/modules/profile/binding/profile_binding.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    ExploreBinding().dependencies();
    CartBinding().dependencies();
    FavouriteBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
