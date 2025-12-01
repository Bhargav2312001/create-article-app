import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'edit_cover_controller.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_outline_button.dart';
import '../../widgets/segmented_tab.dart';

class EditCoverPage extends GetView<EditCoverController> {
  const EditCoverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.cancel,
        ),
        title: const Text('Edit Image'),
        actions: [
          // NEW: Reset All button
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset All',
            onPressed: controller.showResetConfirmation,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildImagePreview()),
                Obx(() => _buildControlSection()),
              ],
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: SegmentedTab(
              label: 'Crop',
              icon: Icons.crop,
              isActive: controller.activeTabIndex.value == 0,
              onTap: () => controller.setActiveTab(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SegmentedTab(
              label: 'Filter',
              icon: Icons.filter,
              isActive: controller.activeTabIndex.value == 1,
              onTap: () => controller.setActiveTab(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SegmentedTab(
              label: 'Adjust',
              icon: Icons.tune,
              isActive: controller.activeTabIndex.value == 2,
              onTap: () => controller.setActiveTab(2),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Obx(() {
          Widget imageWidget = Image.file(
            File(controller.workingImagePath.value),
            fit: BoxFit.contain,
          );

          // Apply aspect ratio cropping visually
          final aspectRatio = controller.getAspectRatioValue();
          if (aspectRatio > 0) {
            imageWidget = AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: imageWidget,
                ),
              ),
            );
          }

          // Apply filter
          final filter = controller.getColorFilter();
          if (filter != null) {
            imageWidget = ColorFiltered(
              colorFilter: filter,
              child: imageWidget,
            );
          }

          // Apply adjustments
          final adjustFilter = controller.getAdjustmentFilter();
          if (adjustFilter != null) {
            imageWidget = ColorFiltered(
              colorFilter: adjustFilter,
              child: imageWidget,
            );
          }

          // Apply transformations
          imageWidget = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(controller.zoom.value)
              ..rotateZ(controller.getTotalRotation() * 3.14159 / 180),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(
                  controller.flipHorizontal.value ? -1.0 : 1.0,
                  controller.flipVertical.value ? -1.0 : 1.0,
                ),
              child: imageWidget,
            ),
          );

          return ClipRect(child: imageWidget);
        }),
      ),
    );
  }

  Widget _buildControlSection() {
    switch (controller.activeTabIndex.value) {
      case 0:
        return _buildCropControls();
      case 1:
        return _buildFilterControls();
      case 2:
        return _buildAdjustControls();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCropControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rotate & Flip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  icon: Icons.rotate_left,
                  label: 'Rotate Left',
                  onTap: controller.rotateLeft,
                ),
                _buildIconButton(
                  icon: Icons.rotate_right,
                  label: 'Rotate Right',
                  onTap: controller.rotateRight,
                ),
                _buildIconButton(
                  icon: Icons.flip,
                  label: 'Flip H',
                  onTap: controller.toggleFlipHorizontal,
                ),
                _buildIconButton(
                  icon: Icons.flip,
                  label: 'Flip V',
                  onTap: controller.toggleFlipVertical,
                  rotation: 90,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Aspect ratio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => InkWell(
              onTap: controller.showAspectRatioBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getAspectRatioLabel(
                          controller.selectedAspectRatio.value),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
            Obx(() => _buildSlider(
              label: 'Zoom',
              value: controller.zoom.value,
              min: 1.0,
              max: 3.0,
              onChanged: (value) => controller.zoom.value = value,
            )),
            const SizedBox(height: 16),
            Obx(() => _buildSlider(
              label: 'Straighten',
              value: controller.straightenAngle.value,
              min: -45.0,
              max: 45.0,
              onChanged: (value) => controller.straightenAngle.value = value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Obx(() => ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterOption(FilterPreset.none, 'None'),

                _buildFilterOption(FilterPreset.studio, 'Studio'),
                _buildFilterOption(FilterPreset.prime, 'Prime'),
                _buildFilterOption(FilterPreset.classic, 'Classic'),
                _buildFilterOption(FilterPreset.edge, 'Edge'),

                _buildFilterOption(FilterPreset.dual, 'Dual'),
                _buildFilterOption(FilterPreset.neon, 'Neon'),
                _buildFilterOption(FilterPreset.film, 'Film'),
                _buildFilterOption(FilterPreset.vintage, 'Vintage'),
                _buildFilterOption(FilterPreset.warm, 'Warm'),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(FilterPreset preset, String label) {
    final isSelected = controller.selectedFilter.value == preset;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => controller.setFilter(preset),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF0A8C)
                      : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildFilterThumbnail(preset),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFFFF0A8C)
                    : const Color(0xFF666666),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterThumbnail(FilterPreset preset) {
    Widget thumbnail = Image.file(
      File(controller.originalImagePath.value),
      fit: BoxFit.cover,
    );

    final tempController = EditCoverController(
      createArticleController: controller.createArticleController,
    );
    tempController.selectedFilter.value = preset;
    final filter = tempController.getColorFilter();

    if (filter != null) {
      thumbnail = ColorFiltered(
        colorFilter: filter,
        child: thumbnail,
      );
    }

    return thumbnail;
  }

  Widget _buildAdjustControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adjustments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => _buildSlider(
              label: 'Brightness',
              value: controller.brightness.value,
              min: -100.0,
              max: 100.0,
              onChanged: (value) => controller.brightness.value = value,
            )),
            const SizedBox(height: 16),
            Obx(() => _buildSlider(
              label: 'Contrast',
              value: controller.contrast.value,
              min: -100.0,
              max: 100.0,
              onChanged: (value) => controller.contrast.value = value,
            )),
            const SizedBox(height: 16),
            Obx(() => _buildSlider(
              label: 'Saturation',
              value: controller.saturation.value,
              min: -100.0,
              max: 100.0,
              onChanged: (value) => controller.saturation.value = value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double? rotation,
  }) {
    Widget iconWidget = Icon(icon, size: 24);

    if (rotation != null) {
      iconWidget = Transform.rotate(
        angle: rotation * 3.14159 / 180,
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: iconWidget,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFFF0A8C),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFFFF0A8C),
            overlayColor: const Color(0xFFFF0A8C).withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
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
      child: Obx(() {
        if (controller.isSaving.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Row(
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
        );
      }),
    );
  }

  String _getAspectRatioLabel(AspectRatioType type) {
    switch (type) {
      case AspectRatioType.original:
        return 'Original';
      case AspectRatioType.square:
        return 'Square';
      case AspectRatioType.fourToOne:
        return '4:1';
      case AspectRatioType.threeToFour:
        return '3:4';
      case AspectRatioType.sixteenToNine:
        return '16:9';
    }
  }
}