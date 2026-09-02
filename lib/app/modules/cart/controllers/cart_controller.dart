import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/cart_item_model.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/order_repository.dart';
import 'package:nectar_grocery/app/modules/cart/views/order_accepted_view.dart';
import 'package:nectar_grocery/app/modules/profile/controllers/profile_controller.dart';
import 'package:nectar_grocery/app/utils/analytics_service.dart';
import 'package:nectar_grocery/app/utils/remote_config_service.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  final RxString selectedDeliveryMethod = 'Standard Delivery (\$3.00)'.obs;
  final RxString selectedPaymentMethod = 'Cash on Delivery'.obs;

  final List<String> deliveryOptions = const [
    'Standard Delivery (\$3.00)',
    'Express Delivery (\$5.00)',
    'Store Pickup',
  ];

  final List<String> paymentOptions = const [
    'Cash on Delivery',
    'Credit / Debit Card',
    'EasyPaisa / JazzCash',
  ];

  void setDeliveryMethod(String method) {
    selectedDeliveryMethod.value = method;
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  /// Remote Config threshold for free delivery
  double get freeDeliveryThreshold => RemoteConfigService.instance.freeDeliveryThreshold;

  /// Calculates subtotal of items in cart
  double get itemsSubtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Check if free delivery threshold is reached
  bool get isFreeDeliveryUnlocked => itemsSubtotal >= freeDeliveryThreshold && itemsSubtotal > 0;

  /// Amount remaining to unlock free delivery
  double get remainingForFreeDelivery {
    final diff = freeDeliveryThreshold - itemsSubtotal;
    return diff > 0 ? diff : 0.0;
  }

  /// Delivery fee calculation logic:
  /// - Store Pickup: $0.00
  /// - Standard Delivery: FREE if itemsSubtotal >= threshold, else $3.00
  /// - Express Delivery: $5.00
  double get deliveryFee {
    final method = selectedDeliveryMethod.value.toLowerCase();
    if (method.contains('pickup')) {
      return 0.0;
    }
    if (method.contains('express')) {
      return 5.0;
    }
    // Standard delivery
    return isFreeDeliveryUnlocked ? 0.0 : 3.0;
  }

  /// Resolved display text for selected delivery method
  String get resolvedDeliveryMethodText {
    final method = selectedDeliveryMethod.value;
    if (method.toLowerCase().contains('pickup')) {
      return 'Store Pickup (Free)';
    }
    if (method.toLowerCase().contains('express')) {
      return 'Express Delivery (\$5.00)';
    }
    return isFreeDeliveryUnlocked
        ? 'Standard Delivery (FREE)'
        : 'Standard Delivery (\$3.00)';
  }

  /// Calculates grand total price of all items in cart + delivery fee
  double get totalPrice => itemsSubtotal + deliveryFee;

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
    AnalyticsService.logAddToCart(product);
    
    // In-App Event trigger when cart unlocks free delivery threshold set via Remote Config
    _checkFreeDeliveryEventTrigger();
    
    Utils.toastMessage('${product.name} added to cart', backgroundColor: Colors.green);
  }

  /// Increment quantity
  void incrementQuantity(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
    _checkFreeDeliveryEventTrigger();
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

  void _checkFreeDeliveryEventTrigger() {
    if (isFreeDeliveryUnlocked) {
      AnalyticsService.logUnlockedFreeDelivery(itemsSubtotal);
    }
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

    String resolvedEmail = user?.email ?? '';
    if (resolvedEmail.isEmpty && Get.isRegistered<ProfileController>()) {
      resolvedEmail = Get.find<ProfileController>().userEmail.value;
    }
    if (resolvedEmail.isEmpty) {
      resolvedEmail = 'guest@nectar.com';
    }

    final newOrder = OrderModel(
      id: '',
      userId: user?.uid ?? 'guest',
      userEmail: resolvedEmail,
      items: orderItems,
      totalAmount: totalPrice,
      deliveryMethod: resolvedDeliveryMethodText,
      paymentMethod: selectedPaymentMethod.value,
      status: 'Accepted',
      createdAt: DateTime.now(),
    );

    final OrderRepository orderRepo = OrderRepository();
    final success = await orderRepo.createOrder(newOrder);

    if (success) {
      AnalyticsService.logPurchase(newOrder);
      AnalyticsService.logInAppEvent('order_placed_success');
      clearCart();
      Get.to(() => const OrderAcceptedView());
    } else {
      Utils.toastMessage('Order creation failed. Please try again.', backgroundColor: Colors.red);
    }
  }
}
