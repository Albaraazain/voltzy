import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class MultiplePhotoPicker extends StatelessWidget {
  final List<String> selectedPhotos;
  final Function(List<String>) onPhotosSelected;
  final double size;
  final bool isLoading;

  const MultiplePhotoPicker({
    super.key,
    required this.selectedPhotos,
    required this.onPhotosSelected,
    this.size = 120,
    this.isLoading = false,
  });

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      final List<String> newPhotos =
          pickedFiles.map((file) => file.path).toList();
      onPhotosSelected([...selectedPhotos, ...newPhotos]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedPhotos.map((photo) => _buildPhotoItem(photo)),
            if (selectedPhotos.length < 5) _buildAddButton(),
          ],
        ),
        if (selectedPhotos.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Tap photos to remove them',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoItem(String photo) {
    return GestureDetector(
      onTap: () {
        final List<String> updatedPhotos = List.from(selectedPhotos)
          ..remove(photo);
        onPhotosSelected(updatedPhotos);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: photo.startsWith('http')
            ? Image.network(
                photo,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                  );
                },
              )
            : Image.file(
                File(photo),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: isLoading ? null : _pickImages,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: size * 0.3,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add Photo',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
