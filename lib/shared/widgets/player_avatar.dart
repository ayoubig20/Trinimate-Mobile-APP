import 'package:flutter/material.dart';

import '../../core/network/api_config.dart';
import '../../core/theme/app_colors.dart';

/// Profile picture if [imageUrl] is set, otherwise a default avatar.
/// The ring color is deterministic per player name.
/// Pass showInitials: true to use initials instead of the person icon.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.imageUrl,
    this.showInitials = false,
  });

  final String name;
  final double radius;
  final String? imageUrl;
  final bool showInitials;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).string.toUpperCase();
    }
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  Color get color =>
      AppColors.avatarPalette[name.hashCode.abs() % AppColors.avatarPalette.length];

  /// Relative paths from the server (/uploads/x.jpg) become full URLs.
  String _resolve(String url) => url.startsWith('http')
      ? url
      : '${ApiConfig.baseUrl.replaceFirst('/api/v1', '')}$url';

  Widget _fallback() => Center(
    child: showInitials
        ? Text(
      initials,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: radius * 0.62,
      ),
    )
        : Icon(Icons.person, size: radius * 1.15, color: color),
  );

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final hasImage = url != null && url.isNotEmpty;
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface2,
        border: Border.all(color: color, width: 1.5),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
          _resolve(url),
          width: size,
          height: size,
          fit: BoxFit.cover,
          // while loading or if the link is broken, show the default
          loadingBuilder: (_, child, progress) =>
          progress == null ? child : _fallback(),
          errorBuilder: (_, error, __) {
          debugPrint('Avatar failed to load: ${_resolve(url)} -> $error');
          return _fallback();
          },
        )
            : _fallback(),
      ),
    );
  }
}