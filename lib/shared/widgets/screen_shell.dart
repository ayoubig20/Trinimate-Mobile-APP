import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Minimal compiling scaffold used by every route in Stage 1.
/// Stages 2–4 replace each usage with the full screen implementation.
class ScreenShell extends StatelessWidget {
  const ScreenShell({super.key, required this.title, this.child});

  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline(size: 34)),
                if (child != null) ...[
                  const SizedBox(height: 18),
                  child!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}