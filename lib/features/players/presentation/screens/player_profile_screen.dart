import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key, required this.playerId});

  final String playerId;

  MockPlayer get player {
    for (final p in MockData.players) {
      if (p.id == playerId) return p;
    }
    return MockData.players.first;
  }

  @override
  Widget build(BuildContext context) {
    final p = player;
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
            const SizedBox(height: 12),
            Center(child: PlayerAvatar(name: p.name, radius: 44)),
            const SizedBox(height: 14),
            Text(p.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline(size: 26)),
            const SizedBox(height: 4),
            Text('${p.city} · ${p.distanceKm} km away',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _StatBox(
                        value: '${p.sessions}', label: 'Sessions')),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatBox(
                        value: p.rating.toStringAsFixed(1),
                        label: 'Rating')),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatBox(
                        value: '${p.responseRate}%', label: 'Response')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Tag(text: p.sport, filled: true),
                const SizedBox(width: 8),
                _Tag(text: p.level, filled: false),
              ],
            ),
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
                  Text(p.bio, style: AppTextStyles.body()),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Invite to play',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Invitation sent to ${p.name.split(' ').first}!')),
              ),
            ),
            const SizedBox(height: 16),
          ],
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