import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/tab_scaffold.dart';
import '../chat_controller.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  String _timeLabel(int millis) {
    if (millis == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsListProvider);

    return TabScaffold(
      current: AppTab.chats,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('CHATS', style: AppTextStyles.headline(size: 30)),
          const SizedBox(height: 16),
          chatsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary)),
            ),
            error: (e, _) => GestureDetector(
              onTap: () => ref.invalidate(chatsListProvider),
              child: Text('Could not load chats. TAP TO RETRY',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(color: AppColors.textMuted)),
            ),
            data: (chats) => chats.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                  'No conversations yet — ping a player from Discover!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                      color: AppColors.textMuted)),
            )
                : Column(
              children: [
                for (final c in chats)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ChatRow(
                      name: c['peerName'] as String,
                      lastMessage:
                      (c['lastMessage'] as String).isEmpty
                          ? 'Say hello!'
                          : c['lastMessage'] as String,
                      time: _timeLabel(c['lastTime'] as int),
                      onTap: () => context.push(
                          '${AppRoutes.chatThread}/${c['id']}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow(
      {required this.name,
        required this.lastMessage,
        required this.time,
        required this.onTap});

  final String name;
  final String lastMessage;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    Text(lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                            size: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(time,
                  style: AppTextStyles.body(
                      size: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}