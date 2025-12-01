import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../create_article/create_article_controller.dart';

enum AspectRatioType { original, square, fourToOne, threeToFour, sixteenToNine }

enum FilterPreset {
  none,
  dual,
  neon,
  film,
  vintage,
  warm,
  studio,
  prime,
  classic,
  edge
}

class EditCoverController extends GetxController {
  final CreateArticleController createArticleController;

  EditCoverController({required this.createArticleController});

  late final RxString originalImagePath;
  final RxString workingImagePath = ''.obs;

  final RxInt activeTabIndex = 0.obs;

  // Transform state
  final RxInt rotation90Deg = 0.obs;
  final RxDouble straightenAngle = 0.0.obs;
  final RxDouble zoom = 1.0.obs;
  final RxBool flipHorizontal = false.obs;
  final RxBool flipVertical = false.obs;

  // Aspect ratio
  final Rx<AspectRatioType> selectedAspectRatio = AspectRatioType.original.obs;

  // Adjust state
  final RxDouble brightness = 0.0.obs;
  final RxDouble contrast = 0.0.obs;
  final RxDouble saturation = 0.0.obs;

  // Filter state
  final Rx<FilterPreset> selectedFilter = FilterPreset.none.obs;

  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    originalImagePath = (createArticleController.editedImagePath.value.isNotEmpty
        ? createArticleController.editedImagePath.value
        : createArticleController.coverMediaPath.value)
        .obs;
    workingImagePath.value = originalImagePath.value;
  }

  void setActiveTab(int index) {
    activeTabIndex.value = index;
  }

  void rotateLeft() {
    rotation90Deg.value = (rotation90Deg.value - 90) % 360;
    if (rotation90Deg.value < 0) rotation90Deg.value += 360;
  }

  void rotateRight() {
    rotation90Deg.value = (rotation90Deg.value + 90) % 360;
  }

  void toggleFlipHorizontal() {
    flipHorizontal.value = !flipHorizontal.value;
  }

  void toggleFlipVertical() {
    flipVertical.value = !flipVertical.value;
  }

  void setAspectRatio(AspectRatioType ratio) {
    selectedAspectRatio.value = ratio;
    Get.back();
  }

  // Reset individual sections
  void resetCropSettings() {
    rotation90Deg.value = 0;
    straightenAngle.value = 0.0;
    zoom.value = 1.0;
    flipHorizontal.value = false;
    flipVertical.value = false;
    selectedAspectRatio.value = AspectRatioType.original;

    Get.snackbar(
      'Reset',
      'Crop settings have been reset',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.grey.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void resetAdjustSettings() {
    brightness.value = 0.0;
    contrast.value = 0.0;
    saturation.value = 0.0;

    Get.snackbar(
      'Reset',
      'Adjust settings have been reset',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.grey.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  // Reset all
  void resetAll() {
    rotation90Deg.value = 0;
    straightenAngle.value = 0.0;
    zoom.value = 1.0;
    flipHorizontal.value = false;
    flipVertical.value = false;
    selectedAspectRatio.value = AspectRatioType.original;
    brightness.value = 0.0;
    contrast.value = 0.0;
    saturation.value = 0.0;
    selectedFilter.value = FilterPreset.none;

    Get.snackbar(
      'Reset',
      'All changes have been reset',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.grey.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void showResetConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset All Changes?'),
        content: const Text('This will reset all editing changes. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              resetAll();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF0A8C),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void showAspectRatioBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Aspect Ratio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 20),
            _buildAspectRatioOption('Original', AspectRatioType.original),
            _buildAspectRatioOption('Square', AspectRatioType.square),
            _buildAspectRatioOption('4:1', AspectRatioType.fourToOne),
            _buildAspectRatioOption('3:4', AspectRatioType.threeToFour),
            _buildAspectRatioOption('16:9', AspectRatioType.sixteenToNine),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectRatioOption(String label, AspectRatioType ratio) {
    return Obx(() {
      final isSelected = selectedAspectRatio.value == ratio;
      return ListTile(
        title: Text(label),
        trailing: isSelected
            ? const Icon(Icons.check, color: Color(0xFFFF0A8C))
            : null,
        onTap: () => setAspectRatio(ratio),
      );
    });
  }

  void setFilter(FilterPreset filter) {
    selectedFilter.value = filter;
  }

  double getTotalRotation() {
    return rotation90Deg.value + straightenAngle.value;
  }

  Future<void> saveAndReturn() async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      print('=== Starting image processing ===');

      // Check if any changes were made
      bool hasChanges = rotation90Deg.value != 0 ||
          straightenAngle.value != 0 ||
          flipHorizontal.value ||
          flipVertical.value ||
          selectedAspectRatio.value != AspectRatioType.original ||
          brightness.value != 0 ||
          contrast.value != 0 ||
          saturation.value != 0 ||
          selectedFilter.value != FilterPreset.none;

      // If no changes, just go back
      if (!hasChanges) {
        isSaving.value = false;
        Get.back();
        Get.snackbar(
          'Info',
          'No changes made',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.grey.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
        return;
      }

      // Load and decode image
      final file = File(originalImagePath.value);
      print('Loading image from: ${originalImagePath.value}');

      final bytes = await file.readAsBytes();
      print('Image size: ${bytes.length} bytes');

      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      print('Decoded image: ${image.width}x${image.height}');

      if (rotation90Deg.value != 0) {
        print('Applying 90-degree rotation: ${rotation90Deg.value}');
        image = img.copyRotate(image, angle: rotation90Deg.value);
      }

      if (straightenAngle.value != 0) {
        print('Applying straighten: ${straightenAngle.value}');
        image = img.copyRotate(image, angle: straightenAngle.value);
      }

      // 3. Flip operations
      if (flipHorizontal.value) {
        print('Flipping horizontal');
        image = img.flipHorizontal(image);
      }

      if (flipVertical.value) {
        print('Flipping vertical');
        image = img.flipVertical(image);
      }

      // 4. Aspect ratio crop
      if (selectedAspectRatio.value != AspectRatioType.original) {
        print('Applying crop: ${selectedAspectRatio.value}');
        image = _applyCrop(image);
        print('After crop: ${image.width}x${image.height}');
      }

      // 5. Apply filter preset
      if (selectedFilter.value != FilterPreset.none) {
        image = _applyFilterPreset(image, selectedFilter.value);
      }

      // 6. Apply brightness, contrast, saturation
      if (brightness.value != 0 || contrast.value != 0 || saturation.value != 0) {
        image = _applyAdjustments(image,brightness.value,contrast.value,saturation.value);
        print('Applying adjustments - B:${brightness.value}, C:${contrast.value}, S:${saturation.value}');
        //ToDo
      }

      print('Final image: ${image.width}x${image.height}');

      // Save with high quality
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'edited_$timestamp.jpg';
      final newPath = path.join(tempDir.path, fileName);

      print('Saving to: $newPath');

      // Encode with good quality
      final jpegBytes = img.encodeJpg(image, quality: 92);
      print('Encoded size: ${jpegBytes.length} bytes');

      final processedFile = File(newPath);
      await processedFile.writeAsBytes(jpegBytes);

      print('File saved, exists: ${processedFile.existsSync()}');
      print('File size on disk: ${processedFile.lengthSync()} bytes');

      // Update controller
      createArticleController.editedImagePath.value = newPath;

      print('=== Image processing complete ===');

      isSaving.value = false;

      // Go back
      Get.back();

      // Show success message
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          'Success',
          'Image saved successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFF0A8C).withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      });

    } catch (e, stackTrace) {
      isSaving.value = false;
      print('ERROR saving image: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
    }
  }

  img.Image _applyFilterPreset(img.Image image, FilterPreset filter) {
    switch (filter) {
      case FilterPreset.dual:
        return _applyDualToneFilter(image);
      case FilterPreset.neon:
        return _applyNeonFilter(image);
      case FilterPreset.film:
        return _applyFilmFilter(image);
      case FilterPreset.vintage:
        return _applyVintageFilter(image);
      case FilterPreset.warm:
        return _applyWarmFilter(image);
      case FilterPreset.studio:
        return _applyStudioFilter(image);
      case FilterPreset.prime:
        return _applyPrimeFilter(image);
      case FilterPreset.classic:
        return _applyClassicFilter(image);
      case FilterPreset.edge:
        return _applyEdgeFilter(image);
      case FilterPreset.none:
        return image;
    }
  }

  img.Image _applyCrop(img.Image image) {
    final aspectRatio = getAspectRatioValue();
    if (aspectRatio == 0) return image;

    final imageWidth = image.width;
    final imageHeight = image.height;
    final imageRatio = imageWidth / imageHeight;

    int cropWidth;
    int cropHeight;

    if (imageRatio > aspectRatio) {
      cropHeight = imageHeight;
      cropWidth = (imageHeight * aspectRatio).round();
    } else {
      cropWidth = imageWidth;
      cropHeight = (imageWidth / aspectRatio).round();
    }

    final x = ((imageWidth - cropWidth) / 2).round();
    final y = ((imageHeight - cropHeight) / 2).round();

    return img.copyCrop(image, x: x, y: y, width: cropWidth, height: cropHeight);
  }

  void cancel() {
    Get.back();
  }

  double getAspectRatioValue() {
    switch (selectedAspectRatio.value) {
      case AspectRatioType.square:
        return 1.0;
      case AspectRatioType.fourToOne:
        return 4.0;
      case AspectRatioType.threeToFour:
        return 3.0 / 4.0;
      case AspectRatioType.sixteenToNine:
        return 16.0 / 9.0;
      case AspectRatioType.original:
      default:
        return 0;
    }
  }

  ColorFilter? getColorFilter() {
    switch (selectedFilter.value) {
      case FilterPreset.dual:
        return const ColorFilter.matrix([
          1.2, 0, 0, 0, 0,
          0, 1.0, 0, 0, 0,
          0, 0, 1.2, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterPreset.neon:
        return const ColorFilter.matrix([
          1.5, 0, 0, 0, 0,
          0, 1.0, 0, 0, 0,
          0, 0, 1.5, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterPreset.film:
        return const ColorFilter.matrix([
          0.9, 0, 0, 0, 20,
          0, 0.9, 0, 0, 20,
          0, 0, 0.8, 0, 20,
          0, 0, 0, 1, 0,
        ]);
      case FilterPreset.vintage:
        return const ColorFilter.matrix([
          0.9, 0, 0, 0, 30,
          0, 0.85, 0, 0, 20,
          0, 0, 0.7, 0, 10,
          0, 0, 0, 1, 0,
        ]);
      case FilterPreset.warm:
        return const ColorFilter.matrix([
          1.2, 0, 0, 0, 0,
          0, 1.0, 0, 0, 0,
          0, 0, 0.8, 0, 0,
          0, 0, 0, 1, 0,
        ]);

    // NEW FILTERS
      case FilterPreset.studio:
      // Professional studio - clean, slightly desaturated
        return const ColorFilter.matrix([
          1.15, 0, 0, 0, 8,
          0, 1.15, 0, 0, 8,
          0, 0, 1.15, 0, 8,
          0, 0, 0, 1, 0,
        ]);

      case FilterPreset.prime:
      // Premium warm tones
        return const ColorFilter.matrix([
          1.18, 0, 0, 0, 20,
          0, 1.12, 0, 0, 20,
          0, 0, 1.05, 0, 20,
          0, 0, 0, 1, 0,
        ]);

      case FilterPreset.classic:
      // Classic muted film
        return const ColorFilter.matrix([
          0.98, 0, 0, 0, 10,
          0, 0.98, 0, 0, 10,
          0, 0, 0.95, 0, 10,
          0, 0, 0, 1, 0,
        ]);

      case FilterPreset.edge:
      // Sharp and dramatic
        return const ColorFilter.matrix([
          1.35, 0, 0, 0, 5,
          0, 1.35, 0, 0, 5,
          0, 0, 1.35, 0, 5,
          0, 0, 0, 1, 0,
        ]);

      case FilterPreset.none:
      default:
        return null;
    }
  }

  ColorFilter? getAdjustmentFilter() {
    if (brightness.value == 0 && contrast.value == 0 && saturation.value == 0) {
      return null;
    }

    final b = brightness.value / 100;
    final c = 1.0 + (contrast.value / 100);
    final s = 1.0 + (saturation.value / 100);

    return ColorFilter.matrix([
      c * s, 0, 0, 0, b * 255,
      0, c * s, 0, 0, b * 255,
      0, 0, c * s, 0, b * 255,
      0, 0, 0, 1, 0,
    ]);
  }

  img.Image _applyAdjustments(img.Image image, double brightness, double contrast, double saturation) {
    // Clone the image
    final adjusted = img.copyResize(image, width: image.width, height: image.height);

    final b = brightness / 100.0;
    final c = contrast / 100.0;
    final s = saturation / 100.0;

    for (var y = 0; y < adjusted.height; y++) {
      for (var x = 0; x < adjusted.width; x++) {
        final pixel = adjusted.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final bv = pixel.b.toDouble();
        final a = pixel.a.toDouble();

        var newR = r + (b * 255);
        var newG = g + (b * 255);
        var newB = bv + (b * 255);

        newR = ((newR - 128) * (1 + c)) + 128;
        newG = ((newG - 128) * (1 + c)) + 128;
        newB = ((newB - 128) * (1 + c)) + 128;

        if (s != 0) {
          final luminance = 0.299 * newR + 0.587 * newG + 0.114 * newB;
          newR = luminance + (newR - luminance) * (1 + s);
          newG = luminance + (newG - luminance) * (1 + s);
          newB = luminance + (newB - luminance) * (1 + s);
        }

        newR = newR.clamp(0, 255);
        newG = newG.clamp(0, 255);
        newB = newB.clamp(0, 255);

        adjusted.setPixelRgba(x, y, newR.round(), newG.round(), newB.round(), a.round());
      }
    }

    return adjusted;
  }

  img.Image _applyDualToneFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;

        final newR = (r * 1.2).clamp(0, 255).round();
        final newB = (b * 1.2).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, g, newB, a);
      }
    }

    return filtered;
  }

  img.Image _applyNeonFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;
        final newR = (r * 1.5).clamp(0, 255).round();
        final newB = (b * 1.5).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, g, newB, a);
      }
    }

    return filtered;
  }

  img.Image _applyFilmFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;

        // Desaturate slightly and add sepia tint
        final newR = (r * 0.9 + 20).clamp(0, 255).round();
        final newG = (g * 0.9 + 20).clamp(0, 255).round();
        final newB = (b * 0.8 + 20).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, newG, newB, a);
      }
    }
    return filtered;
  }

  img.Image _applyVintageFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;

        final newR = (r * 0.9 + 30).clamp(0, 255).round();
        final newG = (g * 0.85 + 20).clamp(0, 255).round();
        final newB = (b * 0.7 + 10).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, newG, newB, a);
      }
    }
    return filtered;
  }

  img.Image _applyWarmFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;

        final newR = (r * 1.2).clamp(0, 255).round();
        final newB = (b * 0.8).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, g, newB, a);
      }
    }
    return filtered;
  }

  img.Image _applyStudioFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;

        final newR = (r * 1.15 + 8).clamp(0, 255).round();
        final newG = (g * 1.15 + 8).clamp(0, 255).round();
        final newB = (b * 1.15 + 8).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, newG, newB, a);
      }
    }

    return filtered;
  }

  img.Image _applyPrimeFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;
        final newR = (r * 1.18 + 20).clamp(0, 255).round();
        final newG = (g * 1.12 + 20).clamp(0, 255).round();
        final newB = (b * 1.05 + 20).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, newG, newB, a);
      }
    }

    return filtered;
  }

  img.Image _applyClassicFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;
        final newR = (r * 0.98 + 10).clamp(0, 255).round();
        final newG = (g * 0.98 + 10).clamp(0, 255).round();
        final newB = (b * 0.95 + 10).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, newG, newB, a);
      }
    }

    return filtered;
  }

  img.Image _applyEdgeFilter(img.Image image) {
    final filtered = img.copyResize(image, width: image.width, height: image.height);

    for (var y = 0; y < filtered.height; y++) {
      for (var x = 0; x < filtered.width; x++) {
        final pixel = filtered.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;
        final newR = (r * 1.35 + 5).clamp(0, 255).round();
        final newG = (g * 1.35 + 5).clamp(0, 255).round();
        final newB = (b * 1.35 + 5).clamp(0, 255).round();

        filtered.setPixelRgba(x, y, newR, newG, newB, a);
      }
    }

    return filtered;
  }
}