import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AvailabilitySetupScreen extends StatefulWidget {
  const AvailabilitySetupScreen({super.key});

  @override
  State<AvailabilitySetupScreen> createState() =>
      _AvailabilitySetupScreenState();
}

class _AvailabilitySetupScreenState extends State<AvailabilitySetupScreen> {
  final Set<String> _days = {};
  final Set<String> _slots = {};

  static const _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _allSlots = ['Morning', 'Afternoon', 'Evening'];

  void _onNext() => context.push(AppRoutes.photoSetup);
  void _onSkip() => context.push(AppRoutes.photoSetup);

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
                'When are you free?'.toUpperCase(),
                style: AppTextStyles.headline(size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick the days and times you usually play — we match you with players on the same schedule.',
                style: AppTextStyles.body(color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
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
                    Text('DAYS', style: AppTextStyles.label()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        for (final d in _allDays)
                          _ToggleChip(
                            label: d,
                            selected: _days.contains(d),
                            onTap: () => setState(() => _days.contains(d)
                                ? _days.remove(d)
                                : _days.add(d)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text('TIME OF DAY', style: AppTextStyles.label()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        for (final s in _allSlots)
                          _ToggleChip(
                            label: s,
                            selected: _slots.contains(s),
                            onTap: () => setState(() => _slots.contains(s)
                                ? _slots.remove(s)
                                : _slots.add(s)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
                        child: Text('SKIP',
                            style: AppTextStyles.button(color: AppColors.text)),
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
                          shape: const StadiumBorder(),
                        ),
                        child: Text('NEXT',
                            style: AppTextStyles.button(color: Colors.black)),
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

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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