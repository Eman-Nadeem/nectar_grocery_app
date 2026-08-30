import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nectar_grocery/app/utils/crashlytics_service.dart';

class StorageRepository {
  // --- Old Firebase Storage Code (Commented Out) ---
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  //
  // Future<String?> uploadProductImageFirebase(File imageFile, String fileName) async {
  //   Reference ref = _storage.ref().child('products/$fileName.jpg');
  //   try {
  //     UploadTask uploadTask = ref.putFile(imageFile);
  //     TaskSnapshot snapshot = await uploadTask;
  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch(e) {
  //     debugPrint("ErrorUploading Image: $e");
  //     return null;
  //   }
  // }

  // --- New Cloudinary Upload Code ---
  final String _cloudName = 'dclaxglms';
  final String _uploadPreset = 'nectar_preset';

  /// Uploads a local image file to Cloudinary and returns the HTTPS CDN URL
  Future<String?> uploadProductImage(File imageFile, String fileName) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        final String? secureUrl = jsonMap['secure_url'];
        return secureUrl;
      } else {
        debugPrint("Cloudinary Upload failed status code: ${response.statusCode}");
        CrashlyticsService.recordError(
          'Cloudinary Upload Failed HTTP ${response.statusCode}',
          StackTrace.current,
          reason: 'Cloudinary upload returned status ${response.statusCode}',
        );
        return null;
      }
    } catch (e, stack) {
      debugPrint("Error uploading image to Cloudinary: $e");
      CrashlyticsService.recordError(
        e,
        stack,
        reason: 'Cloudinary image upload network exception',
      );
      return null;
    }
  }
}
