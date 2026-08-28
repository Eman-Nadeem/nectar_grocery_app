import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Default fallback list of products to show if database is empty/offline/error
  static final List<ProductModel> fallbackProducts = [
    ProductModel(
      id: 'fallback_1',
      name: 'Organic Bananas',
      unit: '7pcs, Price',
      description: 'Fresh organic bananas rich in potassium.',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500',
      category: 'fruits',
      isExclusive: true,
      isBestSelling: false,
    ),
    ProductModel(
      id: 'fallback_2',
      name: 'Red Apple',
      unit: '1kg, Price',
      description: 'Crisp and juicy red apples fresh from orchards.',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
      category: 'fruits',
      isExclusive: true,
      isBestSelling: false,
    ),
    ProductModel(
      id: 'fallback_3',
      name: 'Bell Pepper Red',
      unit: '1kg, Price',
      description: 'Sweet and crunchy red bell peppers.',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500',
      category: 'vegetables',
      isExclusive: false,
      isBestSelling: true,
    ),
  ];

  /// Fetch all products from Cloud Firestore
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .get()
          .timeout(const Duration(seconds: 5));

      debugPrint("Firestore returned ${snapshot.docs.length} products from '$_collection' collection");

      if (snapshot.docs.isEmpty) {
        return fallbackProducts;
      }

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching products from Firestore: $e");
      return fallbackProducts;
    }
  }

  /// Fetch Exclusive Offers Products
  Future<List<ProductModel>> getExclusiveOffers() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isExclusive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isEmpty) {
        return fallbackProducts.where((p) => p.isExclusive).toList();
      }

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return fallbackProducts.where((p) => p.isExclusive).toList();
    }
  }

  /// Fetch Best Selling Products
  Future<List<ProductModel>> getBestSelling() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isBestSelling', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isEmpty) {
        return fallbackProducts.where((p) => p.isBestSelling).toList();
      }

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return fallbackProducts.where((p) => p.isBestSelling).toList();
    }
  }

  /// Fetch Grocery Items
  Future<List<ProductModel>> getGroceries() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: 'groceries')
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isEmpty) {
        return fallbackProducts.where((p) => p.category == 'groceries').toList();
      }

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return fallbackProducts.where((p) => p.category == 'groceries').toList();
    }
  }

  /// Function for adding new products to firestore (admin use)
  Future<bool> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).add(product.toMap());
      Utils.toastMessage(
        'Product added successfully',
        backgroundColor: Colors.green,
      );
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      Utils.toastMessage('Error adding product', backgroundColor: Colors.red);
      return false;
    }
  }

  /// Function for updating existing products (admin use)
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .update(product.toMap());
      Utils.toastMessage(
        'Product updated successfully',
        backgroundColor: Colors.green,
      );
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      Utils.toastMessage('Error updating product', backgroundColor: Colors.red);
      return false;
    }
  }
  
  /// Function for deleting products (admin use)
  Future<bool> deleteProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).delete();
      Utils.toastMessage(
        'Product deleted successfully',
        backgroundColor: Colors.green,
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      Utils.toastMessage('Error deleting product', backgroundColor: Colors.red);
      return false;
    }
  }
}
