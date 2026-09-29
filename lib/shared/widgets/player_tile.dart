import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'player_avatar.dart';

/// Row used in Discover: avatar, name, "Sport · Level · 2.5 km", Ping button.
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.onTap,
    this.onPing,
  });

  final String name;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onPing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PlayerAvatar(name: name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyMedium(size: 15)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.body(size: 12, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onPing,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: Text('PING', style: AppTextStyles.button(size: 12, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}