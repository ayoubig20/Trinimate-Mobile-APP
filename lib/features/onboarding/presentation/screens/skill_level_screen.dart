import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum _SportCategory { solo, duo, team }
enum _Level { beginner, intermediate, advanced }

class SkillLevelScreen extends StatefulWidget {
  const SkillLevelScreen({super.key, required this.selectedSports});

  final List<String> selectedSports;

  @override
  State<SkillLevelScreen> createState() => _SkillLevelScreenState();
}

class _SkillLevelScreenState extends State<SkillLevelScreen> {
  _SportCategory _category = _SportCategory.solo;

  /// sport -> chosen level
  final Map<String, _Level> _levels = {};

  static const _sports = <_SportCategory, List<String>>{
    _SportCategory.solo: [
      'Running', 'Yoga', 'Fitness', 'Swimming', 'Boxing',
      'Cycling', 'Pilates', 'Equitation', 'Hiking',
    ],
    _SportCategory.duo: [
      'Tennis', 'Padel', 'Badminton', 'Squash', 'Table Tennis',
      'Judo', 'Fencing', 'Golf',
    ],
    _SportCategory.team: [
      'Football', 'Basketball', 'Volleyball', 'Handball',
      'Rugby', 'Cricket', 'Baseball',
    ],
  };

  List<String> get _visibleSports => _sports[_category]!
      .where((s) => widget.selectedSports.contains(s))
      .toList();

  void _onDone() => context.push(AppRoutes.locationSetup);

  @override
  Widget build(BuildContext context) {
    final visible = _visibleSports;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Skill level'.toUpperCase(),
                style: AppTextStyles.headline(size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the level that best represents your experience in your favorite sports.',
                style: AppTextStyles.body(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              // Solo / Duo / Team selector
              Row(
                children: [
                  for (final cat in _SportCategory.values) ...[
                    if (cat != _SportCategory.solo)
                      const SizedBox(width: 10),
                    Expanded(
                      child: _CategoryButton(
                        category: cat,
                        active: _category == cat,
                        onTap: () => setState(() => _category = cat),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Levels card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: visible.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No selected sports in this category',
                    textAlign: TextAlign.center,
                    style:
                    AppTextStyles.body(color: AppColors.textMuted),
                  ),
                )
                    : Column(
                  children: [
                    for (int i = 0; i < visible.length; i++) ...[
                      if (i > 0) const SizedBox(height: 18),
                      _SkillRow(
                        sport: visible[i],
                        level: _levels[visible[i]],
                        onChanged: (level) => setState(
                              () => _levels[visible[i]] = level,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Skip + Next
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _onDone,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: const BorderSide(color: AppColors.divider),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'SKIP',
                          style: AppTextStyles.button(color: AppColors.text),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _onDone,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'NEXT',
                          style: AppTextStyles.button(color: Colors.black),
                        ),
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

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.active,
    required this.onTap,
  });

  final _SportCategory category;
  final bool active;
  final VoidCallback onTap;

  (IconData, String) get _data => switch (category) {
    _SportCategory.solo => (Icons.person_outline, 'Solo\nSports'),
    _SportCategory.duo => (Icons.people_outline, 'Duo\nSports'),
    _SportCategory.team => (Icons.groups_outlined, 'Team\nSports'),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _data;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20, color: active ? Colors.white : AppColors.textMuted),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTextStyles.button(
                size: 11,
                color: active ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.sport,
    required this.level,
    required this.onChanged,
  });

  final String sport;
  final _Level? level;
  final ValueChanged<_Level> onChanged;

  static const _labels = {
    _Level.beginner: 'Beginner',
    _Level.intermediate: 'Intermediate',
    _Level.advanced: 'Advanced',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sport, style: AppTextStyles.bodyMedium(size: 15)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final l in _Level.values) ...[
              if (l != _Level.beginner) const SizedBox(width: 18),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(l),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: level == l
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: level == l
                                ? AppColors.primary
                                : AppColors.textMuted,
                            width: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _labels[l]!,
                          style: AppTextStyles.body(
                            size: 12,
                            color: level == l
                                ? AppColors.text
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}