import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  final RxBool isLoading = true.obs;
  final RxInt currentNavIndex = 0.obs;
  final RxString selectedLocation = 'Dhaka, Banasree'.obs;

  final RxList<ProductModel> exclusiveProducts = <ProductModel>[].obs;
  final RxList<ProductModel> bestSelling = <ProductModel>[].obs;
  final RxList<ProductModel> groceryProducts = <ProductModel>[].obs;


 // list of categories for home screen
  final List<CategoryModel> categories = [
    CategoryModel(
      id: '1',
      name: 'pulses',
      imageUrl: 'https://images.unsplash.com/photo-1515543904379-3d757afe72e2?w=500',
      backgroundColor: const Color(0xFFFEF6ED),
    ),
    CategoryModel(
      id: '2',
      name: 'Rice',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
      backgroundColor: const Color(0xFFE6F7ED),
    ),
    CategoryModel(
      id: '3',
      name: 'Nuts',
      imageUrl: 'https://images.unsplash.com/photo-1526685162656-2cc652040199?w=500',
      backgroundColor: const Color(0xFFFEF6ED),
    ),
    CategoryModel(
      id: '4',
      name: 'Oil',
      imageUrl: 'https://images.unsplash.com/photo-1558403171-06e8c4f18f56?w=500',
      backgroundColor: const Color(0xFFE6F7ED),
    ),
    CategoryModel(
      id: '5',
      name: 'Salt',
      imageUrl: 'https://images.unsplash.com/photo-1578350481918-32d714777069?w=500',
      backgroundColor: const Color(0xFFFEF6ED),
    ),
    CategoryModel(
      id: '6',
      name: 'Flour',
      imageUrl: 'https://images.unsplash.com/photo-1558403171-06e8c4f18f56?w=500',
      backgroundColor: const Color(0xFFFEF6ED),
    ),
    CategoryModel(
      id: '7',
      name: 'Sugar',
      imageUrl: 'https://images.unsplash.com/photo-1515543904379-3d757afe72e2?w=500',
      backgroundColor: const Color(0xFFFEF6ED),
    ),
    CategoryModel(
      id: '8',
      name: 'Tea',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
      backgroundColor: const Color(0xFFE6F7ED),
    ),
  ];

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
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final zone = data['zone'] ?? '';
          final area = data['area'] ?? '';

          if (zone.isNotEmpty && area.isNotEmpty && area != 'Types of your area') {
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

  //fetch all home data
  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;

      // Single-pass fetch for all products
      final allProducts = await _productRepository.getAllProducts();

      final exclusive = allProducts.where((p) => p.isExclusive).toList();
      final bestSellingProducts = allProducts.where((p) => p.isBestSelling).toList();
      final groceries = allProducts.where((p) => p.category == 'groceries').toList();

      exclusiveProducts.assignAll(
        exclusive.isNotEmpty
            ? exclusive
            : ProductRepository.fallbackProducts.where((p) => p.isExclusive).toList(),
      );
      bestSelling.assignAll(
        bestSellingProducts.isNotEmpty
            ? bestSellingProducts
            : ProductRepository.fallbackProducts.where((p) => p.isBestSelling).toList(),
      );
      groceryProducts.assignAll(
        groceries.isNotEmpty
            ? groceries
            : ProductRepository.fallbackProducts.where((p) => p.category == 'groceries').toList(),
      );
    } catch (e) {
      debugPrint('Error loading home data: $e');
      exclusiveProducts.assignAll(ProductRepository.fallbackProducts.where((p) => p.isExclusive).toList());
      bestSelling.assignAll(ProductRepository.fallbackProducts.where((p) => p.isBestSelling).toList());
      groceryProducts.assignAll(ProductRepository.fallbackProducts.where((p) => p.category == 'groceries').toList());
    } finally {
      isLoading.value = false;
    }
  }

  //change bottom navigation index
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  //Add product to cart
  void addToCart(ProductModel product){
    Utils.toastMessage(
      '${product.name} added to cart',
      backgroundColor: Colors.green,
    );
  }
}
