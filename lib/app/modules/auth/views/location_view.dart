import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/auth/controllers/auth_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class SelectLocationView extends GetView<AuthController> {
  const SelectLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> zonesList = [
      'Satiana Road',
      'Canal Road',
      'Kohinoor City',
      'D Ground (People\'s Colony)',
      'Madina Town',
      'Gulberg',
      'Susan Road',
      'Jinnah Colony',
      'Samanabad',
      'West Canal Road',
    ];
    final List<String> areasList = [
      'Select your area',
      'Block A',
      'Block B',
      'Block C',
      'Commercial Area',
      'Civic Centre',
      'Officers Colony',
      'Eden Garden',
      'Batala Colony',
      'Ghulam Muhammad Abad',
    ];

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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading Delivery Address...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Location Illustration Icon Asset
                Center(
                  child: Image.asset(
                    'assets/icons/location.png',
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.location_on,
                      size: 110,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

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
                const SizedBox(height: 25),

                // Button: Use Current GPS Location
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: controller.getCurrentGPSLocation,
                    icon: const Icon(Icons.my_location, size: 20),
                    label: const Text(
                      'Use Current GPS Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Your Zone Field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Zone',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () {
                    final currentZone = controller.selectedZone.value;
                    final currentZonesList = List<String>.from(zonesList);
                    if (currentZone.isNotEmpty && !currentZonesList.contains(currentZone)) {
                      currentZonesList.insert(0, currentZone);
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: currentZone.isNotEmpty && currentZonesList.contains(currentZone) ? currentZone : null,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                      ),
                      items: currentZonesList.map((zone) {
                        return DropdownMenuItem(
                          value: zone,
                          child: Text(zone, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedZone.value = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Your Area Field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Area',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () {
                    final currentArea = controller.selectedArea.value;
                    final currentAreasList = List<String>.from(areasList);
                    if (currentArea.isNotEmpty && !currentAreasList.contains(currentArea)) {
                      currentAreasList.insert(0, currentArea);
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: currentArea.isNotEmpty && currentAreasList.contains(currentArea) ? currentArea : null,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                      ),
                      items: currentAreasList.map((area) {
                        return DropdownMenuItem(
                          value: area,
                          child: Text(area, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedArea.value = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
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
                    onPressed: controller.saveUserProfile,
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
