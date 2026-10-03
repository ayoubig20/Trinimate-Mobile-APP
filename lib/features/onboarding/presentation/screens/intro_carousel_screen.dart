import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class IntroCarouselScreen extends StatefulWidget {
  const IntroCarouselScreen({super.key});

  @override
  State<IntroCarouselScreen> createState() => _IntroCarouselScreenState();
}

class _IntroCarouselScreenState extends State<IntroCarouselScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  /// Add more pages here as you design them — dots update automatically.
  static const _pages = [
    _IntroPageData(
      image: 'assets/images/intro_athletes.png',
      title: 'Discover nearby players.',
      subtitle: 'Meet players who share your sport.',
    ),
    _IntroPageData(
      image: 'assets/images/intro_match.png',
      title: 'Match and chat instantly.',
      subtitle: 'Find your perfect partner and play today.',
    ),
    _IntroPageData(
      image: 'assets/images/intro_events.png',
      title: 'Join events and challenges.',
      subtitle: 'Join local games and stay active together.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  void _onSkip() => context.go(AppRoutes.onboarding);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20,80),
          child: Column(
            children: [
              // Logo + tagline
              Center(
                child: Image.asset(
                  'assets/images/trinimate_logo.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),

              // Carousel
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) => _IntroPage(data: _pages[i]),
                ),
              ),

              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface2,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

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

class _IntroPageData {
  const _IntroPageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.data});

  final _IntroPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tilted dashed frame with the athletes artwork
        Expanded(
          flex: 5,
          child: SizedBox(
            width: double.infinity,
            child: Image.asset(
              data.image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          data.title.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTextStyles.headline(size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.body(color: AppColors.textMuted),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

/// White dashed rounded border, like the Figma stroke around the artwork.
class _DashedFrame extends StatelessWidget {
  const _DashedFrame({
    required this.child,
    this.radius = 24,
    this.color = Colors.white,
    this.strokeWidth = 1.6,
    this.dash = 9,
    this.gap = 7,
  });

  final Widget child;
  final double radius;
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dash: dash,
        gap: gap,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    // Draw the path as dashes.
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        dashPath.addPath(
          metric.extractPath(distance, next),
          Offset.zero,
        );
        distance = next + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth ||
          oldDelegate.radius != radius ||
          oldDelegate.dash != dash ||
          oldDelegate.gap != gap;
}