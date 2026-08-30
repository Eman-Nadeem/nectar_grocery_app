import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';
import 'package:nectar_grocery/app/utils/crashlytics_service.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  /// Save new order in Cloud Firestore
  Future<bool> createOrder(OrderModel order) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      await docRef.set(order.toMap());
      return true;
    } catch (e, stack) {
      debugPrint('Error creating order in Firestore: $e');
      CrashlyticsService.recordError(e, stack, reason: 'Firestore create order failed');
      return false;
    }
  }

  /// Fetch all orders for Admin
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stack) {
      debugPrint('Error fetching all orders: $e');
      CrashlyticsService.recordError(e, stack, reason: 'Firestore fetch all orders failed');
      return [];
    }
  }

  /// Update order status in Cloud Firestore
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': newStatus,
      });
      return true;
    } catch (e, stack) {
      debugPrint('Error updating order status: $e');
      CrashlyticsService.recordError(e, stack, reason: 'Firestore update order status failed');
      return false;
    }
  }
}
