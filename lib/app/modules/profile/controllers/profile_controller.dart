import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/data/models/user_models.dart';
import 'package:nectar_grocery/app/routes/app_routes.dart';
import 'package:nectar_grocery/app/utils/utils.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxBool isAdmin = false.obs; // Default: false for regular users

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

    Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? 'user@example.com';

      try {
        // Fetch user document from Firestore 'users' collection by user UID
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final userModel = UserModel.fromMap(userDoc.data()!, userDoc.id);
          
          userName.value = userModel.username.isNotEmpty
              ? userModel.username
              : (user.displayName ?? _extractNameFromEmail(userEmail.value));
          
          isAdmin.value = userModel.isAdmin || userModel.role == 'admin';
        } else {
          userName.value = user.displayName ?? _extractNameFromEmail(userEmail.value);
          isAdmin.value = false;
        }
      } catch (e) {
        debugPrint("Error loading user profile role: $e");
        userName.value = user.displayName ?? _extractNameFromEmail(userEmail.value);
        isAdmin.value = false;
      }
    } else {
      userEmail.value = 'guest@nectargrocery.com';
      userName.value = 'Guest User';
      isAdmin.value = false;
    }
  }


  String _extractNameFromEmail(String email) {
    if (email.contains('@')) {
      final part = email.split('@').first;
      return part.capitalizeFirst ?? part;
    }
    return 'User';
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Utils.toastMessage('Logged out successfully!', backgroundColor: Colors.green);
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Utils.toastMessage('Error logging out: $e', backgroundColor: Colors.red);
    }
  }
}
