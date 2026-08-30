import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';
import 'package:nectar_grocery/app/modules/cart/controllers/cart_controller.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class CategoryProductsController extends GetxController {
  final ProductRepository _repository = ProductRepository();
  late CategoryModel category;

  final RxList<ProductModel> categoryProducts = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is CategoryModel) {
      category = Get.arguments as CategoryModel;
    } else {
      category = CategoryModel(
        id: 'beverages',
        name: 'Beverages',
        imageUrl: '',
        backgroundColor: const Color(0xFFEDF7FC),
        borderColor: const Color(0xFFB7DFF5),
      );
    }
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    try {
      isLoading.value = true;
      final allProducts = await _repository.getAllProducts();

      if (category.id == 'exclusive_offer') {
        categoryProducts.assignAll(allProducts.where((p) => p.isExclusive).toList());
        return;
      }

      if (category.id == 'best_selling') {
        categoryProducts.assignAll(allProducts.where((p) => p.isBestSelling).toList());
        return;
      }

      // Filter by category id or name
      final filtered = allProducts.where((p) {
        final catLower = p.category.toLowerCase();
        final nameLower = category.name.toLowerCase();
        final idLower = category.id.toLowerCase();
        final pCatIdLower = p.categoryId.toLowerCase();
        return pCatIdLower == idLower ||
            catLower == nameLower ||
            catLower.contains(nameLower) ||
            nameLower.contains(catLower);
      }).toList();

      categoryProducts.assignAll(filtered);
    } catch (e) {
      debugPrint('Error loading category products: $e');
      categoryProducts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(ProductModel product) {
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().addToCart(product);
    } else {
      Utils.toastMessage('${product.name} added to cart', backgroundColor: Colors.green);
    }
  }
}
