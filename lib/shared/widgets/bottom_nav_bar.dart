import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppTab { discover, chats, activities, profile }

/// SportMatcher-style bar: 4 tabs + a RAISED center ＋ button (create).
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.current,
    required this.onTap,
    required this.onCreate,
  });

  final AppTab current;
  final ValueChanged<AppTab> onTap;
  final VoidCallback onCreate;

  static const _items = <AppTab, (IconData, String)>{
    AppTab.discover: (Icons.explore_outlined, 'Explorer'),
    AppTab.chats: (Icons.chat_bubble_outline, 'Chats'),
    AppTab.activities: (Icons.event_available_outlined, 'Activités'),
    AppTab.profile: (Icons.person_outline, 'Profil'),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final tab in [AppTab.discover, AppTab.chats]) ...[
              Expanded(child: _tabItem(tab)),
            ],
            // center slot for the raised ＋
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCreate,
                child: const SizedBox(height: 64),
              ),
            ),
            for (final tab in [AppTab.activities, AppTab.profile]) ...[
              Expanded(child: _tabItem(tab)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabItem(AppTab tab) {
    final selected = tab == current;
    final (icon, label) = _items[tab]!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(tab),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.textMuted),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label(
              size: 9,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrap [child] (the Scaffold using [BottomNavBar]) with the raised center ＋.
/// Place ABOVE the scaffold body, overlapping the nav bar.
class CreateFabOverlay extends StatelessWidget {
  const CreateFabOverlay({super.key, required this.onCreate, required this.child});

  final VoidCallback onCreate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 40, // hovers above the 64px bar
          child: Center(
            child: GestureDetector(
              onTap: onCreate,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}