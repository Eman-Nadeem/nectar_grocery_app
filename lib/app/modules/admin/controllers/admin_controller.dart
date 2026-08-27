import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/data/repositories/product_repository.dart';
import 'package:nectar_grocery/app/data/repositories/storage_repository.dart';
import 'package:nectar_grocery/app/modules/home/controllers/home_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class AdminController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final StorageRepository _storageRepository = StorageRepository();
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;

  // Text Form Controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final descriptionController = TextEditingController();

  // Toggles & Selection
  final RxString selectedCategory = 'groceries'.obs;
  final RxBool isExclusive = false.obs;
  final RxBool isBestSelling = false.obs;

  // Image Selection
  final Rx<File?> selectedImageFile = Rx<File?>(null);
  final RxString currentImageUrl = ''.obs;

  // Editing state
  final Rx<ProductModel?> editingProduct = Rx<ProductModel?>(null);
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;

  final List<String> categoriesList = [
    'groceries',
    'fruits',
    'vegetables',
    'meat',
    'beverages',
  ];

  @override
  void onInit() {
    super.onInit();
    loadAllProducts();
  }

  /// Load existing products for management list
  Future<void> loadAllProducts() async {
    isLoading.value = true;
    final products = await _productRepository.getAllProducts();
    allProducts.assignAll(products);
    isLoading.value = false;
  }

  /// Pick an image from gallery
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
      Utils.toastMessage(
        'Error picking image: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Confirmation dialog before saving product
  void confirmSaveProduct() {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final unit = unitController.text.trim();

    if (name.isEmpty || priceText.isEmpty || unit.isEmpty) {
      Utils.toastMessage(
        'Please fill in Name, Price, and Unit',
        backgroundColor: Colors.orange,
      );
      return;
    }

    final double? price = double.tryParse(priceText);
    if (price == null) {
      Utils.toastMessage(
        'Please enter a valid price number',
        backgroundColor: Colors.orange,
      );
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back(); // Close dialog
              saveProduct(); // Execute save
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Confirmation dialog before deleting product
  void confirmDeleteProduct(ProductModel product) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Delete Product',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back(); // Close dialog
              deleteProduct(product); // Execute delete
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Populate form to edit an existing product
  void setProductToEdit(ProductModel product) {
    editingProduct.value = product;
    nameController.text = product.name;
    priceController.text = product.price.toString();
    unitController.text = product.unit;
    descriptionController.text = product.description;
    selectedCategory.value = product.category;
    isExclusive.value = product.isExclusive;
    isBestSelling.value = product.isBestSelling;
    currentImageUrl.value = product.imageUrl;
    selectedImageFile.value = null;
  }

  /// Reset form fields for creating a new product
  void clearForm() {
    editingProduct.value = null;
    nameController.clear();
    priceController.clear();
    unitController.clear();
    descriptionController.clear();
    selectedCategory.value = 'groceries';
    isExclusive.value = false;
    isBestSelling.value = false;
    selectedImageFile.value = null;
    currentImageUrl.value = '';
  }

  /// Save Product (Create or Update)
  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final unit = unitController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || priceText.isEmpty || unit.isEmpty) {
      Utils.toastMessage(
        'Please fill in Name, Price, and Unit',
        backgroundColor: Colors.orange,
      );
      return;
    }

    final double? price = double.tryParse(priceText);
    if (price == null) {
      Utils.toastMessage(
        'Please enter a valid price number',
        backgroundColor: Colors.orange,
      );
      return;
    }

    isLoading.value = true;
    String finalImageUrl = currentImageUrl.value;

    // Upload image to Firebase Storage if a new image file was selected
    if (selectedImageFile.value != null) {
      isUploadingImage.value = true;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(' ', '_')}';
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

    final productToSave = ProductModel(
      id: editingProduct.value?.id ?? '',
      name: name,
      unit: unit,
      description: description,
      price: price,
      imageUrl: finalImageUrl,
      category: selectedCategory.value,
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

  /// Delete a product
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

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    unitController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
