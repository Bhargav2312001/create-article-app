import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../models/article.dart';
import '../../models/media_type.dart';
import '../../services/media_service.dart';
import '../../routes/app_routes.dart';
import 'dart:convert';
import 'dart:io';

class CreateArticleController extends GetxController {
  final MediaService _mediaService = Get.find<MediaService>();

  final headlineController = TextEditingController();
  final QuillController quillController = QuillController.basic();

  final Rx<MediaType> mediaType = MediaType.none.obs;
  final RxString coverMediaPath = ''.obs;
  final RxString editedImagePath = ''.obs;
  final RxString videoThumbnailPath = ''.obs;

  final RxBool isPostButtonEnabled = false.obs;

  // Video player for preview
  VideoPlayerController? videoPlayerController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isVideoPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();

    headlineController.addListener(_updatePostButtonState);
    quillController.addListener(_updatePostButtonState);

    // Listen to media type changes
    ever(mediaType, (_) => _handleMediaTypeChange());
    ever(coverMediaPath, (_) => _handleMediaPathChange());
  }

  @override
  void onClose() {
    headlineController.dispose();
    quillController.dispose();
    videoPlayerController?.dispose();
    super.onClose();
  }

  void _handleMediaTypeChange() {
    if (mediaType.value == MediaType.video && coverMediaPath.value.isNotEmpty) {
      _initializeVideoPlayer();
    } else {
      _disposeVideoPlayer();
    }
  }

  void _handleMediaPathChange() {
    if (mediaType.value == MediaType.video && coverMediaPath.value.isNotEmpty) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _disposeVideoPlayer();

      videoPlayerController = VideoPlayerController.file(File(coverMediaPath.value));
      await videoPlayerController!.initialize();

      isVideoInitialized.value = true;

      videoPlayerController!.addListener(() {
        if (videoPlayerController!.value.isInitialized) {
          isVideoPlaying.value = videoPlayerController!.value.isPlaying;

          // Loop video
          if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
            videoPlayerController!.seekTo(Duration.zero);
            videoPlayerController!.pause();
          }
        }
      });

    } catch (e) {
      print('Error initializing video player in create article: $e');
    }
  }

  void _disposeVideoPlayer() {
    videoPlayerController?.dispose();
    videoPlayerController = null;
    isVideoInitialized.value = false;
    isVideoPlaying.value = false;
  }

  void toggleVideoPlayPause() {
    if (videoPlayerController == null || !isVideoInitialized.value) return;

    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
    } else {
      videoPlayerController!.play();
    }
  }

  void _updatePostButtonState() {
    final hasHeadline = headlineController.text.trim().isNotEmpty;
    final hasContent = quillController.document.toPlainText().trim().isNotEmpty;
    isPostButtonEnabled.value = hasHeadline && hasContent;
  }

  void showMediaPickerBottomSheet() {
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
              'Select cover media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('Photo'),
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
                _captureImage();
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
                _pickImage();
              },
            ),

            const Divider(height: 32),

            _buildSectionHeader('Video'),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0A8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.videocam, color: Color(0xFFFF0A8C)),
              ),
              title: const Text('Record with camera'),
              subtitle: const Text('Record a new video'),
              onTap: () {
                Get.back();
                _recordVideo();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0A8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.video_library, color: Color(0xFFFF0A8C)),
              ),
              title: const Text('Choose from gallery'),
              subtitle: const Text('Select existing video'),
              onTap: () {
                Get.back();
                _pickVideo();
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
      isScrollControlled: true,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF999999),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    final imagePath = await _mediaService.captureImageWithCamera();
    if (imagePath != null) {
      mediaType.value = MediaType.image;
      coverMediaPath.value = imagePath;
      editedImagePath.value = '';
      videoThumbnailPath.value = '';

      Get.toNamed(AppRoutes.EDIT_COVER);
    }
  }

  Future<void> _pickImage() async {
    final imagePath = await _mediaService.pickImageFromGallery();
    if (imagePath != null) {
      mediaType.value = MediaType.image;
      coverMediaPath.value = imagePath;
      editedImagePath.value = '';
      videoThumbnailPath.value = '';

      Get.toNamed(AppRoutes.EDIT_COVER);
    }
  }

  Future<void> _recordVideo() async {
    final videoPath = await _mediaService.recordVideoWithCamera();
    if (videoPath != null) {
      mediaType.value = MediaType.video;
      coverMediaPath.value = videoPath;
      editedImagePath.value = '';
      videoThumbnailPath.value = '';

      Get.toNamed(AppRoutes.EDIT_THUMBNAIL);
    }
  }

  Future<void> _pickVideo() async {
    final videoPath = await _mediaService.pickVideoFromGallery();
    if (videoPath != null) {
      mediaType.value = MediaType.video;
      coverMediaPath.value = videoPath;
      editedImagePath.value = '';
      videoThumbnailPath.value = '';

      Get.toNamed(AppRoutes.EDIT_THUMBNAIL);
    }
  }

  void deleteCoverMedia() {
    _disposeVideoPlayer();
    mediaType.value = MediaType.none;
    coverMediaPath.value = '';
    editedImagePath.value = '';
    videoThumbnailPath.value = '';
  }

  void editCoverMedia() {
    if (mediaType.value == MediaType.image) {
      Get.toNamed(AppRoutes.EDIT_COVER);
    } else if (mediaType.value == MediaType.video) {
      Get.toNamed(AppRoutes.EDIT_THUMBNAIL);
    }
  }

  void postArticle() {
    final htmlBody = _convertQuillToHtml();

    final article = Article(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      headline: headlineController.text.trim(),
      htmlBody: htmlBody,
      mediaType: mediaType.value,
      coverMediaPath: coverMediaPath.value.isEmpty ? null : coverMediaPath.value,
      editedImagePath: editedImagePath.value.isEmpty ? null : editedImagePath.value,
      videoThumbnailPath: videoThumbnailPath.value.isEmpty ? null : videoThumbnailPath.value,
    );

    print('Article JSON: ${jsonEncode(article.toJson())}');

    Get.snackbar(
      'Success',
      'Article posted successfully!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFF0A8C).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  String _convertQuillToHtml() {
    final delta = quillController.document.toDelta();
    final operations = delta.toList();

    StringBuffer html = StringBuffer();

    for (var op in operations) {
      if (op.data is String) {
        String text = op.data as String;
        final attrs = op.attributes;

        if (attrs != null) {
          if (attrs['bold'] == true) {
            text = '<strong>$text</strong>';
          }
          if (attrs['italic'] == true) {
            text = '<em>$text</em>';
          }
          if (attrs['underline'] == true) {
            text = '<u>$text</u>';
          }
          if (attrs['header'] != null) {
            final level = attrs['header'];
            text = '<h$level>$text</h$level>';
          }
          if (attrs['list'] == 'bullet') {
            text = '<li>$text</li>';
          }
          if (attrs['list'] == 'ordered') {
            text = '<li>$text</li>';
          }
        }

        html.write(text);
      }
    }

    return html.toString();
  }

  void showSettingsBottomSheet() {
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
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFFFF0A8C)),
              title: Text('About'),
            ),
            const ListTile(
              leading: Icon(Icons.help_outline, color: Color(0xFFFF0A8C)),
              title: Text('Help'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}