import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final Color backgroundColor;
  final Color borderColor;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.backgroundColor,
    this.borderColor = const Color(0xFF53B175),
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      backgroundColor: _parseColor(map['backgroundColor'], const Color(0xFFEEF7F1)),
      borderColor: _parseColor(map['borderColor'], const Color(0xFF53B175)),
    );
  }

  static Color _parseColor(dynamic val, Color defaultColor) {
    if (val is int) return Color(val);
    if (val is String && val.startsWith('#')) {
      final hex = val.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return defaultColor;
  }
}
