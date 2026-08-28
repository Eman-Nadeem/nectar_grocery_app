import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/category_repository.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';
import 'package:nectar_grocery/app/modules/cart/controllers/cart_controller.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final RxBool isLoading = true.obs;
  final RxInt currentNavIndex = 0.obs;
  final RxString selectedLocation = ' '.obs;

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> exclusiveProducts = <ProductModel>[].obs;
  final RxList<ProductModel> bestSelling = <ProductModel>[].obs;
  final RxList<ProductModel> groceryProducts = <ProductModel>[].obs;
  final RxList<CategoryModel> categoryList = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    loadUserLocation();
  }

  /// Fetches saved zone & area from Firestore users collection
  Future<void> loadUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final zone = data['zone'] ?? '';
          final area = data['area'] ?? '';

          if (zone.isNotEmpty &&
              area.isNotEmpty &&
              area != 'Types of your area' &&
              area != 'Select your area') {
            selectedLocation.value = '$zone, $area';
          } else if (zone.isNotEmpty) {
            selectedLocation.value = zone;
          }
        }
      } catch (e) {
        debugPrint('Error loading user location: $e');
      }
    }
  }

  // Fetch all home data strictly from Cloud Firestore
  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;

      final fetchedProducts = await _productRepository.getAllProducts();
      final fetchedCategories = await _categoryRepository.getCategories();

      allProducts.assignAll(fetchedProducts);
      categoryList.assignAll(fetchedCategories);

      exclusiveProducts.assignAll(
        fetchedProducts.where((p) => p.isExclusive).toList(),
      );
      bestSelling.assignAll(
        fetchedProducts.where((p) => p.isBestSelling).toList(),
      );
      groceryProducts.assignAll(
        fetchedProducts
            .where((p) => p.category.toLowerCase() == 'groceries')
            .toList(),
      );
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<ProductModel> get searchResults {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return [];
    return allProducts
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // Change bottom navigation index
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  // Add product to cart
  void addToCart(ProductModel product) {
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().addToCart(product);
    } else {
      Utils.toastMessage(
        '${product.name} added to cart',
        backgroundColor: Colors.green,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
