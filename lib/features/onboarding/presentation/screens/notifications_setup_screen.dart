import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationsSetupScreen extends StatefulWidget {
  const NotificationsSetupScreen({super.key});

  @override
  State<NotificationsSetupScreen> createState() =>
      _NotificationsSetupScreenState();
}

class _NotificationsSetupScreenState extends State<NotificationsSetupScreen> {
  bool _requesting = false;

  Future<void> _enableAndFinish() async {
    setState(() => _requesting = true);
    // Ask the OS for notification permission (Android 13+ / iOS).
    await Permission.notification.request();
    if (!mounted) return;
    setState(() => _requesting = false);
    context.go(AppRoutes.discover);
  }

  void _skip() => context.go(AppRoutes.discover);

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
                'Stay in the loop'.toUpperCase(),
                style: AppTextStyles.headline(size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'Get pinged when someone invites you, a match fills up, or a game starts near you.',
                style: AppTextStyles.body(color: AppColors.textMuted),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppColors.primary, size: 48),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _requesting ? null : _enableAndFinish,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    AppColors.primary.withOpacity(0.5),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    _requesting ? 'Opening settings…' : 'Enable notifications',
                    style: AppTextStyles.button(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: _skip,
                  child: Text(
                    'MAYBE LATER',
                    style: AppTextStyles.label(),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}