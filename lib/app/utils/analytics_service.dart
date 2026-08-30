import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';

class AnalyticsService {
  static final FirebaseAnalytics instance = FirebaseAnalytics.instance;

  /// Log screen transition
  static Future<void> logScreenView(String screenName) async {
    try {
      await instance.logScreenView(screenName: screenName);
      debugPrint('[Analytics] Screen View: $screenName');
    } catch (e) {
      debugPrint('[Analytics Error] Screen View: $e');
    }
  }

  /// Log user login
  static Future<void> logLogin({required String loginMethod}) async {
    try {
      await instance.logLogin(loginMethod: loginMethod);
      debugPrint('[Analytics] User Login: $loginMethod');
    } catch (e) {
      debugPrint('[Analytics Error] Login: $e');
    }
  }

  /// Log user signup
  static Future<void> logSignUp({required String signUpMethod}) async {
    try {
      await instance.logSignUp(signUpMethod: signUpMethod);
      debugPrint('[Analytics] User Sign Up: $signUpMethod');
    } catch (e) {
      debugPrint('[Analytics Error] Sign Up: $e');
    }
  }

  /// Log product view details
  static Future<void> logViewItem(ProductModel product) async {
    try {
      await instance.logViewItem(
        currency: 'USD',
        value: product.price,
        items: [
          AnalyticsEventItem(
            itemId: product.id,
            itemName: product.name,
            itemCategory: product.category,
            price: product.price,
          ),
        ],
      );
      debugPrint('[Analytics] View Item: ${product.name}');
    } catch (e) {
      debugPrint('[Analytics Error] View Item: $e');
    }
  }

  /// Log add product to cart
  static Future<void> logAddToCart(ProductModel product, {int quantity = 1}) async {
    try {
      await instance.logAddToCart(
        currency: 'USD',
        value: product.price * quantity,
        items: [
          AnalyticsEventItem(
            itemId: product.id,
            itemName: product.name,
            itemCategory: product.category,
            price: product.price,
            quantity: quantity,
          ),
        ],
      );
      debugPrint('[Analytics] Add to Cart: ${product.name} (x$quantity)');
    } catch (e) {
      debugPrint('[Analytics Error] Add to Cart: $e');
    }
  }

  /// Log product search query
  static Future<void> logSearch(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    try {
      await instance.logSearch(searchTerm: searchTerm.trim());
      debugPrint('[Analytics] Search: $searchTerm');
    } catch (e) {
      debugPrint('[Analytics Error] Search: $e');
    }
  }

  /// Log completed order purchase
  static Future<void> logPurchase(OrderModel order) async {
    try {
      await instance.logPurchase(
        currency: 'USD',
        value: order.totalAmount,
        transactionId: order.id,
        items: order.items
            .map((item) => AnalyticsEventItem(
                  itemId: item.productId,
                  itemName: item.productName,
                  price: item.price,
                  quantity: item.quantity,
                ))
            .toList(),
      );
      debugPrint('[Analytics] Purchase Completed: \$${order.totalAmount}');
    } catch (e) {
      debugPrint('[Analytics Error] Purchase: $e');
    }
  }
}
