import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/utils/crashlytics_service.dart';

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
    } catch (e, stack) {
      debugPrint("Error fetching products from Firestore: $e");
      CrashlyticsService.recordError(e, stack, reason: 'Firestore fetch all products failed');
      return [];
    }
  }

  /// Add product to Cloud Firestore
  Future<bool> addProduct(ProductModel product) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      await docRef.set(product.toMap());
      return true;
    } catch (e, stack) {
      debugPrint("Error adding product to Firestore: $e");
      CrashlyticsService.recordError(e, stack, reason: 'Firestore add product failed');
      return false;
    }
  }

  /// Update existing product in Cloud Firestore
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update(product.toMap());
      return true;
    } catch (e, stack) {
      debugPrint("Error updating product in Firestore: $e");
      CrashlyticsService.recordError(e, stack, reason: 'Firestore update product failed');
      return false;
    }
  }

  /// Delete product from Cloud Firestore
  Future<bool> deleteProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).delete();
      return true;
    } catch (e, stack) {
      debugPrint("Error deleting product from Firestore: $e");
      CrashlyticsService.recordError(e, stack, reason: 'Firestore delete product failed');
      return false;
    }
  }

  /// Toggle Favorite status for a specific user in Cloud Firestore
  Future<void> toggleUserFavorite(String userId, String productId, bool isFavorite) async {
    if (userId.isEmpty) return;
    try {
      final userFavRef = _firestore.collection('users').doc(userId).collection('favorites').doc(productId);
      if (isFavorite) {
        await userFavRef.set({'productId': productId, 'addedAt': FieldValue.serverTimestamp()});
      } else {
        await userFavRef.delete();
      }
    } catch (e, stack) {
      debugPrint("Error toggling user favorite in Firestore: $e");
      CrashlyticsService.recordError(e, stack, reason: 'Firestore toggle user favorite failed');
    }
  }

  /// Get list of favorite product IDs for a specific user
  Future<Set<String>> getUserFavoriteIds(String userId) async {
    if (userId.isEmpty) return {};
    try {
      final snapshot = await _firestore.collection('users').doc(userId).collection('favorites').get();
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e, stack) {
      debugPrint("Error fetching user favorite IDs: $e");
      CrashlyticsService.recordError(e, stack, reason: 'Firestore fetch user favorite IDs failed');
      return {};
    }
  }

  /// Legacy Toggle Favorite status
  Future<void> toggleFavoriteStatus(String productId, bool currentFavoriteState) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'isFavorite': !currentFavoriteState,
      });
    } catch (e, stack) {
      debugPrint("Error toggling favorite in Firestore: $e");
      CrashlyticsService.recordError(e, stack, reason: 'Firestore toggle legacy favorite status failed');
    }
  }
}
