import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/profile/views/my_orders_view.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class OrderAcceptedView extends StatelessWidget {
  const OrderAcceptedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Image Illustration Perfectly Centered with Offset Correction
              Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Image.asset(
                  'assets/icons/order_successfull.png',
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFF53B175),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 80, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Your Order has been\naccepted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle
              const Text(
                'Your items has been placed and is on\nit\'s way to being processed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Primary Button: Track Order -> Open My Orders Tracking Screen
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
                  onPressed: () {
                    Get.offAllNamed(Routes.home);
                    Get.to(() => const MyOrdersView());
                  },
                  child: const Text(
                    'Track Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Secondary Button: Back to home
              TextButton(
                onPressed: () {
                  Get.offAllNamed(Routes.home);
                },
                child: const Text(
                  'Back to home',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
