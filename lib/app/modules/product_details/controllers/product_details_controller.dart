import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';
import 'package:nectar_grocery/app/modules/cart/controllers/cart_controller.dart';
import 'package:nectar_grocery/app/modules/favourite/controllers/favourite_controller.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class ProductDetailsController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  late ProductModel product;

  final RxInt quantity = 1.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isProductDetailExpanded = true.obs;
  final RxBool isNutritionExpanded = false.obs;
  final RxBool isReviewExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProductModel) {
      product = Get.arguments as ProductModel;
    } else {
      product = ProductModel(
        id: '',
        name: 'Organic Bananas',
        unit: '7pcs, Price',
        description: 'Apples are nutritious. Apples may be good for weight loss.',
        price: 4.99,
        imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500',
        category: 'fruits',
      );
    }
    _syncFavoriteState();
  }

  void _syncFavoriteState() {
    if (Get.isRegistered<FavouriteController>()) {
      final favController = Get.find<FavouriteController>();
      isFavorite.value = favController.favoriteItems.any((p) => p.id == product.id) || product.isFavorite;
    } else {
      isFavorite.value = product.isFavorite;
    }
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  Future<void> toggleFavorite() async {
    if (Get.isRegistered<FavouriteController>()) {
      await Get.find<FavouriteController>().toggleFavorite(product);
      isFavorite.value = product.isFavorite;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';
      if (uid.isEmpty) {
        Utils.toastMessage('Please sign in to save favorites', backgroundColor: Colors.orange);
        return;
      }
      isFavorite.value = !isFavorite.value;
      product.isFavorite = isFavorite.value;
      await _productRepository.toggleUserFavorite(uid, product.id, isFavorite.value);
      Utils.toastMessage(
        isFavorite.value
            ? '${product.name} added to favorites'
            : '${product.name} removed from favorites',
        backgroundColor: isFavorite.value ? Colors.green : Colors.orange,
      );
    }
  }

  void addToBasket() {
    if (Get.isRegistered<CartController>()) {
      final cart = Get.find<CartController>();
      for (int i = 0; i < quantity.value; i++) {
        cart.addToCart(product);
      }
    } else {
      Utils.toastMessage(
        '${quantity.value}x ${product.name} added to basket',
        backgroundColor: Colors.green,
      );
    }
  }
}
