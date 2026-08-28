import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/category_repository.dart';
import 'package:nectar_grocery/app/data/repositories/order_repository.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';
import 'package:nectar_grocery/app/data/repositories/storage_repository.dart';
import 'package:nectar_grocery/app/modules/explore/controllers/explore_controller.dart';
import 'package:nectar_grocery/app/modules/home/controllers/home_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class CategoryColorTheme {
  final String name;
  final Color backgroundColor;
  final Color borderColor;

  const CategoryColorTheme({
    required this.name,
    required this.backgroundColor,
    required this.borderColor,
  });
}

final List<CategoryColorTheme> categoryColorThemes = const [
  CategoryColorTheme(
    name: 'Fresh Green',
    backgroundColor: Color(0xFFEEF7F1),
    borderColor: Color(0xFF53B175),
  ),
  CategoryColorTheme(
    name: 'Warm Orange',
    backgroundColor: Color(0xFFFDF0E7),
    borderColor: Color(0xFFF7A593),
  ),
  CategoryColorTheme(
    name: 'Soft Pink',
    backgroundColor: Color(0xFFFDE8E4),
    borderColor: Color(0xFFF7A593),
  ),
  CategoryColorTheme(
    name: 'Soft Purple',
    backgroundColor: Color(0xFFF4EBF7),
    borderColor: Color(0xFFD3B0E0),
  ),
  CategoryColorTheme(
    name: 'Soft Yellow',
    backgroundColor: Color(0xFFFFF9E5),
    borderColor: Color(0xFFFDE598),
  ),
  CategoryColorTheme(
    name: 'Soft Blue',
    backgroundColor: Color(0xFFEDF7FC),
    borderColor: Color(0xFFB7DFF5),
  ),
];

