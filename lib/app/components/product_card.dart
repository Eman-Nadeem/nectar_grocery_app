import 'package:flutter/material.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAddPressed;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 173,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Full Image
            Expanded(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildProductImage(product.imageUrl),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Product Title
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Unit Description
            Text(
              product.unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // Price and Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                GestureDetector(
                  onTap: onAddToCart ?? onAddPressed,
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(Icons.add, size: 24, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.shopping_basket_outlined,
            size: 55,
            color: AppColors.primary,
          );
        },
      );
    }

    if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.shopping_basket_outlined,
            size: 55,
            color: AppColors.primary,
          );
        },
      );
    }

    return const Icon(
      Icons.shopping_basket_outlined,
      size: 55,
      color: AppColors.primary,
    );
  }
}