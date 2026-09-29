import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppTab { discover, chats, play, community, profile }

/// The 5-tab bottom navigation: Discover, Chats, Play, Community, Profile.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.current,
    required this.onTap,
  });

  final AppTab current;
  final ValueChanged<AppTab> onTap;

  static const _items = <AppTab, (IconData, String)>{
    AppTab.discover: (Icons.explore_outlined, 'Discover'),
    AppTab.chats: (Icons.chat_bubble_outline, 'Chats'),
    AppTab.play: (Icons.play_circle_outline, 'Play'),
    AppTab.community: (Icons.groups_outlined, 'Community'),
    AppTab.profile: (Icons.person_outline, 'Profile'),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: AppTab.values.map((tab) {
              final selected = tab == current;
              final (icon, label) = _items[tab]!;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(tab),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected ? AppColors.primary : AppColors.textMuted,
                      ),
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
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}