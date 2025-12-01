import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../create_article/create_article_controller.dart';
import '../../services/media_service.dart';

class EditThumbnailController extends GetxController {
  final CreateArticleController createArticleController;
  final MediaService _mediaService = Get.find<MediaService>();

  EditThumbnailController({required this.createArticleController});

  final videoPath = "".obs;
  final RxString thumbnailPath = ''.obs;
  final RxBool isSaving = false.obs;

  // Video player
  VideoPlayerController? videoPlayerController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isPlaying = false.obs;
  final RxDouble videoPosition = 0.0.obs;
  final RxDouble videoDuration = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    videoPath.value = createArticleController.coverMediaPath.value;

    if (createArticleController.videoThumbnailPath.value.isNotEmpty) {
      thumbnailPath.value = createArticleController.videoThumbnailPath.value;
    }

    _initializeVideoPlayer();
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    super.onClose();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      videoPlayerController = VideoPlayerController.file(File(videoPath.value));

      await videoPlayerController!.initialize();

      isVideoInitialized.value = true;
      videoDuration.value = videoPlayerController!.value.duration.inSeconds.toDouble();

      // Listen to video position updates
      videoPlayerController!.addListener(() {
        if (videoPlayerController!.value.isInitialized) {
          videoPosition.value = videoPlayerController!.value.position.inSeconds.toDouble();
          isPlaying.value = videoPlayerController!.value.isPlaying;

          // Loop video if it ends
          if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
            videoPlayerController!.seekTo(Duration.zero);
            videoPlayerController!.pause();
          }
        }
      });

    } catch (e) {
      print('Error initializing video player: $e');
      Get.snackbar(
        'Error',
        'Failed to load video: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  void togglePlayPause() {
    if (videoPlayerController == null || !isVideoInitialized.value) return;

    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
    } else {
      videoPlayerController!.play();
    }
  }

  void seekTo(double seconds) {
    if (videoPlayerController == null || !isVideoInitialized.value) return;
    videoPlayerController!.seekTo(Duration(seconds: seconds.toInt()));
  }

  Future<void> pickThumbnail() async {
    final imagePath = await _mediaService.pickImageFromGallery();
    if (imagePath != null) {
      thumbnailPath.value = imagePath;
    }
  }

  Future<void> captureThumbnail() async {
    final imagePath = await _mediaService.captureImageWithCamera();
    if (imagePath != null) {
      thumbnailPath.value = imagePath;
    }
  }

  void deleteThumbnail() {
    thumbnailPath.value = '';
  }

  Future<void> saveAndReturn() async {
    if (thumbnailPath.value.isEmpty) {
      Get.snackbar(
        'Required',
        'Please select or capture a thumbnail image',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    createArticleController.videoThumbnailPath.value = thumbnailPath.value;

    Get.back();

    Get.snackbar(
      'Success',
      'Video thumbnail saved successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFF0A8C).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void cancel() {
    Get.back();
  }

  void showThumbnailPickerBottomSheet() {
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
              'Select thumbnail',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0A8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFFFF0A8C)),
              ),
              title: const Text('Capture with camera'),
              subtitle: const Text('Take a new photo'),
              onTap: () {
                Get.back();
                captureThumbnail();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0A8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Color(0xFFFF0A8C)),
              ),
              title: const Text('Choose from gallery'),
              subtitle: const Text('Select existing photo'),
              onTap: () {
                Get.back();
                pickThumbnail();
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}