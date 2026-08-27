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
        title: const Text(
          'Admin Catalog',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: controller.loadAllProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          controller.clearForm();
          _showProductFormBottomSheet(context);
        },
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.allProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (controller.allProducts.isEmpty) {
            return const Center(
              child: Text(
                'No products in catalog.\nTap "+ Add Product" to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.allProducts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = controller.allProducts[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                leading: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: product.imageUrl.startsWith('http')
                        ? Image.network(product.imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.shopping_basket, color: AppColors.primary),
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  '\$${product.price.toStringAsFixed(2)} • ${product.unit} • ${product.category}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () {
                        controller.setProductToEdit(product);
                        _showProductFormBottomSheet(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => controller.confirmDeleteProduct(product),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// Opens the Modal Bottom Sheet Overlay Form for Add / Edit
  void _showProductFormBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.editingProduct.value == null ? 'Add New Product' : 'Edit Product',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Image Picker Box
                _buildImagePicker(),
                const SizedBox(height: 15),

                // Product Name Field
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

                // Category Dropdown
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

                _buildTextField('Description', controller.descriptionController, 'Enter product description...', maxLines: 2),
                const SizedBox(height: 10),

                // Toggles
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

                // Save Button (Triggers Confirmation Dialog)
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: controller.isLoading.value ? null : controller.confirmSaveProduct,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              controller.editingProduct.value == null ? 'Save Product' : 'Update Product',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Obx(() {
        final File? imageFile = controller.selectedImageFile.value;
        final String currentUrl = controller.currentImageUrl.value;

        return Container(
          height: 130,
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
                        Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.primary),
                        SizedBox(height: 6),
                        Text('Tap to pick product image', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
}
