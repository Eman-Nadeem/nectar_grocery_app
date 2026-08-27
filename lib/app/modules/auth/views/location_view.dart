import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/auth/controllers/auth_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class SelectLocationView extends GetView<AuthController> {
  const SelectLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> zonesList = ['Banasree', 'Satiana Road', 'Dhanmondi', 'Gulshan', 'Uttara'];
    final List<String> areasList = ['Types of your area', 'Block A', 'Block B', 'Block C', 'Sector 1'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Map Illustration Icon
              const Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 130,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Select Your Location',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Switch on your location to stay in tune with what\'s happening in your area',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Your Zone Dropdown
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Zone',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: zonesList.contains(controller.selectedZone.value)
                      ? controller.selectedZone.value
                      : zonesList.first,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                  ),
                  items: zonesList.map((zone) {
                    return DropdownMenuItem(
                      value: zone,
                      child: Text(zone, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedZone.value = val;
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Your Area Dropdown
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Area',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: areasList.contains(controller.selectedArea.value)
                      ? controller.selectedArea.value
                      : areasList.first,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                  ),
                  items: areasList.map((area) {
                    return DropdownMenuItem(
                      value: area,
                      child: Text(area, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedArea.value = val;
                  },
                ),
              ),
              const SizedBox(height: 50),

              // Submit Button (Saves UserModel to Firestore & Goes to Home)
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 67,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.isLoading.value ? null : controller.saveUserProfile,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

