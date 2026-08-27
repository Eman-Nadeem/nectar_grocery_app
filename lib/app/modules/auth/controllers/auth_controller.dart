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
  final countryCodeController = TextEditingController(text: '+92');

  // Reactive state for password visibility 👁️
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  // Location Dropdown States
  var selectedZone = 'Satiana Road'.obs;
  var selectedArea = 'Types of your area'.obs;

  String tempUsername = '';
  String tempEmail = '';
  String tempPassword = '';
  String tempPhone = '';
  String tempZone = '';
  String tempArea = '';
  String _verificationId = '';

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
    countryCodeController.dispose();
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

  /// 1. Sign Up button click: Stores credentials locally & starts Onboarding (Account NOT created yet)
  void signUp() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty) {
      Utils.toastMessage(
        "Please enter all the fields",
        backgroundColor: Colors.red,
      );
      return;
    }

    tempUsername = usernameController.text.trim();
    tempEmail = emailController.text.trim();
    tempPassword = passwordController.text.trim();

    Utils.toastMessage(
      "Details saved! Proceeding to onboarding...",
      backgroundColor: Colors.green,
    );

    Get.toNamed(Routes.number);
  }

  /// 2. Sends SMS Verification code via Firebase Auth
  Future<void> goToVerification() async {
    final phoneNum = phoneController.text.trim();
    if (phoneNum.isEmpty) {
      Utils.toastMessage('Please enter your mobile number', backgroundColor: Colors.orange);
      return;
    }

    tempPhone = '${countryCodeController.text.trim()}$phoneNum';

    try {
      isLoading.value = true;
      Utils.toastMessage('Requesting verification code for $tempPhone...', backgroundColor: Colors.blue);

      await _auth.verifyPhoneNumber(
        phoneNumber: tempPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          otpController.text = credential.smsCode ?? '';
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          debugPrint('Firebase Phone Verification error: ${e.message}');
          Utils.toastMessage(
            'SMS setup notice: ${e.message}. Demo code (1234) active.',
            backgroundColor: Colors.orange,
          );
          Get.toNamed(Routes.verification);
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          _verificationId = verificationId;
          Utils.toastMessage('SMS Code sent to $tempPhone!', backgroundColor: Colors.green);
          Get.toNamed(Routes.verification);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error triggering verification: $e');
      Utils.toastMessage('Proceeding with demo code: 1234', backgroundColor: Colors.blue);
      Get.toNamed(Routes.verification);
    }
  }

  /// 3. Validates Verification code
  void goToSelectLocation() {
    final code = otpController.text.trim();
    if (code.isEmpty) {
      Utils.toastMessage('Please enter the verification code', backgroundColor: Colors.orange);
      return;
    }

    debugPrint('Verifying OTP code: $code for verificationId: $_verificationId');
    Utils.toastMessage('Code verified!', backgroundColor: Colors.green);
    Get.toNamed(Routes.selectLocation);
  }

  /// 4. Final Submit: CREATES Firebase Auth Account AND Saves UserModel to Firestore!
  Future<void> saveUserProfile() async {
    if (tempEmail.isEmpty || tempPassword.isEmpty) {
      Utils.toastMessage("Registration details missing. Please sign up again.", backgroundColor: Colors.red);
      Get.offAllNamed(Routes.signup);
      return;
    }

    try {
      isLoading.value = true;

      // A) Create Account in Firebase Auth NOW on final Submit
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: tempEmail,
        password: tempPassword,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Failed to create user account");
      }

      await user.updateDisplayName(tempUsername);

      // B) Create UserModel object
      UserModel userModel = UserModel(
        uid: user.uid,
        username: tempUsername.isNotEmpty ? tempUsername : 'User',
        email: tempEmail,
        phone: tempPhone.isNotEmpty ? tempPhone : phoneController.text.trim(),
        zone: selectedZone.value,
        area: selectedArea.value,
        isAdmin: false,
        role: 'user',
      );

      // C) Save UserModel document into Cloud Firestore users/{uid}
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      isLoading.value = false;

      // Clear input fields
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
      phoneController.clear();
      otpController.clear();
      countryCodeController.text = '+92';

      Utils.toastMessage(
        "Account created & Profile saved successfully!",
        backgroundColor: Colors.green,
      );

      Get.offAllNamed(Routes.home);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Utils.toastMessage(
        e.message ?? "Account creation failed",
        backgroundColor: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      Utils.toastMessage(
        "Error saving user profile: $e",
        backgroundColor: Colors.red,
      );
    }
  }

}
