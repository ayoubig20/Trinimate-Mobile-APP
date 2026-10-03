import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum _SportCategory { solo, duo, team }

class OnboardingSportsScreen extends StatefulWidget {
  const OnboardingSportsScreen({super.key});

  @override
  State<OnboardingSportsScreen> createState() =>
      _OnboardingSportsScreenState();
}

class _OnboardingSportsScreenState extends State<OnboardingSportsScreen> {
  _SportCategory _category = _SportCategory.solo;

  /// Key = sport name. Selection persists when switching categories.
  final Set<String> _selected = {};

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

  void _toggle(String sport) {
    setState(() {
      if (_selected.contains(sport)) {
        _selected.remove(sport);
      } else {
        _selected.add(sport);
      }
    });
  }

  void _onNext() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one sport to continue')),
      );
      return;
    }
    _showSkillDialog();
  }

  void _showSkillDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0xB3000000), // scrim: black at 70% (rectangle_1)
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, anim1, anim2) {
        return Material(
            type: MaterialType.transparency,
            child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Would you like to set skill\nlevels for each sport?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(size: 17),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                context.push(AppRoutes.locationSetup);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.text,
                                side: const BorderSide(
                                    color: AppColors.primary),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                'No',
                                style: AppTextStyles.button(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                context.push(
                                  AppRoutes.skillLevel,
                                  extra: _selected.toList(),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                'Yes',
                                style:
                                AppTextStyles.button(color: Colors.black),
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
          ),
            ),
        );

      },
    );
  }

  void _onSkip() => context.go(AppRoutes.discover);

  @override
  Widget build(BuildContext context) {
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
                'Favorite sports'.toUpperCase(),
                style: AppTextStyles.headline(size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your favorite solo, duo, or team sports',
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

              // Chips card
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        for (final sport in _sports[_category]!)
                          _SportChip(
                            label: sport,
                            selected: _selected.contains(sport),
                            onTap: () => _toggle(sport),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_selected.length} Sports Selected',
                        style: AppTextStyles.label(
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
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
                        onPressed: _onSkip,
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
                        onPressed: _onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
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
            Icon(
              icon,
              size: 20,
              color: active ? Colors.white : AppColors.textMuted,
            ),
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

/// Small pill chip: white text, orange when selected (per the design).
class _SportChip extends StatelessWidget {
  const _SportChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium(
            size: 13,
            color: selected ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}