import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/event_card.dart';
import '../../../../shared/widgets/tab_scaffold.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      current: AppTab.community,
      child: Stack(
        children: [
          ListView(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text('COMMUNITY', style: AppTextStyles.headline(size: 30)),
              const SizedBox(height: 6),
              Text('Open games and events near you',
                  style: AppTextStyles.body(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              for (final e in MockData.events) ...[
                EventCard(
                  day: e.day,
                  month: e.month,
                  title: e.title,
                  place: e.place,
                  time: e.time,
                  onTap: () =>
                      context.push('${AppRoutes.sessionDetail}/s1'),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 80),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.createSession),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}