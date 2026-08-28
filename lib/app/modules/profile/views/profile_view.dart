import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/profile/controllers/profile_controller.dart';
import 'package:nectar_grocery/app/modules/profile/views/my_details_view.dart';
import 'package:nectar_grocery/app/modules/profile/views/my_orders_view.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // User Info Header: Avatar (Initials or Photo) + Name + Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Obx(() {
                      final url = controller.photoUrl.value;
                      final initials = controller.initials;
                      return CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        child: url.startsWith('http')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.network(url, width: 64, height: 64, fit: BoxFit.cover),
                              )
                            : Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    }),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller.userName.value,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Obx(
                            () => Text(
                              controller.userEmail.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Divider(height: 1, thickness: 1, color: AppColors.border),

              // Option 1: Orders (User Order Tracking)
              _buildProfileOptionTile(
                icon: Icons.shopping_bag_outlined,
                title: 'Orders',
                onTap: () => Get.to(() => const MyOrdersView()),
              ),

              // Option 2: My Details (Edit Profile Info)
              _buildProfileOptionTile(
                icon: Icons.badge_outlined,
                title: 'My Details',
                onTap: () => Get.to(() => const MyDetailsView()),
              ),

              // Option 3: Delivery Address (GPS Location Selection)
              _buildProfileOptionTile(
                icon: Icons.location_on_outlined,
                title: 'Delivery Address',
                onTap: () => Get.toNamed(Routes.selectLocation),
              ),

              // Option 4: Admin Dashboard (Conditional visibility based on isAdmin)
              Obx(() {
                if (controller.isAdmin.value) {
                  return _buildProfileOptionTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Dashboard',
                    iconColor: AppColors.primary,
                    onTap: () => Get.toNamed(Routes.admin),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 40),

              // Logout Button Component
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 67,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F3F2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: controller.logout,
                    icon: const Icon(Icons.logout, color: AppColors.primary),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOptionTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
          leading: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 24),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textPrimary,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
    );
  }
}
