import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';

class MyOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<OrderModel> userOrders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders();
  }

  Future<void> fetchUserOrders() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';

      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .where((order) => uid.isEmpty || order.userId == uid || order.userId == 'guest')
          .toList();

      userOrders.assignAll(orders.isNotEmpty ? orders : snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList());
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
