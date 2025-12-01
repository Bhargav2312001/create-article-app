import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'edit_thumbnail_controller.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_outline_button.dart';

class EditThumbnailPage extends GetView<EditThumbnailController> {
  const EditThumbnailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.cancel,
        ),
        title: const Text('Add Video Thumbnail'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoPreview(),
                  const SizedBox(height: 24),
                  _buildThumbnailSection(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (!controller.isVideoInitialized.value) {
            return Container(
              height: Get.height * 0.4, // 40% of screen height
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Container(
            height: Get.height * 0.4, // 40% of screen height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video player
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(controller.videoPlayerController!),
                    ),
                  ),

                  // Thumbnail overlay if set
                  if (controller.thumbnailPath.value.isNotEmpty)
                    Obx(() => AnimatedOpacity(
                      opacity: controller.isPlaying.value ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Image.file(
                        File(controller.thumbnailPath.value),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )),

                  // Play/Pause button overlay
                  GestureDetector(
                    onTap: controller.togglePlayPause,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Obx(() => AnimatedOpacity(
                          opacity: controller.isPlaying.value ? 0.0 : 1.0,
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
                      ),
                    ),
                  ),

                  // Controls at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // Video progress slider
                          Obx(() => Slider(
                            value: controller.videoPosition.value,
                            min: 0.0,
                            max: controller.videoDuration.value,
                            activeColor: const Color(0xFFFF0A8C),
                            inactiveColor: Colors.white.withOpacity(0.3),
                            onChanged: (value) {
                              controller.seekTo(value);
                            },
                          )),

                          // Play/pause and time
                          Row(
                            children: [
                              Obx(() => IconButton(
                                icon: Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: controller.togglePlayPause,
                              )),
                              Obx(() => Text(
                                '${_formatDuration(controller.videoPosition.value.toInt())} / ${_formatDuration(controller.videoDuration.value.toInt())}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildThumbnailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Thumbnail',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.thumbnailPath.value.isEmpty) {
            return _buildEmptyThumbnailCard();
          } else {
            return _buildThumbnailPreview();
          }
        }),
      ],
    );
  }

  Widget _buildEmptyThumbnailCard() {
    return InkWell(
      onTap: controller.showThumbnailPickerBottomSheet,
      child: Container(
        height: 200,
        width: Get.width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
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
                Icons.image_outlined,
                size: 32,
                color: Color(0xFFFF0A8C),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add a thumbnail for your video',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to select',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(controller.thumbnailPath.value),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              _buildCircularIconButton(
                icon: Icons.edit,
                onTap: controller.pickThumbnail,
              ),
              const SizedBox(width: 8),
              _buildCircularIconButton(
                icon: Icons.delete_outline,
                onTap: controller.deleteThumbnail,
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _buildBottomActions() {
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
      child: Row(
        children: [
          Expanded(
            child: SecondaryOutlineButton(
              text: 'Cancel',
              onPressed: controller.cancel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              text: 'Done',
              onPressed: controller.saveAndReturn,
            ),
          ),
        ],
      ),
    );
  }
}