import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Initials in a colored circle. Color is deterministic per player name.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({super.key, required this.name, this.radius = 22});

  final String name;
  final double radius;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.take(2).string.toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  Color get color =>
      AppColors.avatarPalette[name.hashCode.abs() % AppColors.avatarPalette.length];

  @override
  Widget build(BuildContext context) {
    final textColor =
    color == AppColors.secondary || color == const Color(0xFFD4EE2C)
        ? Colors.black
        : Colors.white;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.62,
        ),
      ),
    );
  }
}