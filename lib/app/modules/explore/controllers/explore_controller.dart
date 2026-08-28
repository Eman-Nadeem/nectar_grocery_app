import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/category_repository.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';

class ExploreController extends GetxController {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ProductRepository _productRepository = ProductRepository();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  final RxList<CategoryModel> categoriesList = <CategoryModel>[].obs;
  final RxList<ProductModel> allProductsList = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadExploreData();
  }

  Future<void> loadExploreData() async {
    isLoading.value = true;
    final fetchedCats = await _categoryRepository.getCategories();
    final fetchedProds = await _productRepository.getAllProducts();
    categoriesList.assignAll(fetchedCats);
    allProductsList.assignAll(fetchedProds);
    isLoading.value = false;
  }

  Future<void> loadCategories() async {
    await loadExploreData();
  }

  List<CategoryModel> get filteredCategories {
    if (searchQuery.value.trim().isEmpty) {
      return categoriesList;
    }
    return categoriesList
        .where((cat) =>
            cat.name.toLowerCase().contains(searchQuery.value.trim().toLowerCase()))
        .toList();
  }

  List<ProductModel> get filteredProducts {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return [];
    return allProductsList
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
