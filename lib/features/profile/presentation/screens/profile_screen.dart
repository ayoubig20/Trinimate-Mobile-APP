import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/tab_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  String _language = 'EN';

  static const _skillLevels = [
    ('Padel', 0.7),
    ('Tennis', 0.4),
    ('Running', 0.85),
  ];

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            for (final lang in ['EN', 'FR', '中文'])
              ListTile(
                title: Text(lang,
                    style: AppTextStyles.bodyMedium()),
                trailing: _language == lang
                    ? const Icon(Icons.check,
                    color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _language = lang);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      current: AppTab.profile,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('PROFILE', style: AppTextStyles.headline(size: 30)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const PlayerAvatar(name: 'Ayoub', radius: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ayoub',
                          style: AppTextStyles.bodyMedium(size: 17)),
                      const SizedBox(height: 2),
                      Text('Agadir · Intermediate',
                          style: AppTextStyles.body(
                              size: 12,
                              color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Edit profile — coming in Stage 6')),
                            ),
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
                for (var i = 0; i < _skillLevels.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_skillLevels[i].$1,
                          style: AppTextStyles.bodyMedium(size: 14)),
                      Text(
                          '${(_skillLevels[i].$2 * 100).round()}%',
                          style: AppTextStyles.body(
                              size: 12,
                              color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _skillLevels[i].$2,
                      minHeight: 7,
                      backgroundColor: AppColors.surface2,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.social_distance_outlined,
                  title: 'Match radius',
                  value: '5 km',
                  onTap: () {},
                ),
                const Divider(color: AppColors.divider, height: 1),
                _SettingsTile(
                  icon: Icons.event_outlined,
                  title: 'Available days',
                  value: 'Mon–Fri',
                  onTap: () {},
                ),
                const Divider(color: AppColors.divider, height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Notifications',
                            style:
                            AppTextStyles.bodyMedium(size: 14)),
                      ),
                      Switch(
                        value: _notificationsOn,
                        onChanged: (v) =>
                            setState(() => _notificationsOn = v),
                        activeColor: AppColors.primary,
                        activeTrackColor:
                        AppColors.primary.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  value: _language,
                  onTap: _showLanguagePicker,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go(AppRoutes.login),
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
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textMuted, size: 20),
      title: Text(title, style: AppTextStyles.bodyMedium(size: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTextStyles.body(
                  size: 13, color: AppColors.textMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}