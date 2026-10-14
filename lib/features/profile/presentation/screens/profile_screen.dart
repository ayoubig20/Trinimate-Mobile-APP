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
import 'dart:io';
import 'package:image_picker/image_picker.dart';
String _cap(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  double _levelPercent(String level) => switch (level.toLowerCase()) {
    'beginner' => 0.33,
    'intermediate' => 0.66,
    'advanced' => 0.9,
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
    final currentUrl = user['avatarUrl'] as String?;
    final hasCurrent = currentUrl != null && currentUrl.isNotEmpty;
    final picker = ImagePicker();
    XFile? pickedImage;
    bool removePhoto = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> pick(ImageSource source) async {
            try {
              final f = await picker.pickImage(
                source: source,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 80,
              );
              if (f != null) {
                setState(() {
                  pickedImage = f;
                  removePhoto = false;
                });
              }
            } catch (_) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Could not open camera or gallery')));
              }
            }
          }

          void chooseSource() {
            showModalBottomSheet(
              context: ctx,
              backgroundColor: AppColors.surface,
              builder: (sheetCtx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_camera_outlined,
                          color: AppColors.text),
                      title: Text('Take a photo',
                          style: AppTextStyles.bodyMedium()),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        pick(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined,
                          color: AppColors.text),
                      title: Text('Choose from gallery',
                          style: AppTextStyles.bodyMedium()),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        pick(ImageSource.gallery);
                      },
                    ),
                    if (pickedImage != null || (hasCurrent && !removePhoto))
                      ListTile(
                        leading: const Icon(Icons.delete_outline,
                            color: Color(0xFFFF3B30)),
                        title: Text('Remove photo',
                            style: AppTextStyles.bodyMedium(
                                color: const Color(0xFFFF3B30))),
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          setState(() {
                            pickedImage = null;
                            removePhoto = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          final previewName =
          nameCtrl.text.trim().isEmpty ? '?' : nameCtrl.text.trim();

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('EDIT PROFILE',
                style: AppTextStyles.headline(size: 20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: chooseSource,
                    child: Stack(
                      children: [
                        if (pickedImage != null)
                          CircleAvatar(
                            radius: 44,
                            backgroundImage:
                            FileImage(File(pickedImage!.path)),
                          )
                        else
                          PlayerAvatar(
                            name: previewName,
                            radius: 44,
                            imageUrl: removePhoto ? null : currentUrl,
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('CANCEL',
                    style:
                    AppTextStyles.button(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('SAVE',
                    style: AppTextStyles.button(color: AppColors.primary)),
              ),
            ],
          );
        },
      ),
    );

    if (saved == true) {
      final ok = await updateProfile(ref, {
        'name': nameCtrl.text.trim(),
        'city': cityCtrl.text.trim(),
        'bio': bioCtrl.text.trim(),
      });

      String? photoError;
      if (pickedImage != null) {
        photoError = await uploadAvatar(ref, pickedImage!);
      } else if (removePhoto && hasCurrent) {
        if (!await removeAvatar(ref)) photoError = 'Could not remove photo';
      }

      nameCtrl.dispose();
      cityCtrl.dispose();
      bioCtrl.dispose();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(photoError ??
              (ok ? 'Profile updated' : 'Update failed'))));
    } else {
      nameCtrl.dispose();
      cityCtrl.dispose();
      bioCtrl.dispose();
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
          final avatarUrl = user['avatarUrl'] as String?;      // NEW
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
                      PlayerAvatar(name: name, radius: 30, imageUrl: avatarUrl),
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
                              Text(_cap(sports[i]['level'] as String),
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
                                          imageUrl: avatarUrl,
                                          large: true,
                                        ),
                                      ),
                                    ),
                                    child: _PlayerCard(
                                      name: name,
                                      sport: sp['sport'] as String,
                                      level: sp['level'] as String,
                                      rating: rating,
                                      imageUrl: avatarUrl,
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
class _SportSpec {
  const _SportSpec(this.colors, this.accent, this.pos, this.icon, this.stats);
  final List<Color> colors;
  final Color accent;
  final String pos;
  final IconData icon;
  final List<String> stats; // exactly 6
}

const _defaultSpec = _SportSpec(
  [Color(0xFF455A64), Color(0xFF1C262B)],
  Color(0xFFD4EE2C),
  'ATH',
  Icons.emoji_events,
  ['SPD', 'PWR', 'TEC', 'STA', 'DEF', 'AGI'],
);

/// Keys are lowercase sport names.
const _sportSpecs = <String, _SportSpec>{
  'football': _SportSpec([Color(0xFF0E8A6D), Color(0xFF0B3D33)],
      Color(0xFFB6F36B), 'ST', Icons.sports_soccer,
      ['PAC', 'SHO', 'PAS', 'DRI', 'DEF', 'PHY']),
  'basketball': _SportSpec([Color(0xFFFF7A1A), Color(0xFF6B2800)],
      Color(0xFFFFD9A8), 'PG', Icons.sports_basketball,
      ['SPD', '3PT', 'PAS', 'DRI', 'DEF', 'JMP']),
  'tennis': _SportSpec([Color(0xFF8DB600), Color(0xFF334700)],
      Color(0xFFF4FF8A), 'ACE', Icons.sports_tennis,
      ['SER', 'RET', 'VOL', 'BAC', 'FOR', 'SPD']),
  'padel': _SportSpec([Color(0xFF1E88E5), Color(0xFF0A2A57)],
      Color(0xFF8FD3FF), 'CF', Icons.sports_tennis,
      ['VOL', 'SMA', 'SER', 'NET', 'DEF', 'STA']),
  'running': _SportSpec([Color(0xFFE53935), Color(0xFF560C0A)],
      Color(0xFFFFB3AE), 'SPD', Icons.directions_run,
      ['SPD', 'STA', 'AGI', 'POW', 'REC', 'WIL']),
  'cycling': _SportSpec([Color(0xFF8E44F5), Color(0xFF2A0F5E)],
      Color(0xFFD9B8FF), 'RDR', Icons.directions_bike,
      ['PWR', 'STA', 'SPD', 'CLB', 'DES', 'REC']),
  'volleyball': _SportSpec([Color(0xFFF2A900), Color(0xFF6B4300)],
      Color(0xFFFFE9A8), 'OH', Icons.sports_volleyball,
      ['SPK', 'BLK', 'SRV', 'DIG', 'SET', 'JMP']),
  'swimming': _SportSpec([Color(0xFF00ACC1), Color(0xFF00424B)],
      Color(0xFFA8F3FF), 'FRE', Icons.pool,
      ['SPD', 'STA', 'TEC', 'TRN', 'POW', 'REC']),
  'boxing': _SportSpec([Color(0xFFB71C1C), Color(0xFF1A0505)],
      Color(0xFFFFC2C2), 'MID', Icons.sports_mma,
      ['PWR', 'SPD', 'DEF', 'CHN', 'FTW', 'STA']),
  'handball': _SportSpec([Color(0xFF3949AB), Color(0xFF111A4D)],
      Color(0xFFC5CAFF), 'PIV', Icons.sports_handball,
      ['SHO', 'PAS', 'DEF', 'SPD', 'PWR', 'GKP']),
  'rugby': _SportSpec([Color(0xFF6D4C41), Color(0xFF2A1B16)],
      Color(0xFFFFCCBC), 'FLY', Icons.sports_rugby,
      ['PWR', 'TKL', 'SPD', 'PAS', 'KCK', 'STA']),
  'cricket': _SportSpec([Color(0xFF26A69A), Color(0xFF0B3B36)],
      Color(0xFFB2F5EA), 'BAT', Icons.sports_cricket,
      ['BAT', 'BWL', 'FLD', 'SPD', 'STA', 'CAT']),
  'baseball': _SportSpec([Color(0xFF283593), Color(0xFF0D1240)],
      Color(0xFFC5CAFF), 'SS', Icons.sports_baseball,
      ['HIT', 'PWR', 'THR', 'FLD', 'SPD', 'CAT']),
  'golf': _SportSpec([Color(0xFF43A047), Color(0xFF14361A)],
      Color(0xFFC8F7B5), 'PRO', Icons.sports_golf,
      ['DRV', 'IRN', 'PUT', 'CHP', 'CLT', 'STA']),
  'yoga': _SportSpec([Color(0xFFD81B8A), Color(0xFF4A0A33)],
      Color(0xFFFFB3E0), 'ZEN', Icons.self_improvement,
      ['FLX', 'BAL', 'STR', 'FOC', 'BRE', 'STA']),
  'pilates': _SportSpec([Color(0xFFEC407A), Color(0xFF55122A)],
      Color(0xFFFFC1D6), 'COR', Icons.self_improvement,
      ['COR', 'FLX', 'BAL', 'STR', 'CTL', 'STA']),
  'fitness': _SportSpec([Color(0xFF546E7A), Color(0xFF151F24)],
      Color(0xFFD4EE2C), 'GYM', Icons.fitness_center,
      ['STR', 'PWR', 'STA', 'AGI', 'FLX', 'REC']),
  'hiking': _SportSpec([Color(0xFF6D8B3A), Color(0xFF22300F)],
      Color(0xFFDDF0B0), 'TRL', Icons.hiking,
      ['STA', 'CLB', 'NAV', 'PWR', 'BAL', 'REC']),
  'badminton': _SportSpec([Color(0xFF00BFA5), Color(0xFF00382F)],
      Color(0xFFA7FFF0), 'SMS', Icons.sports_tennis,
      ['SMA', 'NET', 'DEF', 'SPD', 'STA', 'DRP']),
  'squash': _SportSpec([Color(0xFF5E35B1), Color(0xFF1C1040)],
      Color(0xFFD1C4FF), 'RLY', Icons.sports_tennis,
      ['PWR', 'ACC', 'SPD', 'STA', 'RET', 'TAC']),
  'table tennis': _SportSpec([Color(0xFFD84315), Color(0xFF4A1405)],
      Color(0xFFFFCCBC), 'SPN', Icons.sports_tennis,
      ['SPN', 'SRV', 'RET', 'SPD', 'REF', 'TAC']),
};

/// Shield player card, themed per sport. Rating comes from the backend when
/// > 0 (0–5 scale, shown out of 100), otherwise derived from skill level.
class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.name,
    required this.sport,
    required this.level,
    this.rating = 0,
    this.large = false,
    this.imageUrl,
  });

  final String name;
  final String sport;
  final String level;
  final double rating;
  final bool large;
  final String? imageUrl;

  _SportSpec get _spec =>
      _sportSpecs[sport.trim().toLowerCase()] ?? _defaultSpec;

  int get _levelRating => switch (level.toLowerCase()) {
    'beginner' => 72,
    'intermediate' => 80,
    'advanced' => 88,
    _ => 94,
  };

  int get shownRating =>
      rating > 0 ? (rating * 20).round().clamp(40, 99) : _levelRating;

  int _stat(int seed, int spread) =>
      (shownRating - 10 + (sport.hashCode + seed * 31) % spread)
          .clamp(40, 99);

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final stats = spec.stats;
    final scale = large ? 1.55 : 1.0;

    return ClipPath(
      clipper: _ShieldClipper(),
      child: CustomPaint(
        foregroundPainter: _ShieldBorderPainter(spec.accent, 2.5 * scale),
        child: Container(
          width: 170 * scale,
          height: 235 * scale,
          padding: EdgeInsets.fromLTRB(
              13 * scale, 10 * scale, 13 * scale, 11 * scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: spec.colors,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // faint sport watermark
              Positioned(
                right: -14 * scale,
                bottom: 34 * scale,
                child: Icon(spec.icon,
                    size: 120 * scale,
                    color: Colors.white.withOpacity(0.07)),
              ),
              Column(
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
                                  color: spec.accent,
                                  fontSize: 25 * scale,
                                  fontWeight: FontWeight.w900)),
                          Text(spec.pos,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12 * scale)),
                          SizedBox(height: 3 * scale),
                          Icon(spec.icon,
                              color: spec.accent, size: 18 * scale),
                        ],
                      ),
                      const Spacer(),
                      PlayerAvatar(
                          name: name,
                          radius: 24 * scale,
                          imageUrl: imageUrl),
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
                  SizedBox(height: 3 * scale),
                  Center(
                    child: Container(
                      height: 2 * scale,
                      width: 36 * scale,
                      color: spec.accent,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Center(
                    child: Text('$sport · ${_cap(level)}',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 8.5 * scale)),
                  ),
                  SizedBox(height: 6 * scale),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          14 * scale, 0, 14 * scale, 34 * scale),
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

Path _shieldPath(Size size) {
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

class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _shieldPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ShieldBorderPainter extends CustomPainter {
  _ShieldBorderPainter(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _shieldPath(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _ShieldBorderPainter old) =>
      old.color != color || old.width != width;
}