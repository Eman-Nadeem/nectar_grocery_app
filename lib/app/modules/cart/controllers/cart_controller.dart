import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/cart_item_model.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/order_repository.dart';
import 'package:nectar_grocery/app/modules/cart/views/order_accepted_view.dart';
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

  /// Place Order and save to Cloud Firestore orders collection
  Future<void> placeOrder() async {
    if (cartItems.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final orderItems = cartItems
        .map((item) => OrderItem(
              productId: item.product.id,
              productName: item.product.name,
              price: item.product.price,
              quantity: item.quantity,
              imageUrl: item.product.imageUrl,
            ))
        .toList();

    final newOrder = OrderModel(
      id: '',
      userId: user?.uid ?? 'guest',
      userEmail: user?.email ?? 'guest@nectar.com',
      items: orderItems,
      totalAmount: totalPrice,
      deliveryMethod: 'Select Method',
      paymentMethod: 'Credit Card',
      status: 'Accepted',
      createdAt: DateTime.now(),
    );

    final OrderRepository orderRepo = OrderRepository();
    final success = await orderRepo.createOrder(newOrder);

    if (success) {
      clearCart();
      Get.to(() => const OrderAcceptedView());
    } else {
      Utils.toastMessage('Order creation failed. Please try again.', backgroundColor: Colors.red);
    }
  }
}
