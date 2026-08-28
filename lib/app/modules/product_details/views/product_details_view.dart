import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/product_details/controllers/product_details_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final product = controller.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Hero Container with Background & Image
            _buildHeroHeader(context),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title & Favorite Heart Toggle Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Obx(
                        () => GestureDetector(
                          onTap: controller.toggleFavorite,
                          child: Icon(
                            controller.isFavorite.value
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: controller.isFavorite.value
                                ? Colors.red
                                : const Color(0xFF7C7C7C),
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 3. Unit Description
                  Text(
                    product.unit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 4. Quantity Controls & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Controls [ - ]  count  [ + ]
                      Row(
                        children: [
                          _buildQuantityBtn(
                            icon: Icons.remove,
                            iconColor: AppColors.textSecondary,
                            onTap: controller.decrementQuantity,
                          ),
                          Obx(
                            () => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Text(
                                '${controller.quantity.value}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          _buildQuantityBtn(
                            icon: Icons.add,
                            iconColor: AppColors.primary,
                            onTap: controller.incrementQuantity,
                          ),
                        ],
                      ),

                      // Calculated Price
                      Obx(
                        () => Text(
                          '\$${(product.price * controller.quantity.value).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Divider(height: 1, thickness: 1),

                  // 5. Product Detail Accordion
                  _buildProductDetailAccordion(),
                  const Divider(height: 1, thickness: 1),

                  // 6. Nutritions Accordion
                  _buildNutritionAccordion(),
                  const Divider(height: 1, thickness: 1),

                  // 7. Review Accordion
                  _buildReviewAccordion(),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          child: SizedBox(
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
              onPressed: controller.addToBasket,
              child: const Text(
                'Add To Basket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Top Hero Header Container with Back & Share buttons
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F3F2),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    onPressed: () => Get.back(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.ios_share, color: Colors.black, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'product_${controller.product.id}',
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildProductImage(controller.product.imageUrl),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Accordion 1: Product Detail
  Widget _buildProductDetailAccordion() {
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: () => controller.isProductDetailExpanded.value =
                !controller.isProductDetailExpanded.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product Detail',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Icon(
                    controller.isProductDetailExpanded.value
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (controller.isProductDetailExpanded.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                controller.product.description.isNotEmpty
                    ? controller.product.description
                    : 'Apples are nutritious. Apples may be good for weight loss. Apples may be good for your heart. As part of a healthful and varied diet.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Accordion 2: Nutritions
  Widget _buildNutritionAccordion() {
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: () => controller.isNutritionExpanded.value =
                !controller.isNutritionExpanded.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nutritions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          '100gr',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        controller.isNutritionExpanded.value
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (controller.isNutritionExpanded.value)
            const Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: Text(
                'Rich in Potassium, Vitamin C, Dietary Fiber, and essential antioxidants.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Accordion 3: Reviews
  Widget _buildReviewAccordion() {
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: () => controller.isReviewExpanded.value =
                !controller.isReviewExpanded.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            color: Color(0xFFF3603F),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        controller.isReviewExpanded.value
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (controller.isReviewExpanded.value)
            const Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: Text(
                '5.0 out of 5 stars based on customer reviews. High quality, fresh farm produce!',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.shopping_basket_outlined,
          size: 90,
          color: AppColors.primary,
        ),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.shopping_basket_outlined,
        size: 90,
        color: AppColors.primary,
      ),
    );
  }
}
