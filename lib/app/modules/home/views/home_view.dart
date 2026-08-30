import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/components/product_card.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/modules/cart/controllers/cart_controller.dart';
import 'package:nectar_grocery/app/modules/cart/views/cart_view.dart';
import 'package:nectar_grocery/app/modules/explore/views/explore_view.dart';
import 'package:nectar_grocery/app/modules/favourite/views/favourite_view.dart';
import 'package:nectar_grocery/app/modules/profile/views/profile_view.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        switch (controller.currentNavIndex.value) {
          case 0:
            return _buildShopTab(context);
          case 1:
            return const ExploreView();
          case 2:
            return const CartView();
          case 3:
            return const FavouriteView();
          case 4:
            return const ProfileView();
          default:
            return _buildShopTab(context);
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.currentNavIndex.value,
          onTap: controller.changeNavIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textPrimary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront, color: AppColors.primary),
              label: 'Shop',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.manage_search_outlined),
              activeIcon: Icon(Icons.manage_search, color: AppColors.primary),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Obx(() {
                if (Get.isRegistered<CartController>()) {
                  final cartController = Get.find<CartController>();
                  final count = cartController.totalItemCount;
                  if (count > 0) {
                    return Badge(
                      label: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.shopping_cart_outlined),
                    );
                  }
                }
                return const Icon(Icons.shopping_cart_outlined);
              }),
              activeIcon: const Icon(Icons.shopping_cart, color: AppColors.primary),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite, color: AppColors.primary),
              label: 'Favourite',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Account',
            ),
          ],
        );
      }),
    );
  }

  // --- SHOP TAB BODY ---
  Widget _buildShopTab(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/icons/orange_carrot.png',
                height: 30,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket, color: AppColors.primary, size: 30),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: AppColors.textPrimary, size: 18),
                const SizedBox(width: 5),
                Obx(
                  () => Text(
                    controller.selectedLocation.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Active Interactive Search Bar
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
                          onPressed: controller.clearSearch,
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

            // Content Area: Search Mode vs Default Shop Mode
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final query = controller.searchQuery.value.trim();

                // Search Results Grid
                if (query.isNotEmpty) {
                  final results = controller.searchResults;
                  if (results.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found for "$query"',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: results.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {
                      final product = results[index];
                      return ProductCard(
                        product: product,
                        onTap: () => Get.toNamed(Routes.productDetails, arguments: product),
                        onAddToCart: () => controller.addToCart(product),
                      );
                    },
                  );
                }

                // Default Shop Content
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Banner with Rich Vibrant Gradient Background
                      Container(
                        height: 135,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF53B175), // Nectar Primary Green
                              Color(0xFF2E7D32), // Forest Green
                              Color(0xFF1B5E20), // Deep Emerald
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3D53B175),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Decorative Background Accent Circles
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 40,
                              bottom: -40,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                            // Banner Text & Action Button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'SPECIAL PROMO',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Fresh Vegetables',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Get Up To 40% OFF',
                                          style: TextStyle(
                                            color: Color(0xFFFFD54F), // Amber Gold
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onPressed: () => controller.changeNavIndex(1),
                                    child: const Text(
                                      'Shop Now',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),

                      // 1. Exclusive Offer Section
                      _buildSectionHeader('Exclusive Offer', () {
                        Get.toNamed(
                          Routes.categoryProducts,
                          arguments: CategoryModel(
                            id: 'exclusive_offer',
                            name: 'Exclusive Offer',
                            imageUrl: '',
                            backgroundColor: const Color(0xFFE8F5E9),
                            borderColor: const Color(0xFFA5D6A7),
                          ),
                        );
                      }),
                      const SizedBox(height: 15),
                      Obx(() => _buildHorizontalProductList(controller.exclusiveProducts)),

                      const SizedBox(height: 25),

                      // 2. Best Selling Section
                      _buildSectionHeader('Best Selling', () {
                        Get.toNamed(
                          Routes.categoryProducts,
                          arguments: CategoryModel(
                            id: 'best_selling',
                            name: 'Best Selling',
                            imageUrl: '',
                            backgroundColor: const Color(0xFFFFF3E0),
                            borderColor: const Color(0xFFFFCC80),
                          ),
                        );
                      }),
                      const SizedBox(height: 15),
                      Obx(() => _buildHorizontalProductList(controller.bestSelling)),

                      const SizedBox(height: 25),

                      // 3. Groceries Section & All Products Grid
                      _buildSectionHeader('Groceries', () {
                        controller.changeNavIndex(1);
                      }),
                      const SizedBox(height: 15),
                      _buildCategoryList(),
                      const SizedBox(height: 20),
                      Obx(() => _buildAllProductsGrid(controller.allProducts)),

                      const SizedBox(height: 35),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('No products available.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return SizedBox(
      height: 248,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Get.toNamed(Routes.productDetails, arguments: product),
            onAddToCart: () => controller.addToCart(product),
          );
        },
      ),
    );
  }

  /// 2-Column Grid View to display ALL products regardless of category
  Widget _buildAllProductsGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('No products available.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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
          onAddToCart: () => controller.addToCart(product),
        );
      },
    );
  }

  // Horizontal Category Slider Reading Dynamically from Cloud Firestore
  Widget _buildCategoryList() {
    return SizedBox(
      height: 95,
      child: Obx(() {
        if (controller.categoryList.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categoryList.length,
          separatorBuilder: (context, index) => const SizedBox(width: 15),
          itemBuilder: (context, index) {
            final cat = controller.categoryList[index];
            return GestureDetector(
              onTap: () {
                Get.toNamed(Routes.categoryProducts, arguments: cat);
              },
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: cat.backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cat.borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: cat.imageUrl.startsWith('http')
                            ? Image.network(cat.imageUrl, fit: BoxFit.contain)
                            : const Icon(Icons.category_outlined, color: AppColors.primary, size: 30),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
