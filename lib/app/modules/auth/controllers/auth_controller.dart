import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:nectar_grocery/app/modules/home/controllers/home_controller.dart';
import 'package:nectar_grocery/app/modules/profile/controllers/profile_controller.dart';
import 'package:nectar_grocery/app/utils/crashlytics_service.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/utils.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final countryCodeController = TextEditingController(text: '+92');

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  var selectedZone = 'Satiana Road'.obs;
  var selectedArea = 'Select your area'.obs;

  String tempUsername = '';
  String tempEmail = '';
  String tempPassword = '';
  String tempPhone = '';
  String tempZone = '';
  String tempArea = '';
  String _verificationId = '';

  @override
  void onInit() {
    super.onInit();
    loadSavedUserLocation();
  }

  Future<void> loadSavedUserLocation() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        isLoading.value = true;
        final doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final zone = data['zone'] as String?;
          final area = data['area'] as String?;
          if (zone != null && zone.isNotEmpty) {
            selectedZone.value = zone;
          }
          if (area != null && area.isNotEmpty) {
            selectedArea.value = area;
          }
        }
      } catch (e) {
        debugPrint('Error loading saved location: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

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

  /// Real-Time GPS Location Detection with Timeout & Fallback so UI Never Hangs
  Future<void> getCurrentGPSLocation() async {
    try {
      isLoading.value = true;

      // 1. Check if location service (GPS) is turned on
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Utils.toastMessage(
          'GPS is disabled. Please turn on location in settings or pick from dropdown.',
          backgroundColor: Colors.orange,
        );
        await Geolocator.openLocationSettings();
        return;
      }

      // 2. Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Utils.toastMessage(
            'Location permission was denied. Please select from dropdown.',
            backgroundColor: Colors.orange,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Utils.toastMessage(
          'Location permission permanently denied. Opening App Settings...',
          backgroundColor: Colors.red,
        );
        await Geolocator.openAppSettings();
        return;
      }

      // 3. Obtain Position with 10-second timeout & medium accuracy for fast fix
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e, stack) {
        debugPrint(
          'getCurrentPosition failed: $e. Trying last known position...',
        );
        CrashlyticsService.recordError(e, stack, reason: 'GPS Geolocator position fetch failed');
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        // 4. Reverse Geocoding
        List<Placemark> placemarks = [];
        try {
          placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(const Duration(seconds: 5), onTimeout: () => []);
        } catch (e, stack) {
          debugPrint('Geocoding failed: $e');
          CrashlyticsService.recordError(e, stack, reason: 'Reverse Geocoding placemark coordinates failed');
        }

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          // Resolve Zone
          String zone = place.locality?.isNotEmpty == true
              ? place.locality!
              : (place.subAdministrativeArea?.isNotEmpty == true
                    ? place.subAdministrativeArea!
                    : (place.administrativeArea?.isNotEmpty == true
                          ? place.administrativeArea!
                          : 'Satiana Road'));

          // Resolve Area
          String area = place.subLocality?.isNotEmpty == true
              ? place.subLocality!
              : (place.thoroughfare?.isNotEmpty == true
                    ? place.thoroughfare!
                    : (place.name?.isNotEmpty == true
                          ? place.name!
                          : 'Block A'));

          selectedZone.value = zone;
          selectedArea.value = area;

          Utils.toastMessage(
            'GPS Location Detected: $zone, $area',
            backgroundColor: Colors.green,
          );
        } else {
          // Fallback if reverse geocoding is unavailable
          final zone = 'Lat ${position.latitude.toStringAsFixed(2)}';
          final area = 'Long ${position.longitude.toStringAsFixed(2)}';
          selectedZone.value = zone;
          selectedArea.value = area;

          Utils.toastMessage(
            'GPS Coordinates Found (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})',
            backgroundColor: Colors.green,
          );
        }
      } else {
        Utils.toastMessage(
          'Could not fetch GPS fix. Please select your zone & area from dropdowns below.',
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      debugPrint('Error fetching GPS location: $e');
      if (e.toString().contains('MissingPluginException')) {
        Utils.toastMessage(
          'Please stop & restart the app (flutter run) to load new native location plugins.',
          backgroundColor: Colors.orange,
        );
      } else {
        Utils.toastMessage(
          'Location request timed out. Please select from dropdown.',
          backgroundColor: Colors.orange,
        );
      }
    } finally {
      isLoading.value = false;
    }
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

      if (userCredential.user != null) {
        Utils.toastMessage('Login successful!', backgroundColor: Colors.green);
        Get.offAllNamed(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      Utils.toastMessage(
        e.message ?? 'Login failed',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void saveTempRegistrationData() {
    tempUsername = usernameController.text.trim();
    tempEmail = emailController.text.trim();
    tempPassword = passwordController.text.trim();
  }

  void signUp() {
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Utils.toastMessage(
        'Please fill in all fields',
        backgroundColor: Colors.orange,
      );
      return;
    }
    saveTempRegistrationData();
    Get.toNamed(Routes.number);
  }

  void goToVerification() {
    sendOtp();
  }

  void goToSelectLocation() {
    verifyOtp();
  }

  void saveTempPhoneData() {
    tempPhone =
        '${countryCodeController.text.trim()}${phoneController.text.trim()}';
  }

  Future<void> sendOtp() async {
    if (phoneController.text.trim().isEmpty) {
      Utils.toastMessage(
        'Please enter a valid phone number',
        backgroundColor: Colors.red,
      );
      return;
    }

    saveTempPhoneData();
    isLoading.value = true;

    await _auth.verifyPhoneNumber(
      phoneNumber: tempPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        isLoading.value = false;
        Get.toNamed(Routes.selectLocation);
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading.value = false;
        Utils.toastMessage(
          'Phone verification failed: ${e.message}',
          backgroundColor: Colors.red,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        isLoading.value = false;
        Utils.toastMessage(
          'OTP sent to $tempPhone',
          backgroundColor: Colors.green,
        );
        Get.toNamed(Routes.verification);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim().length < 4) {
      Utils.toastMessage(
        'Please enter valid 4-digit code',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);
      isLoading.value = false;
      Get.toNamed(Routes.selectLocation);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Utils.toastMessage(
        e.message ?? 'Invalid OTP Code',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> saveUserProfile() async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;

      if (currentUser == null &&
          tempEmail.isNotEmpty &&
          tempPassword.isNotEmpty) {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: tempEmail,
              password: tempPassword,
            )
            .timeout(const Duration(seconds: 8));
        currentUser = userCredential.user;
      }

      if (currentUser != null) {
        final userDocRef = _firestore.collection('users').doc(currentUser.uid);
        DocumentSnapshot? existingDoc;
        try {
          existingDoc = await userDocRef.get().timeout(
            const Duration(seconds: 4),
          );
        } catch (e) {
          debugPrint('Error fetching existing user doc: $e');
        }

        Map<String, dynamic> updateData = {
          'zone': selectedZone.value,
          'area': selectedArea.value,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        if (existingDoc != null &&
            existingDoc.exists &&
            existingDoc.data() != null) {
          // Existing user doc: Only update non-empty fields to preserve isAdmin, role, phone, username
          if (tempUsername.isNotEmpty) updateData['username'] = tempUsername;
          if (tempPhone.isNotEmpty) updateData['phone'] = tempPhone;
          if (tempEmail.isNotEmpty) updateData['email'] = tempEmail;
        } else {
          // New user document setup
          updateData['uid'] = currentUser.uid;
          updateData['username'] = tempUsername.isNotEmpty
              ? tempUsername
              : (currentUser.displayName ?? 'User');
          updateData['email'] = currentUser.email ?? tempEmail;
          updateData['phone'] = tempPhone.isNotEmpty
              ? tempPhone
              : (currentUser.phoneNumber ?? '');
          updateData['isAdmin'] = false;
          updateData['role'] = 'user';
          updateData['createdAt'] = DateTime.now().toIso8601String();
        }

        await userDocRef
            .set(updateData, SetOptions(merge: true))
            .timeout(const Duration(seconds: 6));

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadUserLocation();
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadUserData();
        }

        Utils.toastMessage(
          'Location & profile saved!',
          backgroundColor: Colors.green,
        );
        Get.offAllNamed(Routes.home);
      } else {
        // Guest mode fallback so user can proceed directly to Home
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().selectedLocation.value =
              '${selectedZone.value}, ${selectedArea.value}';
        }
        Utils.toastMessage('Location saved!', backgroundColor: Colors.green);
        Get.offAllNamed(Routes.home);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      // If network times out, navigate home gracefully
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().selectedLocation.value =
            '${selectedZone.value}, ${selectedArea.value}';
      }
      Get.offAllNamed(Routes.home);
    } finally {
      isLoading.value = false;
    }
  }
}
