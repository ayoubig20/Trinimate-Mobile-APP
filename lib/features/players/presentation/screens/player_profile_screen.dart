import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../discover/presentation/discover_controller.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(playerId) ?? 0;
    final playerAsync = ref.watch(playerDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: playerAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load player.',
                    style: AppTextStyles.body(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => ref.invalidate(playerDetailProvider(id)),
                  child: Text('TAP TO RETRY',
                      style:
                      AppTextStyles.label(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          data: (p) {
            final sports = (p['sports'] as List<dynamic>?) ?? [];
            final sport = sports.isNotEmpty
                ? sports[0]['sport'] as String? ?? ''
                : '';
            final level = sports.isNotEmpty
                ? sports[0]['level'] as String? ?? ''
                : '';
            return ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.arrow_back_ios_new,
                        color: AppColors.text, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                    child: PlayerAvatar(
                        name: p['name'] as String? ?? '?', radius: 44)),
                const SizedBox(height: 14),
                Text(p['name'] as String? ?? '',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline(size: 26)),
                const SizedBox(height: 4),
                Text(p['city'] as String? ?? '',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(color: AppColors.textMuted)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            value: '${p['sessions'] ?? 0}',
                            label: 'Sessions')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatBox(
                            value:
                            '${p['rating'] ?? 0}',
                            label: 'Rating')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatBox(
                            value: '${p['responseRate'] ?? 0}%',
                            label: 'Response')),
                  ],
                ),
                const SizedBox(height: 16),
                if (sport.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Tag(text: sport, filled: true),
                      if (level.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _Tag(text: level, filled: false),
                      ],
                    ],
                  ),
                if ((p['bio'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ABOUT', style: AppTextStyles.label()),
                        const SizedBox(height: 8),
                        Text(p['bio'] as String,
                            style: AppTextStyles.body()),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Invite to play',
                  onPressed: () =>
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Invitation sent!')),
                      ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headline(size: 22)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: AppTextStyles.label(size: 10)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.filled});

  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text.toUpperCase(),
          style: AppTextStyles.button(
              size: 11,
              color: filled ? Colors.white : AppColors.textMuted)),
    );
  }
}