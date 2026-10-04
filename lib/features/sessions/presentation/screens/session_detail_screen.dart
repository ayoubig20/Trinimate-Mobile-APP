import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  MockSession get session {
    for (final s in MockData.sessions) {
      if (s.id == sessionId) return s;
    }
    return MockData.sessions.first;
  }

  @override
  Widget build(BuildContext context) {
    final s = session;
    final joined = MockData.players.take(s.playersJoined).toList();
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.text, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(s.sport.toUpperCase(),
                        style: AppTextStyles.button(size: 11)),
                  ),
                  const SizedBox(height: 12),
                  Text(s.title, style: AppTextStyles.headline(size: 26)),
                  const SizedBox(height: 12),
                  _MetaRow(
                      icon: Icons.calendar_today_outlined,
                      text: s.dateTimeLabel),
                  const SizedBox(height: 8),
                  _MetaRow(icon: Icons.place_outlined, text: s.place),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  for (var i = 0;
                  i < joined.length && i < 3;
                  i++) ...[
                    PlayerAvatar(name: joined[i].name, radius: 18),
                    if (i < joined.length - 1 && i < 2)
                      const SizedBox(width: 8),
                  ],
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${s.playersJoined}/${s.playersNeeded} players joined',
                      style: AppTextStyles.body(color: AppColors.textMuted),
                    ),
                  ),
                  if (s.playersJoined < s.playersNeeded)
                    Text('${s.playersNeeded - s.playersJoined} SPOTS LEFT',
                        style: AppTextStyles.label(
                            size: 11, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.fee,
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.secondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Message',
              icon: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.text, size: 20),
              onPressed: () => context.push('${AppRoutes.chatThread}/c1'),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Join session',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You joined the session!')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.body(color: AppColors.textMuted)),
      ],
    );
  }
}