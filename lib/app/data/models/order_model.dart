import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String deliveryMethod;
  final String paymentMethod;
  final String status; // 'Accepted', 'Processing', 'Delivered', 'Cancelled'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    this.deliveryMethod = 'Select Method',
    this.paymentMethod = 'Credit Card',
    this.status = 'Accepted',
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      items: rawItems.map((item) => OrderItem.fromMap(item as Map<String, dynamic>)).toList(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      deliveryMethod: map['deliveryMethod'] ?? 'Select Method',
      paymentMethod: map['paymentMethod'] ?? 'Credit Card',
      status: map['status'] ?? 'Accepted',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
