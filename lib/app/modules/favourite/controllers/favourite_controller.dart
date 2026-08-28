import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';
import 'package:nectar_grocery/app/modules/cart/controllers/cart_controller.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class FavouriteController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  final RxList<ProductModel> favoriteItems = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    final allProducts = await _productRepository.getAllProducts();
    final favs = allProducts.where((p) => p.isFavorite).toList();
    favoriteItems.assignAll(favs);
    isLoading.value = false;
  }

  Future<void> toggleFavorite(ProductModel product) async {
    product.isFavorite = !product.isFavorite;
    await _productRepository.toggleFavoriteStatus(product.id, !product.isFavorite);
    if (!product.isFavorite) {
      favoriteItems.removeWhere((p) => p.id == product.id);
    } else if (!favoriteItems.any((p) => p.id == product.id)) {
      favoriteItems.add(product);
    }
    Utils.toastMessage(
      product.isFavorite ? '${product.name} added to favorites' : '${product.name} removed from favorites',
      backgroundColor: product.isFavorite ? Colors.green : Colors.orange,
    );
  }

  void addAllToCart() {
    if (favoriteItems.isEmpty) return;
    if (Get.isRegistered<CartController>()) {
      final cart = Get.find<CartController>();
      for (final item in favoriteItems) {
        cart.addToCart(item);
      }
      Utils.toastMessage('All favorite items added to cart!', backgroundColor: Colors.green);
    }
  }
}
