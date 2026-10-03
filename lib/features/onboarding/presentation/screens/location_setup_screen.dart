import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final _cityController = TextEditingController();
  double _radiusKm = 5;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _onNext() => context.push(AppRoutes.availabilitySetup);
  void _onSkip() => context.push(AppRoutes.availabilitySetup);

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
                'Where do you play?'.toUpperCase(),
                style: AppTextStyles.headline(size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'We will show players and sessions within your match radius.',
                style: AppTextStyles.body(color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              AppTextField(
                label: 'City',
                hint: 'e.g. Agadir',
                controller: _cityController,
                prefixIcon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 24),
              Text('MATCH RADIUS', style: AppTextStyles.label()),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final r in [2.0, 5.0, 10.0, 25.0]) ...[
                    if (r != 2.0) const SizedBox(width: 10),
                    Expanded(
                      child: _RadiusPill(
                        label: '${r.toStringAsFixed(0)} km',
                        selected: _radiusKm == r,
                        onTap: () => setState(() => _radiusKm = r),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              _NavButtons(onSkip: _onSkip, onNext: _onNext),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadiusPill extends StatelessWidget {
  const _RadiusPill({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.button(
            size: 13,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Shared Skip/Next bottom buttons for the onboarding steps.
class _NavButtons extends StatelessWidget {
  const _NavButtons({required this.onSkip, required this.onNext});

  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onSkip,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.divider),
                shape: const StadiumBorder(),
              ),
              child:
              Text('SKIP', style: AppTextStyles.button(color: AppColors.text)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onNext,
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
    );
  }
}