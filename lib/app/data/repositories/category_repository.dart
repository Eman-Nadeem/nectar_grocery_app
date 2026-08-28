import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  /// Fetch categories strictly from Cloud Firestore (No fallbacks or seeding)
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching categories from Firestore: $e');
      return [];
    }
  }

  /// Add new category to Cloud Firestore
  Future<bool> addCategory(CategoryModel category) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      await docRef.set({
        'name': category.name,
        'imageUrl': category.imageUrl,
        'backgroundColor': category.backgroundColor.toARGB32(),
        'borderColor': category.borderColor.toARGB32(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  /// Update existing category in Cloud Firestore
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection(_collection).doc(category.id).update({
        'name': category.name,
        'imageUrl': category.imageUrl,
        'backgroundColor': category.backgroundColor.toARGB32(),
        'borderColor': category.borderColor.toARGB32(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  /// Delete category from Cloud Firestore
  Future<bool> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }
}
