import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/tab_scaffold.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  double _levelPercent(String level) => switch (level) {
    'Beginner' => 0.33,
    'Intermediate' => 0.66,
    'Advanced' => 0.9,
    _ => 1.0,
  };

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            for (final (code, label) in [
              ('en', 'English'),
              ('fr', 'Français'),
              ('zh', '中文'),
            ])
              ListTile(
                title: Text(label, style: AppTextStyles.bodyMedium()),
                trailing:
                ref.watch(localeProvider).languageCode == code
                    ? const Icon(Icons.check,
                    color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).state =
                      Locale(code);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref,
      Map<String, dynamic> user) async {
    final nameCtrl =
    TextEditingController(text: user['name'] as String? ?? '');
    final cityCtrl =
    TextEditingController(text: user['city'] as String? ?? '');
    final bioCtrl =
    TextEditingController(text: user['bio'] as String? ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title:
        Text('EDIT PROFILE', style: AppTextStyles.headline(size: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: AppTextStyles.bodyMedium(),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: cityCtrl,
              style: AppTextStyles.bodyMedium(),
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: bioCtrl,
              style: AppTextStyles.bodyMedium(),
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL',
                style: AppTextStyles.button(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('SAVE',
                style: AppTextStyles.button(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (saved == true) {
      final ok = await updateProfile(ref, {
        'name': nameCtrl.text.trim(),
        'city': cityCtrl.text.trim(),
        'bio': bioCtrl.text.trim(),
      });
      nameCtrl.dispose();
      cityCtrl.dispose();
      bioCtrl.dispose();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Profile updated' : 'Update failed')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final currentLocale = ref.watch(localeProvider).languageCode;
    final languageLabel = switch (currentLocale) {
      'fr' => 'Français',
      'zh' => '中文',
      _ => 'English',
    };

    return TabScaffold(
      current: AppTab.profile,
      child: userAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: GestureDetector(
            onTap: () => ref.invalidate(currentUserProvider),
            child: Text('Could not load profile. TAP TO RETRY',
                style: AppTextStyles.body(color: AppColors.textMuted)),
          ),
        ),
        data: (user) {
          final sports = (user['sports'] as List<dynamic>?) ?? [];
          final level = sports.isNotEmpty
              ? sports[0]['level'] as String? ?? ''
              : '';
          final city = user['city'] as String? ?? '';
          final name = user['name'] as String? ?? '?';
          final rating = (user['rating'] as num?)?.toDouble() ?? 0;
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(currentUserProvider),
            child: ListView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Text('PROFILE', style: AppTextStyles.headline(size: 30)),
                const SizedBox(height: 20),

                // Identity card — REAL data
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      PlayerAvatar(name: name, radius: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style:
                                AppTextStyles.bodyMedium(size: 17)),
                            const SizedBox(height: 2),
                            Text(
                              [city, level]
                                  .where((s) => s.isNotEmpty)
                                  .join(' · '),
                              style: AppTextStyles.body(
                                  size: 12,
                                  color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () =>
                                  _editProfile(context, ref, user),
                              child: Text('EDIT PROFILE',
                                  style: AppTextStyles.label(
                                      size: 11,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Skill bars + PLAYER CARDS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MY SPORTS', style: AppTextStyles.label()),
                      const SizedBox(height: 14),
                      if (sports.isEmpty)
                        Text('No sports selected yet.',
                            style: AppTextStyles.body(
                                color: AppColors.textMuted))
                      else ...[
                        for (var i = 0; i < sports.length; i++) ...[
                          if (i > 0) const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sports[i]['sport'] as String,
                                  style: AppTextStyles.bodyMedium(
                                      size: 14)),
                              Text(sports[i]['level'] as String,
                                  style: AppTextStyles.body(
                                      size: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: _levelPercent(
                                  sports[i]['level'] as String),
                              minHeight: 7,
                              backgroundColor: AppColors.surface2,
                              valueColor:
                              const AlwaysStoppedAnimation(
                                  AppColors.primary),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        // ---- PLAYER CARDS (tap = fullscreen) ----
                        SizedBox(
                          height: 245,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (final sp in sports)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 12),
                                  child: GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        backgroundColor:
                                        Colors.transparent,
                                        insetPadding:
                                        const EdgeInsets.all(24),
                                        child: _PlayerCard(
                                          name: name,
                                          sport: sp['sport'] as String,
                                          level: sp['level'] as String,
                                          rating: rating,
                                          large: true,
                                        ),
                                      ),
                                    ),
                                    child: _PlayerCard(
                                      name: name,
                                      sport: sp['sport'] as String,
                                      level: sp['level'] as String,
                                      rating: rating,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Settings card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_outlined,
                            color: AppColors.textMuted, size: 20),
                        title: Text('Language',
                            style: AppTextStyles.bodyMedium(size: 14)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(languageLabel,
                                style: AppTextStyles.body(
                                    size: 13,
                                    color: AppColors.textMuted)),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textMuted, size: 18),
                          ],
                        ),
                        onTap: () => _showLanguagePicker(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Logout
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .logout();
                    if (!context.mounted) return;
                    context.go(AppRoutes.login);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout,
                            color: Color(0xFFFF3B30), size: 18),
                        const SizedBox(width: 8),
                        Text('LOG OUT',
                            style: AppTextStyles.button(
                                color: const Color(0xFFFF3B30))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// FUT-style shield player card. Rating comes from the backend when > 0
/// (real ratings from other players), otherwise derived from skill level.
class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.name,
    required this.sport,
    required this.level,
    this.rating = 0,
    this.large = false,
  });

  final String name;
  final String sport;
  final String level;
  final double rating;
  final bool large;

  int get _levelRating => switch (level) {
    'Beginner' => 72,
    'Intermediate' => 80,
    'Advanced' => 88,
    _ => 94,
  };

  int get shownRating => rating > 0 ? rating.round() : _levelRating;

  int _stat(int seed, int spread) =>
      (shownRating - 10 + (sport.hashCode + seed * 31) % spread)
          .clamp(40, 99);

  String get _pos => switch (sport) {
    'Football' => 'ST',
    'Basketball' => 'PG',
    'Padel' => 'CF',
    'Tennis' => 'ACE',
    'Running' => 'SPD',
    'Cycling' => 'RDR',
    _ => 'ATH',
  };

  IconData get _icon => switch (sport) {
    'Football' => Icons.sports_soccer,
    'Basketball' => Icons.sports_basketball,
    'Tennis' => Icons.sports_tennis,
    'Padel' => Icons.sports_tennis,
    'Running' => Icons.directions_run,
    'Cycling' => Icons.directions_bike,
    _ => Icons.emoji_events,
  };

  List<String> get _statNames => switch (sport) {
    'Football' => ['PAC', 'SHO', 'PAS', 'DRI', 'DEF', 'PHY'],
    'Basketball' => ['SPD', '3PT', 'PAS', 'DRI', 'DEF', 'JMP'],
    'Padel' => ['VOL', 'SMA', 'SER', 'NET', 'DEF', 'STA'],
    'Tennis' => ['SER', 'RET', 'VOL', 'BAC', 'FOR', 'SPD'],
    'Running' => ['SPD', 'STA', 'AGI', 'POW', 'REC', 'WIL'],
    'Cycling' => ['PWR', 'STA', 'SPD', 'CLB', 'DES', 'REC'],
    _ => ['SPD', 'PWR', 'TEC', 'STA', 'DEF', 'AGI'],
  };

  @override
  Widget build(BuildContext context) {
    final stats = _statNames;
    final scale = large ? 1.55 : 1.0;
    return ClipPath(
      clipper: _ShieldClipper(),
      child: Container(
        width: 170 * scale,
        height: 235 * scale,
        padding: EdgeInsets.fromLTRB(
            13 * scale, 10 * scale, 13 * scale, 11 * scale),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E8A6D), Color(0xFF0B3D33)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$shownRating',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25 * scale,
                            fontWeight: FontWeight.w900)),
                    Text(_pos,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12 * scale)),
                    SizedBox(height: 3 * scale),
                    Icon(_icon,
                        color: Colors.white70, size: 18 * scale),
                  ],
                ),
                const Spacer(),
                PlayerAvatar(name: name, radius: 24 * scale),
              ],
            ),
            SizedBox(height: 5 * scale),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name.split(' ').first.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14 * scale,
                      letterSpacing: 1),
                ),
              ),
            ),
            SizedBox(height: 1 * scale),
            Center(
              child: Text('$sport · $level',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 8.5 * scale)),
            ),
            SizedBox(height: 7 * scale),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var col = 0; col < 2; col++)
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = col * 3; i < col * 3 + 3; i++)
                          Text(
                            '${_stat(i + 1, 18)}  ${stats[i]}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.5 * scale),
                          ),
                      ],
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

class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(w * 0.02, h * 0.06)
      ..quadraticBezierTo(w * 0.02, 0, w * 0.14, 0)
      ..lineTo(w * 0.36, 0)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.64, 0)
      ..lineTo(w * 0.86, 0)
      ..quadraticBezierTo(w * 0.98, 0, w * 0.98, h * 0.06)
      ..lineTo(w * 0.98, h * 0.55)
      ..quadraticBezierTo(w * 0.98, h * 0.82, w * 0.5, h * 0.99)
      ..quadraticBezierTo(w * 0.02, h * 0.82, w * 0.02, h * 0.55)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}