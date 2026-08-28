class ProductModel {
  final String id;
  final String name;
  final String unit;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String categoryId;
  final bool isExclusive;
  final bool isBestSelling;
  bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.categoryId = '',
    this.isExclusive = false,
    this.isBestSelling = false,
    this.isFavorite = false,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      unit: map['unit'] ?? '1kg, Price',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      categoryId: map['categoryId'] ?? '',
      isExclusive: map['isExclusive'] ?? false,
      isBestSelling: map['isBestSelling'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'categoryId': categoryId,
      'isExclusive': isExclusive,
      'isBestSelling': isBestSelling,
      'isFavorite': isFavorite,
    };
  }
}