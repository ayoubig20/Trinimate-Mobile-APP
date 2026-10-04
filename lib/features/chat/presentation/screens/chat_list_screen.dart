import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/tab_scaffold.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      current: AppTab.chats,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('CHATS', style: AppTextStyles.headline(size: 30)),
          const SizedBox(height: 16),
          for (final c in MockData.chats) ...[
            _ChatRow(chat: c),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat});

  final MockChatPreview chat;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.push('${AppRoutes.chatThread}/${chat.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PlayerAvatar(name: chat.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat.name,
                        style: AppTextStyles.bodyMedium(size: 15)),
                    const SizedBox(height: 2),
                    Text(chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                            size: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(chat.time,
                      style: AppTextStyles.body(
                          size: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  if (chat.unread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}