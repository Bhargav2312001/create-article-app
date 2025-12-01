import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'create_article_controller.dart';
import '../../models/media_type.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';

class CreateArticlePage extends GetView<CreateArticleController> {
  const CreateArticlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Create Article'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: controller.showSettingsBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeadlineField(),
                  const SizedBox(height: 24),
                  _buildCoverMediaSection(),
                  const SizedBox(height: 24),
                  _buildHtmlEditorSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomPostButton(),
        ],
      ),
    );
  }

  Widget _buildHeadlineField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Headline',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.headlineController,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
          decoration: InputDecoration(
            hintText: 'Enter headline...',
            hintStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildCoverMediaSection() {
    return Obx(() {
      if (controller.mediaType.value == MediaType.none) {
        return _buildEmptyCoverCard();
      } else {
        return _buildCoverPreview();
      }
    });
  }

  Widget _buildEmptyCoverCard() {
    return SectionCard(
      child: InkWell(
        onTap: controller.showMediaPickerBottomSheet,
        child: Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0A8C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: Color(0xFFFF0A8C),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose a cover image or video for your article',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Obx(() {
            if (controller.mediaType.value == MediaType.image) {
              // FIXED: Force rebuild when image changes using ValueKey
              final imagePath = controller.editedImagePath.value.isNotEmpty
                  ? controller.editedImagePath.value
                  : controller.coverMediaPath.value;

              print('Displaying image: $imagePath'); // Debug log

              return Image.file(
                File(imagePath),
                key: ValueKey(imagePath), // IMPORTANT: Forces rebuild on path change
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, size: 64, color: Colors.red),
                    ),
                  );
                },
              );
            } else {
              return _buildVideoThumbnailPreview();
            }
          }),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              _buildCircularIconButton(
                icon: Icons.edit,
                onTap: controller.editCoverMedia,
              ),
              const SizedBox(width: 8),
              _buildCircularIconButton(
                icon: Icons.delete_outline,
                onTap: controller.deleteCoverMedia,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoThumbnailPreview() {
    return Obx(() {
      // If thumbnail is set, show thumbnail with play overlay
      if (controller.videoThumbnailPath.value.isNotEmpty) {
        return GestureDetector(
          onTap: controller.toggleVideoPlayPause,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Show video player if playing, otherwise show thumbnail
                Obx(() {
                  if (controller.isVideoPlaying.value && controller.isVideoInitialized.value) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: controller.videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(controller.videoPlayerController!),
                      ),
                    );
                  } else {
                    return Image.file(
                      File(controller.videoThumbnailPath.value),
                      key: ValueKey(controller.videoThumbnailPath.value),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    );
                  }
                }),

                // Play/Pause overlay (hide when playing)
                Obx(() => AnimatedOpacity(
                  opacity: controller.isVideoPlaying.value ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      } else {
        // No thumbnail set - show placeholder
        return Container(
          width: double.infinity,
          height: 250,
          color: Colors.grey[300],
          child: const Icon(
            Icons.videocam,
            size: 64,
            color: Colors.grey,
          ),
        );
      }
    });
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFF222222),
        ),
      ),
    );
  }

  Widget _buildHtmlEditorSection() {
    return SectionCard(
      child: Column(
        children: [
          quill.QuillSimpleToolbar(
            controller: controller.quillController,
            config: const quill.QuillSimpleToolbarConfig(
              showAlignmentButtons: true,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showListBullets: true,
              showListNumbers: true,
              showCodeBlock: false,
              showInlineCode: false,
              showLink: true,
              showClearFormat: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showHeaderStyle: false,
              multiRowsDisplay: false,
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 300,
            padding: const EdgeInsets.all(12),
            child: quill.QuillEditor.basic(
              controller: controller.quillController,
              config: const quill.QuillEditorConfig(
                placeholder: 'Start writing...',
                padding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPostButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final isEnabled = controller.isPostButtonEnabled.value;
        return PrimaryButton(
          text: 'Post',
          onPressed: isEnabled ? controller.postArticle : null,
          enabled: isEnabled,
        );
      }),
    );
  }
}