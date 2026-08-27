import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/profile/controllers/profile_controller.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Profile Header
              _buildProfileHeader(),
              const SizedBox(height: 30),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // 2. Simplified Menu Items
              _buildMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Orders',
                onTap: () {},
              ),
              const Divider(height: 1),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'My Details',
                onTap: () {},
              ),
              const Divider(height: 1),

              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Delivery Address',
                onTap: () {},
              ),
              const Divider(height: 1),

              // 3. Admin Dashboard Tile (Only visible if Admin)
              Obx(
                () => controller.isAdmin.value
                    ? Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Admin Dashboard',
                            iconColor: AppColors.primary,
                            onTap: () => Get.toNamed(Routes.admin),
                          ),
                          const Divider(height: 1),
                        ],
                      )
                    : const SizedBox(),
              ),

              const SizedBox(height: 40),

              // 4. Logout Button
              SizedBox(
                width: double.infinity,
                height: 55,
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
            ],
          ),
        ),
      ),
    );
  }

  // Header Widget (Avatar + Name + Email)
  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 32,
          backgroundColor: Color(0xFFE2E2E2),
          child: Icon(Icons.person, size: 40, color: AppColors.primary),
        ),
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
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  controller.userEmail.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Menu Tile Item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.textPrimary,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textPrimary),
      onTap: onTap,
    );
  }
}
