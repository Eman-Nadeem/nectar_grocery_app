import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/admin/controllers/admin_controller.dart';

class AdminBinding extends Bindings{
  @override
  void dependencies(){
    Get.put<AdminController>(AdminController());
  }
}