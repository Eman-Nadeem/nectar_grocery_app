import 'package:nectar_grocery/app/data/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  /// Calculates total price for this cart item line (price * quantity)
  double get totalPrice => product.price * quantity;
}
