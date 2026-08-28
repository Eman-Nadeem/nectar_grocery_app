import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/components/product_card.dart';
import 'package:nectar_grocery/app/modules/category_products/controllers/category_products_controller.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class CategoryProductsView extends GetView<CategoryProductsController> {
  const CategoryProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.category.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.categoryProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'No products found in ${controller.category.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(25),
            itemCount: controller.categoryProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              final product = controller.categoryProducts[index];
              return ProductCard(
                product: product,
                onTap: () => Get.toNamed(Routes.productDetails, arguments: product),
                onAddToCart: () => controller.addToCart(product),
              );
            },
          );
        }),
      ),
    );
  }
}
