import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Fetch all products strictly from Cloud Firestore
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching products from Firestore: $e");
      return [];
    }
  }

  /// Add product to Cloud Firestore
  Future<bool> addProduct(ProductModel product) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      await docRef.set(product.toMap());
      return true;
    } catch (e) {
      debugPrint("Error adding product to Firestore: $e");
      return false;
    }
  }

  /// Update existing product in Cloud Firestore
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update(product.toMap());
      return true;
    } catch (e) {
      debugPrint("Error updating product in Firestore: $e");
      return false;
    }
  }

  /// Delete product from Cloud Firestore
  Future<bool> deleteProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting product from Firestore: $e");
      return false;
    }
  }

  /// Toggle Favorite status in Cloud Firestore
  Future<void> toggleFavoriteStatus(String productId, bool currentFavoriteState) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'isFavorite': !currentFavoriteState,
      });
    } catch (e) {
      debugPrint("Error toggling favorite in Firestore: $e");
    }
  }
}
