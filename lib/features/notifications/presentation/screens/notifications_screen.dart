import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  (IconData, Color) _iconFor(String type) => switch (type) {
    'ping_accepted' =>
    (Icons.handshake_outlined, AppColors.primary),
    'pickup_game' =>
    (Icons.sports_soccer_outlined, AppColors.secondary),
    'new_message' => (Icons.chat_bubble_outline, AppColors.primary),
    _ => (Icons.notifications_outlined, AppColors.textMuted),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.text, size: 20),
                ),
                const SizedBox(width: 14),
                Text('NOTIFICATIONS',
                    style: AppTextStyles.headline(size: 26)),
              ],
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < MockData.notifications.length; i++) ...[
              _NotificationTile(
                icon: _iconFor(MockData.notifications[i].type).$1,
                iconColor: _iconFor(MockData.notifications[i].type).$2,
                title: MockData.notifications[i].title,
                body: MockData.notifications[i].body,
                time: MockData.notifications[i].time,
                isUnread: i < 2,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium(size: 14)),
                const SizedBox(height: 3),
                Text(body,
                    style: AppTextStyles.body(
                        size: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time,
              style: AppTextStyles.body(
                  size: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}