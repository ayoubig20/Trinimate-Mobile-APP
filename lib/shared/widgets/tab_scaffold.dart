import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'bottom_nav_bar.dart';

/// Adds the bottom nav bar to the 5 main tabs and switches tabs via go_router.
class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key, required this.current, required this.child});

  final AppTab current;
  final Widget child;

  void _onTab(BuildContext context, AppTab tab) {
    final route = switch (tab) {
      AppTab.discover => AppRoutes.discover,
      AppTab.chats => AppRoutes.chats,
      AppTab.play => AppRoutes.createSession,
      AppTab.community => AppRoutes.community,
      AppTab.profile => AppRoutes.profile,
    };
    if (tab != current) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavBar(
        current: current,
        onTap: (tab) => _onTab(context, tab),
      ),
    );
  }
}