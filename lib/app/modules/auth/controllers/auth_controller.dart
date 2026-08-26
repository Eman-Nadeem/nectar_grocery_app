import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/user_models.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/utils.dart';

class AuthController extends GetxController {
  // Firebase Auth instance 🔐
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text Editing Controllers 📝
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // Reactive state for password visibility 👁️
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  // Location Dropdown States
  var selectedZone = 'Satiana Road'.obs;
  var selectedArea = 'Types of your area'.obs;

  String tempUsername = '';
  String tempEmail = '';
  String tempPhone = '';
  String tempZone = '';
  String tempArea = '';

  // Toggle password visibility state 🔄
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Cleanup controllers when screen is closed 🧹
  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Utils.toastMessage(
        'Please enter email and password',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      isLoading.value = false;

      if (userCredential.user != null) {
        Utils.toastMessage("Login successful!", backgroundColor: Colors.green);
        emailController.clear();
        passwordController.clear();
        Get.offAllNamed(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      Utils.toastMessage(
        e.message ?? 'Login failed',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> signUp() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty) {
      Utils.toastMessage(
        "Please enter all the fields",
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      isLoading.value = false;

      await userCredential.user?.updateDisplayName(
        usernameController.text.trim(),
      );

      tempUsername = usernameController.text.trim();
      tempEmail = emailController.text.trim();
      tempPhone = phoneController.text.trim();
      tempZone = selectedZone.value;
      tempArea = selectedArea.value;

      if (userCredential.user != null) {
        Utils.toastMessage(
          "Account created successfully!",
          backgroundColor: Colors.green,
        );
        emailController.clear();
        passwordController.clear();
        usernameController.clear();
        phoneController.clear();
        selectedZone.value = 'Satiana Road';
        selectedArea.value = 'Types of your area';
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      Utils.toastMessage(
        e.message ?? "Account creation failed",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> saveUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      Utils.toastMessage("User not logged in", backgroundColor: Colors.red);
      return;
    }

    try {
      isLoading.value = true;

      UserModel userModel = UserModel(
        uid: user.uid,
        username: tempUsername.isNotEmpty
            ? tempUsername
            : (user.displayName ?? ""),
        email: tempEmail.isNotEmpty ? tempEmail : (user.email ?? ""),
        phone: tempPhone,
        zone: tempZone,
        area: tempArea,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      isLoading.value = false;

      // Clear input fields after profile setup completion
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
      phoneController.clear();
      otpController.clear();

      Utils.toastMessage(
        "Profile saved successfully!",
        backgroundColor: Colors.green,
      );

      Get.offAllNamed(Routes.home);
    } catch (e) {
      isLoading.value = false;
      Utils.toastMessage(
        "Failed to save user profile: $e",
        backgroundColor: Colors.red,
      );
    }
  }
}
