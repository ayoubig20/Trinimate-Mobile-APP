import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PhotoSetupScreen extends StatefulWidget {
  const PhotoSetupScreen({super.key});

  @override
  State<PhotoSetupScreen> createState() => _PhotoSetupScreenState();
}

class _PhotoSetupScreenState extends State<PhotoSetupScreen> {
  final _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) setState(() => _imagePath = picked.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick an image')),
      );
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.text),
              title: Text('Take a photo',
                  style: AppTextStyles.bodyMedium()),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.text),
              title: Text('Choose from gallery',
                  style: AppTextStyles.bodyMedium()),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _onNext() => context.push(AppRoutes.notificationsSetup);
  void _onSkip() => context.push(AppRoutes.notificationsSetup);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Add a photo'.toUpperCase(),
                style: AppTextStyles.headline(size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'Profiles with a real photo get up to 3x more responses.',
                style: AppTextStyles.body(color: AppColors.textMuted),
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: _showSourceSheet,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.divider),
                      image: _imagePath != null
                          ? DecorationImage(
                        image: FileImage(File(_imagePath!)),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _imagePath == null
                        ? const Icon(Icons.add_a_photo_outlined,
                        color: AppColors.textMuted, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: _showSourceSheet,
                  child: Text(
                    _imagePath == null
                        ? 'TAP TO ADD PHOTO'
                        : 'TAP TO CHANGE PHOTO',
                    style: AppTextStyles.label(color: AppColors.primary),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _onSkip,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: const BorderSide(color: AppColors.divider),
                          shape: const StadiumBorder(),
                        ),
                        child: Text('SKIP',
                            style: AppTextStyles.button(color: AppColors.text)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        child: Text('NEXT',
                            style: AppTextStyles.button(color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}