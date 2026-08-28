import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nectar_grocery/app/data/repositories/storage_repository.dart';
import 'package:nectar_grocery/app/modules/profile/controllers/profile_controller.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class MyDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageRepository _storageRepository = StorageRepository();
  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final RxString photoUrl = ''.obs;
  final Rx<File?> selectedImageFile = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploadingPhoto = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          nameController.text = data['username'] ?? user.displayName ?? '';
          phoneController.text = data['phone'] ?? '';
          photoUrl.value = data['photoUrl'] ?? user.photoURL ?? '';
        } else {
          nameController.text = user.displayName ?? user.email?.split('@').first ?? 'User';
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
    isLoading.value = false;
  }

  /// Calculates initials from user name (e.g. "musamurad" -> "MM", "Eman Nadeem" -> "EN")
  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.trim().length >= 2) {
      return name.trim().substring(0, 2).toUpperCase();
    }
    return name.trim()[0].toUpperCase();
  }

  Future<void> pickProfilePhoto() async {
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

  Future<void> saveProfileDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      Utils.toastMessage('Please enter your name', backgroundColor: Colors.orange);
      return;
    }

    isLoading.value = true;
    String finalPhotoUrl = photoUrl.value;

    if (selectedImageFile.value != null) {
      isUploadingPhoto.value = true;
      final fileName = 'user_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      final uploadedUrl = await _storageRepository.uploadProductImage(
        selectedImageFile.value!,
        fileName,
      );
      isUploadingPhoto.value = false;
      if (uploadedUrl != null) {
        finalPhotoUrl = uploadedUrl;
        photoUrl.value = finalPhotoUrl;
      }
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'username': name,
        'phone': phone,
        'email': user.email,
        'photoUrl': finalPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().loadUserData();
      }

      Utils.toastMessage('Profile details saved successfully!', backgroundColor: Colors.green);
      Get.back();
    } catch (e) {
      Utils.toastMessage('Error saving profile: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
