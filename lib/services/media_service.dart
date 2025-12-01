import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MediaService extends GetxService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) return null;

      return await _saveToTempDirectory(image.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Capture image with camera
  Future<String?> captureImageWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return null;

      return await _saveToTempDirectory(image.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Pick video from gallery
  Future<String?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
      );

      if (video == null) return null;

      return await _saveToTempDirectory(video.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick video: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Record video with camera
  Future<String?> recordVideoWithCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
        preferredCameraDevice: CameraDevice.rear,
      );

      if (video == null) return null;

      return await _saveToTempDirectory(video.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record video: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<String> _saveToTempDirectory(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basename(sourcePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = path.join(tempDir.path, '${timestamp}_$fileName');

    final sourceFile = File(sourcePath);
    final newFile = await sourceFile.copy(newPath);

    return newFile.path;
  }

  Future<String> saveTempFile(File file) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basename(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = path.join(tempDir.path, 'edited_${timestamp}_$fileName');

    final newFile = await file.copy(newPath);
    return newFile.path;
  }
}