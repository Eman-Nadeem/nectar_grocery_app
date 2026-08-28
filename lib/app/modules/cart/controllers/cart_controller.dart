import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/cart_item_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  /// Calculates grand total price of all items in cart
  double get totalPrice => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Calculates total quantity of items in cart
  int get totalItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Add product to cart (or increment if already added)
  void addToCart(ProductModel product) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel(product: product, quantity: 1));
    }
    Utils.toastMessage('${product.name} added to cart', backgroundColor: Colors.green);
  }

  /// Increment quantity
  void incrementQuantity(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
  }

  /// Decrement quantity (removes if quantity drops below 1)
  void decrementQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      removeItem(item);
    }
  }

  /// Remove item completely from cart
  void removeItem(CartItemModel item) {
    cartItems.removeWhere((element) => element.product.id == item.product.id);
    Utils.toastMessage('${item.product.name} removed from cart', backgroundColor: Colors.orange);
  }

  /// Clear entire cart
  void clearCart() {
    cartItems.clear();
  }
}
