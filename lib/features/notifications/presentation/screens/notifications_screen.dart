import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../notifications_controller.dart';

String _timeLabel(int millis) {
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  (IconData, Color) _iconFor(String type) => switch (type) {
    'ping' => (Icons.handshake_outlined, AppColors.primary),
    'session' => (Icons.sports_soccer_outlined, AppColors.secondary),
    'new_message' => (Icons.chat_bubble_outline, AppColors.primary),
    _ => (Icons.notifications_outlined, AppColors.textMuted),
  };

  Future<void> _openChatWith(
      BuildContext context, int userId) async {
    try {
      final res =
      await ApiClient.instance.post('/chats/with/$userId');
      if (!context.mounted) return;
      context.push('${AppRoutes.chatThread}/${res.data['chatId']}');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);

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
            notifsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: GestureDetector(
                  onTap: () => ref.invalidate(notificationsProvider),
                  child: Text('Could not load notifications. TAP TO RETRY',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                          color: AppColors.textMuted)),
                ),
              ),
              data: (items) => items.isEmpty
                  ? Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                    'No notifications yet.\nPing a player from Discover!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                        color: AppColors.textMuted)),
              )
                  : Column(
                children: [
                  for (final n in items)
                    Padding(
                      padding:
                      const EdgeInsets.only(bottom: 10),
                      child: _NotificationTile(
                        icon: _iconFor(n['type'] as String).$1,
                        iconColor:
                        _iconFor(n['type'] as String).$2,
                        title: n['title'] as String,
                        body: n['body'] as String,
                        time: _timeLabel(
                            n['createdAt'] as int),
                        isUnread:
                        !(n['read'] as bool? ?? true),
                        // Tap a ping → open chat with that user
                        onTap: (n['type'] == 'ping' &&
                            n['refId'] != null)
                            ? () => _openChatWith(
                            context, n['refId'] as int)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
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
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}