import 'package:flutter/material.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class GroceryCategoryCard extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String imagePath;

  const GroceryCategoryCard({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      height: 105,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildImage(imagePath),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E423F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          path,
          height: 70,
          width: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.shopping_bag_outlined,
            size: 40,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return Image.asset(
      path,
      height: 70,
      width: 70,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.shopping_bag_outlined,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}