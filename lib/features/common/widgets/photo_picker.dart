import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class PhotoPicker extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final double size;
  final String? label;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isCircular;

  const PhotoPicker({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.size = 120,
    this.label,
    required this.onTap,
    this.isLoading = false,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      );
    } else if (imageFile != null) {
      content = Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      content = Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.error_outline,
            size: size * 0.5,
            color: AppColors.error,
          );
        },
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: size * 0.5,
            color: AppColors.textSecondary,
          ),
          if (label != null) ...[
            const SizedBox(height: 8),
            Text(
              label!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(isCircular ? size / 2 : 12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(child: content),
      ),
    );
  }
}
