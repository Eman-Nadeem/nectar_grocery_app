import 'package:firebase_auth/firebase_auth.dart';
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
    FirebaseAuth.instance.authStateChanges().listen((user) {
      loadFavorites();
    });
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    if (uid.isEmpty) {
      favoriteItems.clear();
      isLoading.value = false;
      return;
    }

    try {
      final userFavIds = await _productRepository.getUserFavoriteIds(uid);
      final allProducts = await _productRepository.getAllProducts();
      for (final p in allProducts) {
        p.isFavorite = userFavIds.contains(p.id);
      }
      final favs = allProducts.where((p) => p.isFavorite).toList();
      favoriteItems.assignAll(favs);
    } catch (e) {
      debugPrint('Error loading user favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    if (uid.isEmpty) {
      Utils.toastMessage('Please sign in to save favorites', backgroundColor: Colors.orange);
      return;
    }

    product.isFavorite = !product.isFavorite;
    await _productRepository.toggleUserFavorite(uid, product.id, product.isFavorite);
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