class AdminController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final StorageRepository _storageRepository = StorageRepository();
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;

  // --- Product Form Controllers ---
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxString selectedCategoryId = ''.obs;
  final RxBool isExclusive = false.obs;
  final RxBool isBestSelling = false.obs;

  final Rx<File?> selectedImageFile = Rx<File?>(null);
  final RxString currentImageUrl = ''.obs;

  final Rx<ProductModel?> editingProduct = Rx<ProductModel?>(null);
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;

  // --- Category Management Controllers ---
  final categoryNameController = TextEditingController();
  final categoryImageUrlController = TextEditingController();
  final categoryBgColorController = TextEditingController(text: '#EEF7F1');
  final categoryBorderColorController = TextEditingController(text: '#53B175');

  final RxInt selectedColorThemeIndex = 0.obs;
  final Rx<File?> selectedCategoryImageFile = Rx<File?>(null);
  final RxString currentCategoryImageUrl = ''.obs;

  final Rx<CategoryModel?> editingCategory = Rx<CategoryModel?>(null);
  final RxList<CategoryModel> allCategories = <CategoryModel>[].obs;

  // --- Orders Management List ---
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllProducts();
    loadAllCategories();
    loadAllOrders();
  }

  /// Load existing products
  Future<void> loadAllProducts() async {
    isLoading.value = true;
    final products = await _productRepository.getAllProducts();
    allProducts.assignAll(products);
    isLoading.value = false;
  }

  /// Load existing categories from Cloud Firestore
  Future<void> loadAllCategories() async {
    isLoading.value = true;
    final categories = await _categoryRepository.getCategories();
    allCategories.assignAll(categories);
    if (allCategories.isNotEmpty && selectedCategoryId.value.isEmpty) {
      selectedCategoryId.value = allCategories.first.id;
    }
    isLoading.value = false;
  }

  /// Load all customer orders
  Future<void> loadAllOrders() async {
    isLoading.value = true;
    final orders = await _orderRepository.getAllOrders();
    allOrders.assignAll(orders);
    isLoading.value = false;
  }

  /// Update order status in Cloud Firestore
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final success = await _orderRepository.updateOrderStatus(orderId, newStatus);
    if (success) {
      Utils.toastMessage('Order status updated to $newStatus', backgroundColor: Colors.green);
      loadAllOrders();
    }
  }

  /// Pick an image for Product
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        selectedImageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Utils.toastMessage('Error picking image: $e', backgroundColor: Colors.red);
    }
  }

  /// Pick an image for Category
  Future<void> pickCategoryImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        selectedCategoryImageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Utils.toastMessage('Error picking image: $e', backgroundColor: Colors.red);
    }
  }

  void selectColorTheme(int index) {
    selectedColorThemeIndex.value = index;
    final theme = categoryColorThemes[index];
    categoryBgColorController.text = '#${theme.backgroundColor.toARGB32().toRadixString(16).substring(2)}';
    categoryBorderColorController.text = '#${theme.borderColor.toARGB32().toRadixString(16).substring(2)}';
  }

  // --- Product Confirmation & Save Dialogs ---

  void confirmSaveProduct() {
    if (allCategories.isEmpty) {
      Utils.toastMessage('No categories found. Please create a category first!', backgroundColor: Colors.red);
      return;
    }

    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final unit = unitController.text.trim();

    if (name.isEmpty || priceText.isEmpty || unit.isEmpty) {
      Utils.toastMessage('Please fill in Name, Price, and Unit', backgroundColor: Colors.orange);
      return;
    }

    final double? price = double.tryParse(priceText);
    if (price == null) {
      Utils.toastMessage('Please enter a valid price number', backgroundColor: Colors.orange);
      return;
    }

    final isEditing = editingProduct.value != null;
    final title = isEditing ? 'Update Product' : 'Add New Product';
    final message = isEditing
        ? 'Are you sure you want to save changes to "$name"?'
        : 'Are you sure you want to add "$name" to the catalog?';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back();
              saveProduct();
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void confirmDeleteProduct(ProductModel product) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back();
              deleteProduct(product);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void setProductToEdit(ProductModel product) {
    editingProduct.value = product;
    nameController.text = product.name;
    priceController.text = product.price.toString();
    unitController.text = product.unit;
    descriptionController.text = product.description;
    
    // Select category ID matching product's categoryId or name
    final matchingCat = allCategories.firstWhere(
      (c) => c.id == product.categoryId || c.name.toLowerCase() == product.category.toLowerCase(),
      orElse: () => allCategories.isNotEmpty ? allCategories.first : CategoryModel(id: '', name: '', imageUrl: '', backgroundColor: Colors.white, borderColor: Colors.white),
    );
    selectedCategoryId.value = matchingCat.id;

    isExclusive.value = product.isExclusive;
    isBestSelling.value = product.isBestSelling;
    currentImageUrl.value = product.imageUrl;
    selectedImageFile.value = null;
  }

  void clearForm() {
    editingProduct.value = null;
    nameController.clear();
    priceController.clear();
    unitController.clear();
    descriptionController.clear();
    selectedCategoryId.value = allCategories.isNotEmpty ? allCategories.first.id : '';
    isExclusive.value = false;
    isBestSelling.value = false;
    selectedImageFile.value = null;
    currentImageUrl.value = '';
  }

  Future<void> saveProduct() async {
    if (allCategories.isEmpty) {
      Utils.toastMessage('No categories available in Cloud Firestore', backgroundColor: Colors.red);
      return;
    }

    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final unit = unitController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || priceText.isEmpty || unit.isEmpty) {
      Utils.toastMessage('Please fill in Name, Price, and Unit', backgroundColor: Colors.orange);
      return;
    }

    final double? price = double.tryParse(priceText);
    if (price == null) {
      Utils.toastMessage('Please enter a valid price number', backgroundColor: Colors.orange);
      return;
    }

    isLoading.value = true;
    String finalImageUrl = currentImageUrl.value;

    if (selectedImageFile.value != null) {
      isUploadingImage.value = true;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(' ', '_')}';
      final uploadedUrl = await _storageRepository.uploadProductImage(
        selectedImageFile.value!,
        fileName,
      );
      isUploadingImage.value = false;

      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      } else {
        Utils.toastMessage('Image upload failed', backgroundColor: Colors.red);
        isLoading.value = false;
        return;
      }
    }

    // Lookup CategoryModel from selectedCategoryId
    final selectedCat = allCategories.firstWhere(
      (c) => c.id == selectedCategoryId.value,
      orElse: () => allCategories.first,
    );

    final productToSave = ProductModel(
      id: editingProduct.value?.id ?? '',
      name: name,
      unit: unit,
      description: description,
      price: price,
      imageUrl: finalImageUrl,
      category: selectedCat.name,
      categoryId: selectedCat.id,
      isExclusive: isExclusive.value,
      isBestSelling: isBestSelling.value,
    );

    bool success = false;
    if (editingProduct.value == null) {
      success = await _productRepository.addProduct(productToSave);
    } else {
      success = await _productRepository.updateProduct(productToSave);
    }

    if (success) {
      clearForm();
      await loadAllProducts();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomeData();
      }
      Get.back();
    }

    isLoading.value = false;
  }

  Future<void> deleteProduct(ProductModel product) async {
    isLoading.value = true;
    bool success = await _productRepository.deleteProduct(product);
    if (success) {
      await loadAllProducts();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomeData();
      }
    }
    isLoading.value = false;
  }

  // --- Category CRUD Actions ---

  void confirmSaveCategory() {
    final name = categoryNameController.text.trim();
    if (name.isEmpty) {
      Utils.toastMessage('Please enter Category Name', backgroundColor: Colors.orange);
      return;
    }

    final isEditing = editingCategory.value != null;
    final title = isEditing ? 'Update Category' : 'Add New Category';
    final message = isEditing
        ? 'Are you sure you want to save changes to "$name"?'
        : 'Are you sure you want to add "$name" category?';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back();
              saveCategory();
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void confirmDeleteCategory(CategoryModel category) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Are you sure you want to delete category "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back();
              deleteCategory(category);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void setCategoryToEdit(CategoryModel category) {
    editingCategory.value = category;
    categoryNameController.text = category.name;
    categoryImageUrlController.text = category.imageUrl;
    currentCategoryImageUrl.value = category.imageUrl;
    categoryBgColorController.text = '#${category.backgroundColor.toARGB32().toRadixString(16).substring(2)}';
    categoryBorderColorController.text = '#${category.borderColor.toARGB32().toRadixString(16).substring(2)}';
    selectedCategoryImageFile.value = null;

    final themeIndex = categoryColorThemes.indexWhere(
      (t) => t.backgroundColor.toARGB32() == category.backgroundColor.toARGB32(),
    );
    selectedColorThemeIndex.value = themeIndex != -1 ? themeIndex : 0;
  }

  void clearCategoryForm() {
    editingCategory.value = null;
    categoryNameController.clear();
    categoryImageUrlController.clear();
    selectColorTheme(0);
    currentCategoryImageUrl.value = '';
    selectedCategoryImageFile.value = null;
  }

  Future<void> saveCategory() async {
    final name = categoryNameController.text.trim();
    if (name.isEmpty) return;

    isLoading.value = true;
    String finalImageUrl = currentCategoryImageUrl.value;

    if (selectedCategoryImageFile.value != null) {
      isUploadingImage.value = true;
      final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(' ', '_')}';
      final uploadedUrl = await _storageRepository.uploadProductImage(
        selectedCategoryImageFile.value!,
        fileName,
      );
      isUploadingImage.value = false;
      if (uploadedUrl != null) finalImageUrl = uploadedUrl;
    }

    final bgColor = _parseColorHex(categoryBgColorController.text.trim(), const Color(0xFFEEF7F1));
    final borderColor = _parseColorHex(categoryBorderColorController.text.trim(), const Color(0xFF53B175));

    final catToSave = CategoryModel(
      id: editingCategory.value?.id ?? '',
      name: name,
      imageUrl: finalImageUrl,
      backgroundColor: bgColor,
      borderColor: borderColor,
    );

    bool success = false;
    if (editingCategory.value == null) {
      success = await _categoryRepository.addCategory(catToSave);
    } else {
      success = await _categoryRepository.updateCategory(catToSave);
    }

    if (success) {
      clearCategoryForm();
      await loadAllCategories();
      if (Get.isRegistered<ExploreController>()) {
        Get.find<ExploreController>().loadCategories();
      }
      Get.back();
    }

    isLoading.value = false;
  }

  Future<void> deleteCategory(CategoryModel category) async {
    isLoading.value = true;
    bool success = await _categoryRepository.deleteCategory(category.id);
    if (success) {
      await loadAllCategories();
      if (Get.isRegistered<ExploreController>()) {
        Get.find<ExploreController>().loadCategories();
      }
    }
    isLoading.value = false;
  }

  Color _parseColorHex(String input, Color defaultColor) {
    if (input.isEmpty) return defaultColor;
    try {
      String hex = input.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    unitController.dispose();
    descriptionController.dispose();
    categoryNameController.dispose();
    categoryImageUrlController.dispose();
    categoryBgColorController.dispose();
    categoryBorderColorController.dispose();
    super.onClose();
  }
}
