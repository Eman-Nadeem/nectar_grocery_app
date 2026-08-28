import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/cart_item_model.dart';
import 'package:nectar_grocery/app/modules/cart/controllers/cart_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Your Cart is Empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore products and add them to your cart!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 30, thickness: 1),
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return _buildCartItemTile(item);
                  },
                ),
              ),

              // Bottom Checkout Button Bar
              Padding(
                padding: const EdgeInsets.all(25.0),
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
                    onPressed: () => _showCheckoutBottomSheet(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Go to Checkout',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF489E67),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '\$${controller.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Checkout Bottom Sheet Matching Screenshot 1 Mockup
  void _showCheckoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Title Bar with 'X' Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              // Row 1: Delivery Method
              _buildCheckoutRow(
                label: 'Delivery',
                trailing: 'Select Method',
                onTap: () {},
              ),
              const Divider(height: 20, thickness: 1),

              // Row 2: Payment Method
              _buildCheckoutRow(
                label: 'Payment',
                trailingIcon: Icons.credit_card,
                onTap: () {},
              ),
              const Divider(height: 20, thickness: 1),

              // Row 3: Promo Code
              _buildCheckoutRow(
                label: 'Promo Code',
                trailing: 'Pick discount',
                onTap: () {},
              ),
              const Divider(height: 20, thickness: 1),

              // Row 4: Total Cost
              _buildCheckoutRow(
                label: 'Total Cost',
                trailing: '\$${controller.totalPrice.toStringAsFixed(2)}',
                isBoldPrice: true,
                onTap: () {},
              ),
              const Divider(height: 20, thickness: 1),

              // Terms and Conditions Disclaimer
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    text: 'By placing an order you agree to our ',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Terms And Conditions',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Place Order Button
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
                    Get.back(); // Close bottom sheet
                    controller.placeOrder(); // Execute order placement
                  },
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutRow({
    required String label,
    String? trailing,
    IconData? trailingIcon,
    bool isBoldPrice = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                if (trailingIcon != null)
                  Icon(trailingIcon, color: AppColors.primary, size: 20)
                else if (trailing != null)
                  Text(
                    trailing,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isBoldPrice ? FontWeight.bold : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Cart Item Tile Matching Design Mockup
  Widget _buildCartItemTile(CartItemModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.cardBackground,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.product.imageUrl.startsWith('http')
                ? Image.network(item.product.imageUrl, fit: BoxFit.contain)
                : const Icon(Icons.shopping_basket, color: AppColors.primary, size: 35),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${item.product.unit}, Price',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    color: AppColors.border,
                    iconColor: AppColors.textSecondary,
                    onTap: () => controller.decrementQuantity(item),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    color: AppColors.primary,
                    iconColor: AppColors.primary,
                    onTap: () => controller.incrementQuantity(item),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => controller.removeItem(item),
              child: const Icon(Icons.close, color: Color(0xFF7C7C7C), size: 22),
            ),
            const SizedBox(height: 45),
            Text(
              '\$${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
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
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
