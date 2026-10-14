import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'bottom_nav_bar.dart';

/// Tab screens + bottom nav with the RAISED center ＋ (create session).
class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key, required this.current, required this.child});

  final AppTab current;
  final Widget child;

  void _onTab(BuildContext context, AppTab tab) {
    final route = switch (tab) {
      AppTab.discover => AppRoutes.discover,
      AppTab.chats => AppRoutes.chats,
      AppTab.activities => AppRoutes.activities,
      AppTab.profile => AppRoutes.profile,
    };
    if (tab != current) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: CreateFabOverlay(
        onCreate: () => context.push(AppRoutes.createSession),
        child: SafeArea(child: child),
      ),
      bottomNavigationBar: BottomNavBar(
        current: current,
        onTap: (tab) => _onTab(context, tab),
        onCreate: () => context.push(AppRoutes.createSession),
      ),
    );
  }
}