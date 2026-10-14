import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'player_avatar.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    this.rating = 0,
    this.sessions = 0,
    this.distanceKm,
    this.sports = const [],
    this.onTap,
    this.onPing,
    this.pinged = false,
  });

  final String name;
  final String subtitle;
  final String? imageUrl;
  final double rating;
  final int sessions;
  final double? distanceKm;

  /// Labels like "Padel · Intermediate"
  final List<String> sports;
  final VoidCallback? onTap;
  final VoidCallback? onPing;
  final bool pinged;

  Widget _stat(IconData icon, String value, {Color? iconColor}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: iconColor ?? AppColors.textMuted),
      const SizedBox(width: 4),
      Text(value, style: AppTextStyles.bodyMedium(size: 13)),
    ],
  );

  Widget _chip(String label, {bool highlight = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: highlight
          ? AppColors.primary.withOpacity(0.16)
          : AppColors.surface2,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: AppTextStyles.bodyMedium(
        size: 11,
        color: highlight ? AppColors.primary : AppColors.text,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pingColor = pinged ? AppColors.textMuted : AppColors.primary;
    final shown = sports.take(2).toList();
    final extra = sports.length - shown.length;
    final radius = BorderRadius.circular(14);

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              PlayerAvatar(name: name, imageUrl: imageUrl, radius: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium(size: 16),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _stat(Icons.star_rounded,
                            rating > 0 ? rating.toStringAsFixed(1) : 'New',
                            iconColor: AppColors.secondary),
                        _stat(Icons.event_available_outlined,
                            '$sessions games'),
                        if (distanceKm != null)
                          _stat(Icons.place_outlined,
                              '${distanceKm!.toStringAsFixed(1)} km'),
                      ],
                    ),
                    if (shown.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final s in shown) _chip(s, highlight: true),
                          if (extra > 0) _chip('+$extra'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onPing,
                style: TextButton.styleFrom(
                  foregroundColor: pingColor,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const StadiumBorder(),
                  side: BorderSide(color: pingColor),
                ),
                child: Text(
                  pinged ? 'UNPING' : 'PING',
                  style: AppTextStyles.button(size: 12, color: pingColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}