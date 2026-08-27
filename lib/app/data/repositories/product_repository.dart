import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';

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
    ProductModel(
      id: 'fallback_4',
      name: 'Ginger',
      unit: '250gm, Price',
      description: 'Fresh organic ginger root.',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500',
      category: 'groceries',
      isExclusive: false,
      isBestSelling: true,
    ),
    ProductModel(
      id: 'fallback_5',
      name: 'Beef Bone',
      unit: '1kg, Price',
      description: 'Fresh beef bone cuts for soup and broth.',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
      category: 'meat',
      isExclusive: false,
      isBestSelling: false,
    ),
    ProductModel(
      id: 'fallback_6',
      name: 'Broiler Chicken',
      unit: '1kg, Price',
      description: 'Fresh farm broiler chicken.',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=500',
      category: 'groceries',
      isExclusive: false,
      isBestSelling: false,
    ),
  ];

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isEmpty) {
        // Trigger seeding asynchronously, return fallback products
        unawaited(seedInitialProductsIfEmpty());
        return fallbackProducts;
      }

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error or timeout fetching products from Firestore: $e");
      return fallbackProducts;
    }
  }

  /// Helper to fire-and-forget seeding without blocking
  void unawaited(Future<void> future) {
    future.catchError((e) {
      debugPrint("Background seeding error: $e");
    });
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

  /// Seed initial products if collection is empty
  Future<void> seedInitialProductsIfEmpty() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 4));
      
      if (snapshot.docs.isEmpty) {
        final List<Map<String, dynamic>> initialProducts = [
          {
            'name': 'Organic Bananas',
            'unit': '7pcs, Price',
            'description': 'Fresh organic bananas rich in potassium.',
            'price': 4.99,
            'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500',
            'category': 'fruits',
            'isExclusive': true,
            'isBestSelling': false,
          },
          {
            'name': 'Red Apple',
            'unit': '1kg, Price',
            'description': 'Crisp and juicy red apples fresh from orchards.',
            'price': 4.99,
            'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
            'category': 'fruits',
            'isExclusive': true,
            'isBestSelling': false,
          },
          {
            'name': 'Bell Pepper Red',
            'unit': '1kg, Price',
            'description': 'Sweet and crunchy red bell peppers.',
            'price': 4.99,
            'imageUrl': 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500',
            'category': 'vegetables',
            'isExclusive': false,
            'isBestSelling': true,
          },
          {
            'name': 'Ginger',
            'unit': '250gm, Price',
            'description': 'Fresh organic ginger root.',
            'price': 4.99,
            'imageUrl': 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500',
            'category': 'groceries',
            'isExclusive': false,
            'isBestSelling': true,
          },
          {
            'name': 'Beef Bone',
            'unit': '1kg, Price',
            'description': 'Fresh beef bone cuts for soup and broth.',
            'price': 4.99,
            'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
            'category': 'meat',
            'isExclusive': false,
            'isBestSelling': false,
          },
          {
            'name': 'Broiler Chicken',
            'unit': '1kg, Price',
            'description': 'Fresh farm broiler chicken.',
            'price': 4.99,
            'imageUrl': 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=500',
            'category': 'groceries',
            'isExclusive': false,
            'isBestSelling': false,
          },
        ];
        for (var product in initialProducts) {
          await _firestore.collection(_collection).add(product);
        }
      }
    } catch (e) {
      debugPrint("Error seeding initial products: $e");
    }
  }
}


