import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Pill-shaped sport chip. Selected = orange fill, unselected = dark surface.
class SportChip extends StatelessWidget {
  const SportChip({
    super.key,
    required this.sport,
    required this.selected,
    this.onTap,
  });

  final String sport;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          sport.toUpperCase(),
          style: AppTextStyles.button(
            color: selected ? Colors.white : AppColors.textMuted,
            size: 13,
          ),
        ),
      ),
    );
  }
}