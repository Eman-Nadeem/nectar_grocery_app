import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/components/product_card.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/modules/cart/controllers/cart_controller.dart';
import 'package:nectar_grocery/app/modules/explore/controllers/explore_controller.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Find Products',
          style: TextStyle(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Search Input Field
              TextField(
                controller: controller.searchController,
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search Store',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
                  suffixIcon: Obx(
                    () => controller.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F3F2),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Search Results OR Category Grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final query = controller.searchQuery.value.trim();

                  // Search Mode: Show Product Cards
                  if (query.isNotEmpty) {
                    final products = controller.filteredProducts;
                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          'No products found for "$query"',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Get.toNamed(Routes.productDetails, arguments: product),
                          onAddToCart: () {
                            if (Get.isRegistered<CartController>()) {
                              Get.find<CartController>().addToCart(product);
                            }
                          },
                        );
                      },
                    );
                  }

                  // Default Mode: Show Category Grid
                  final categories = controller.filteredCategories;
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories available.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: categories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(category);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.categoryProducts, arguments: category);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: category.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: category.borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: category.imageUrl.startsWith('http')
                  ? Image.network(category.imageUrl, fit: BoxFit.contain)
                  : const Icon(Icons.category_outlined, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
