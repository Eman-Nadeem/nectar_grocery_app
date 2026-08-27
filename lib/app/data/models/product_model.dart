class ProductModel {
  final String id;
  final String name;
  final String unit;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isExclusive;
  final bool isBestSelling;

  ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isExclusive = false,
    this.isBestSelling = false,
  });

/// Factory constructor to convert Firestore Document Map into ProductModel object
  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      unit: map['unit'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isExclusive: map['isExclusive'] ?? false,
      isBestSelling: map['isBestSelling'] ?? false,
    );
  }

/// Converts ProductModel object into Firestore JSON Map for uploading/saving
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isExclusive': isExclusive,
      'isBestSelling': isBestSelling,
    };
  }
}
