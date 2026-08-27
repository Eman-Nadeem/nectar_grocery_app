import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/components/grocery_category_card.dart';
import 'package:nectar_grocery/app/components/product_card.dart';
import 'package:nectar_grocery/app/modules/home/controllers/home_controller.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Carrot Logo & Location)
                _buildHeader(),
                const SizedBox(height: 20),

                // 2. Search Bar
                _buildSearchBar(),
                const SizedBox(height: 20),

                // 3. Banner Carousel Card
                _buildBanner(),
                const SizedBox(height: 25),

                // 4. Exclusive Offer Section
                _buildSectionTitle('Exclusive Offer', onSeeAllTap: () {}),
                const SizedBox(height: 15),
                _buildHorizontalProductList(controller.exclusiveProducts),
                const SizedBox(height: 25),

                // 5. Best Selling Section
                _buildSectionTitle('Best Selling', onSeeAllTap: () {}),
                const SizedBox(height: 15),
                _buildHorizontalProductList(controller.bestSelling),
                const SizedBox(height: 25),

                // 6. Groceries Section Header
                _buildSectionTitle('Groceries', onSeeAllTap: () {}),
                const SizedBox(height: 15),

                // Groceries Categories Horizontal List
                _buildCategoryList(),
                const SizedBox(height: 15),

                // Groceries Products Horizontal List
                _buildHorizontalProductList(controller.groceryProducts),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentNavIndex.value,
          onTap: controller.changeNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textPrimary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront, color: AppColors.primary),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search, color: AppColors.primary),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart, color: AppColors.primary),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite, color: AppColors.primary),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

    // Header Widget (Logo + Location Pin + Admin Button)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/orange_carrot.png',
                  height: 30,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shopping_basket,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Color(0xFF4C4F4D), size: 20),
                  SizedBox(width: 5),
                  Text(
                    'Dhaka, Banassre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4C4F4D),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 28),
              tooltip: 'Admin Dashboard',
              onPressed: () => Get.toNamed(Routes.admin),
            ),
          ),
        ],
      ),
    );
  }


  // Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            hintText: 'Search Store',
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Banner Card Widget
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 115,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.green.shade100,
              Colors.orange.shade50,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 10,
              bottom: 10,
              top: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
                  fit: BoxFit.cover,
                  width: 120,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Fresh Vegetables',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Get Up To 40% OFF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Section Header Row
  Widget _buildSectionTitle(String title, {required VoidCallback onSeeAllTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onSeeAllTap,
            child: const Text(
              'See all',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal Product ListView
  Widget _buildHorizontalProductList(List products) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onAddToCart: () => controller.addToCart(product),
          );
        },
      ),
    );
  }

  // Horizontal Grocery Category Cards ListView
  Widget _buildCategoryList() {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return GroceryCategoryCard(
            title: category.name,
            backgroundColor: category.backgroundColor,
            imagePath: category.imageUrl,
          );
        },
      ),
    );
  }
}
