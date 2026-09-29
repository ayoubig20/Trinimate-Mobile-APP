import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Card for an open session: sport tag, title, date/time/place, fee, spots.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.sport,
    required this.title,
    required this.meta,
    required this.fee,
    this.spotsLeft,
    this.onTap,
  });

  final String sport;
  final String title;
  final String meta; // "Sat 4 Oct · 18:30 · Padel Club Agadir"
  final String fee; // "120 MAD — split 4 ways"
  final String? spotsLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  sport.toUpperCase(),
                  style: AppTextStyles.button(size: 11),
                ),
              ),
              const SizedBox(height: 10),
              Text(title, style: AppTextStyles.bodyMedium(size: 16)),
              const SizedBox(height: 6),
              Text(meta, style: AppTextStyles.body(size: 12, color: AppColors.textMuted)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(fee,
                        style: AppTextStyles.bodyMedium(
                            size: 12, color: AppColors.secondary)),
                  ),
                  if (spotsLeft != null)
                    Text(
                      spotsLeft!.toUpperCase(),
                      style: AppTextStyles.label(
                          size: 11,
                          color: AppColors.primary),
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