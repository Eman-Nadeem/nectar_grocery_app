import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/admin/controllers/admin_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.editingProduct.value == null
                ? 'Add New Product'
                : 'Edit Product',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: controller.clearForm,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Picker Box
              _buildImagePicker(),
              const SizedBox(height: 20),

              // 2. Input Fields
              _buildTextField('Product Name', controller.nameController, 'e.g. Organic Bananas'),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Price (\$)', controller.priceController, 'e.g. 4.99', isNumber: true),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField('Unit / Quantity', controller.unitController, 'e.g. 1kg, Price'),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 3. Category Selector Dropdown
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.selectedCategory.value,
                      items: controller.categoriesList.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.capitalizeFirst ?? cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedCategory.value = val;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              _buildTextField('Description', controller.descriptionController, 'Enter product description...', maxLines: 3),
              const SizedBox(height: 15),

              // 4. Feature Toggles
              Obx(
                () => SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  title: const Text('Exclusive Offer', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: controller.isExclusive.value,
                  onChanged: (val) => controller.isExclusive.value = val,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  title: const Text('Best Selling Item', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: controller.isBestSelling.value,
                  onChanged: (val) => controller.isBestSelling.value = val,
                ),
              ),
              const SizedBox(height: 20),

              // 5. Save Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: controller.isLoading.value ? null : controller.saveProduct,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            controller.editingProduct.value == null ? 'Add Product' : 'Update Product',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 35),
              const Divider(),
              const SizedBox(height: 15),

              // 6. Manage Existing Products List
              const Text(
                'Existing Products Catalog',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildProductList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Obx(() {
        final File? imageFile = controller.selectedImageFile.value;
        final String currentUrl = controller.currentImageUrl.value;

        return Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(imageFile, fit: BoxFit.cover),
                )
              : currentUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(currentUrl, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary),
                        SizedBox(height: 8),
                        Text('Tap to pick product image', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
        );
      }),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: textController,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.allProducts.isEmpty) {
        return const Center(child: Text('No products found in Firestore catalog'));
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.allProducts.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final product = controller.allProducts[index];
          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: product.imageUrl.startsWith('http')
                  ? Image.network(product.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.shopping_basket, color: AppColors.primary),
            ),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('\$${product.price.toStringAsFixed(2)} - ${product.category}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => controller.setProductToEdit(product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteProduct(product),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
