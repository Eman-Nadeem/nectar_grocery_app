import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/category_model.dart';
import 'package:nectar_grocery/app/data/models/order_model.dart';
import 'package:nectar_grocery/app/data/models/product_model.dart';
import 'package:nectar_grocery/app/modules/admin/controllers/admin_controller.dart';
import 'package:nectar_grocery/app/utils/app_colors.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
              Tab(icon: Icon(Icons.category_outlined), text: 'Categories'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Orders'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Tab 1: Products Catalog List
              _buildProductsTab(context),

              // Tab 2: Categories Catalog List
              _buildCategoriesTab(context),

              // Tab 3: Orders List
              _buildOrdersTab(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: PRODUCTS LIST & FLOATING ADD ---
  Widget _buildProductsTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          if (controller.allCategories.isEmpty) {
            Utils.toastMessage('Please add at least one category in the Categories tab before adding products!', backgroundColor: Colors.red);
            return;
          }
          controller.clearForm();
          _showProductFormBottomSheet(context);
        },
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.allProducts.isEmpty) {
          return const Center(child: Text('No products in catalog.', style: TextStyle(color: AppColors.textSecondary)));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 85),
          itemCount: controller.allProducts.length,
          separatorBuilder: (context, index) => const Divider(height: 20),
          itemBuilder: (context, index) {
            final product = controller.allProducts[index];
            return _buildProductListTile(context, product);
          },
        );
      }),
    );
  }

  Widget _buildProductListTile(BuildContext context, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.cardBackground),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.imageUrl.startsWith('http')
                  ? Image.network(product.imageUrl, fit: BoxFit.contain)
                  : const Icon(Icons.image, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${product.unit} • \$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('Category: ${product.category}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
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
  }

  void _showProductFormBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.editingProduct.value == null ? 'Add Product' : 'Edit Product',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 15),

                // Image Picker for Product
                const Text('Product Image', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Obx(() {
                  final file = controller.selectedImageFile.value;
                  final currentUrl = controller.currentImageUrl.value;
                  return Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          color: AppColors.cardBackground,
                        ),
                        child: file != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover))
                            : currentUrl.startsWith('http')
                                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(currentUrl, fit: BoxFit.cover))
                                : const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 30),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('Pick Image'),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 15),

                _buildTextField('Product Name *', controller.nameController, 'e.g. Red Apple'),
                _buildTextField('Price (\$) *', controller.priceController, 'e.g. 4.99', keyboardType: TextInputType.number),
                _buildTextField('Unit *', controller.unitController, 'e.g. 1kg, Price'),
                _buildTextField('Description', controller.descriptionController, 'e.g. Fresh organic apples', maxLines: 2),
                const SizedBox(height: 10),

                // Dynamic Categories Dropdown
                const Text('Category *', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 5),
                Obx(() {
                  if (controller.allCategories.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red.shade50,
                      ),
                      child: const Text(
                        'No categories available. Please create a category first!',
                        style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.allCategories.any((c) => c.id == controller.selectedCategoryId.value)
                            ? controller.selectedCategoryId.value
                            : controller.allCategories.first.id,
                        isExpanded: true,
                        items: controller.allCategories
                            .map((c) => DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectedCategoryId.value = val;
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 15),
                Obx(
                  () => CheckboxListTile(
                    title: const Text('Exclusive Offer'),
                    value: controller.isExclusive.value,
                    onChanged: (val) => controller.isExclusive.value = val!,
                  ),
                ),
                Obx(
                  () => CheckboxListTile(
                    title: const Text('Best Selling'),
                    value: controller.isBestSelling.value,
                    onChanged: (val) => controller.isBestSelling.value = val!,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: controller.confirmSaveProduct,
                    child: const Text('Save Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- TAB 2: CATEGORIES LISTVIEW & FLOATING ADD ---
  Widget _buildCategoriesTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          controller.clearCategoryForm();
          _showCategoryFormBottomSheet(context);
        },
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.allCategories.isEmpty) {
          return const Center(child: Text('No categories found. Please add a category first.', style: TextStyle(color: AppColors.textSecondary)));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 85),
          itemCount: controller.allCategories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = controller.allCategories[index];
            return _buildCategoryListTile(context, category);
          },
        );
      }),
    );
  }

  Widget _buildCategoryListTile(BuildContext context, CategoryModel category) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: category.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withValues(alpha: 0.6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: category.imageUrl.startsWith('http')
                  ? Image.network(category.imageUrl, fit: BoxFit.contain)
                  : const Icon(Icons.category_outlined, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              controller.setCategoryToEdit(category);
              _showCategoryFormBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => controller.confirmDeleteCategory(category),
          ),
        ],
      ),
    );
  }

  void _showCategoryFormBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.editingCategory.value == null ? 'Add Category' : 'Edit Category',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 15),

                // Category Image Picker
                const Text('Category Image', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Obx(() {
                  final file = controller.selectedCategoryImageFile.value;
                  final currentUrl = controller.currentCategoryImageUrl.value;
                  return Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          color: AppColors.cardBackground,
                        ),
                        child: file != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover))
                            : currentUrl.startsWith('http')
                                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(currentUrl, fit: BoxFit.contain))
                                : const Icon(Icons.category_outlined, color: AppColors.textSecondary, size: 30),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: controller.pickCategoryImage,
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('Pick Image'),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 15),

                _buildTextField('Category Name *', controller.categoryNameController, 'e.g. Organic Juices'),

                // Light Primary Colors Theme Dropdown
                const Text('Color Theme *', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 5),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: controller.selectedColorThemeIndex.value,
                        isExpanded: true,
                        items: List.generate(categoryColorThemes.length, (index) {
                          final theme = categoryColorThemes[index];
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: theme.backgroundColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.borderColor, width: 2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(theme.name, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        }),
                        onChanged: (val) => controller.selectColorTheme(val!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: controller.confirmSaveCategory,
                    child: const Text('Save Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- TAB 3: ORDERS MANAGEMENT ---
  Widget _buildOrdersTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.allOrders.isEmpty) {
          return const Center(
            child: Text('No orders placed yet.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.allOrders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final order = controller.allOrders[index];
            return _buildOrderCard(context, order);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Customer: ${order.userEmail}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 10),
          const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          ...order.items.map((item) => Text('• ${item.quantity}x ${item.productName} (\$${item.price})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              DropdownButton<String>(
                value: order.status,
                items: const [
                  DropdownMenuItem(value: 'Accepted', child: Text('Accepted', style: TextStyle(color: Colors.green))),
                  DropdownMenuItem(value: 'Processing', child: Text('Processing', style: TextStyle(color: Colors.orange))),
                  DropdownMenuItem(value: 'Delivered', child: Text('Delivered', style: TextStyle(color: Colors.blue))),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled', style: TextStyle(color: Colors.red))),
                ],
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    controller.updateOrderStatus(order.id, newStatus);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController, String hint, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 5),
          TextField(
            controller: textController,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ],
      ),
    );
  }
}
