import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';

class AnalyticsService {
  static final FirebaseAnalytics instance = FirebaseAnalytics.instance;
  static final FirebaseInAppMessaging _inAppMessaging = FirebaseInAppMessaging.instance;

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

  /// Custom In-App Event Logger (Triggers Firebase In-App Messaging campaigns)
  static Future<void> logInAppEvent(String eventName, {Map<String, Object>? parameters}) async {
    try {
      await instance.logEvent(name: eventName, parameters: parameters);
      await _inAppMessaging.triggerEvent(eventName);
      debugPrint('[In-App Event] Logged & Triggered: $eventName');
    } catch (e) {
      debugPrint('[Analytics Error] In-App Event ($eventName): $e');
    }
  }

  /// Triggered when customer basket reaches free delivery threshold
  static Future<void> logUnlockedFreeDelivery(double cartTotal) async {
    await logInAppEvent('unlocked_free_delivery', parameters: {
      'cart_total': cartTotal,
    });
  }

  /// Triggered when user marks a product as favorite
  static Future<void> logItemFavorited(ProductModel product) async {
    await logInAppEvent('item_favorited', parameters: {
      'product_id': product.id,
      'product_name': product.name,
      'price': product.price,
    });
  }
}

