import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/player_tile.dart';
import '../../../../shared/widgets/tab_scaffold.dart';
import '../../../community/presentation/community_controller.dart';
import '../../../notifications/presentation/notifications_controller.dart';
import '../../../sessions/presentation/sessions_controller.dart';
import '../discover_controller.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// SportMatcher-style icon + tint per sport.
(IconData, Color) _sportStyle(String sport) => switch (sport) {
  'Football' => (Icons.sports_soccer, const Color(0xFF2E9E5B)),
  'Basketball' => (Icons.sports_basketball, const Color(0xFFEF8633)),
  'Tennis' => (Icons.sports_tennis, const Color(0xFF7CB342)),
  'Padel' => (Icons.sports_tennis, const Color(0xFF26A0B8)),
  'Running' => (Icons.directions_run, const Color(0xFF43A047)),
  'Cycling' => (Icons.directions_bike, const Color(0xFFEF6C00)),
  'Swimming' => (Icons.pool, const Color(0xFF1E88E5)),
  'Boxing' => (Icons.sports_mma, const Color(0xFFE53935)),
  'Volleyball' => (Icons.sports_volleyball, const Color(0xFF8E6BC0)),
  'Yoga' => (Icons.self_improvement, const Color(0xFFAB6BC0)),
  _ => (Icons.emoji_events, AppColors.primary),
};

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _filter = 'All';
  String _search = '';
  bool _mapMode = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final playersAsync = ref.watch(nearbyPlayersProvider(_filter));
    final sessionsAsync = ref.watch(sessionsListProvider);

    final players = (playersAsync.value ?? []).where((p) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      final sports = (p['sports'] as List?) ?? [];
      return (p['name'] as String? ?? '').toLowerCase().contains(q) ||
          sports.any((sp) =>
              (sp['sport'] as String? ?? '').toLowerCase().contains(q));
    }).toList();

    final sessions = (sessionsAsync.value ?? []).where((se) {
      final sportOk =
          _filter == 'All' || se['sport'] == _filter;
      if (!sportOk) return false;
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return (se['title'] as String? ?? '').toLowerCase().contains(q) ||
          (se['place'] as String? ?? '').toLowerCase().contains(q);
    }).toList();

    return TabScaffold(
      current: AppTab.discover,
      child: Column(
        children: [
          // ---------- Header ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.discover, style: AppTextStyles.headline(size: 30)),
                GestureDetector(
                  onTap: () async {
                    await context.push(AppRoutes.notifications);
                    ref.invalidate(unreadCountProvider);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_outlined,
                            color: AppColors.text, size: 20),
                        ref.watch(unreadCountProvider).when(
                          data: (count) => count > 0
                              ? Positioned(
                            right: 3,
                            top: 3,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              constraints: const BoxConstraints(
                                  minWidth: 15, minHeight: 15),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text('$count',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight:
                                      FontWeight.bold)),
                            ),
                          )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Search ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.trim()),
                style: AppTextStyles.bodyMedium(size: 14),
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---------- List / Carte toggle + sport chips ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _Segmented(
                  labels: [s.listMode, s.mapMode],
                  selected: _mapMode ? 1 : 0,
                  onChanged: (i) =>
                      setState(() => _mapMode = i == 1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final f in ['All', ...MockData.sports])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: f,
                              active: _filter == f,
                              onTap: () => setState(() => _filter = f),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Content ----------
          Expanded(
            child: _mapMode
                ? _ExplorerMap(players: players, sessions: sessions)
                : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // ACTIVITIES with progress cards
                Text(s.activitiesNearYou,
                    style: AppTextStyles.headline(size: 20)),
                const SizedBox(height: 12),
                sessionsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                  ),
                  error: (e, _) => GestureDetector(
                    onTap: () => ref.invalidate(sessionsListProvider),
                    child: Text('Could not load. TAP TO RETRY',
                        style: AppTextStyles.body(
                            color: AppColors.textMuted)),
                  ),
                  data: (_) => sessions.isEmpty
                      ? Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12),
                    child: Text(s.noSessions,
                        style: AppTextStyles.body(
                            color: AppColors.textMuted)),
                  )
                      : Column(
                    children: [
                      for (final se in sessions)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 10),
                          child: _ActivityCard(session: se),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // PLAYERS
                Text(s.playersNearYou,
                    style: AppTextStyles.headline(size: 20)),
                const SizedBox(height: 12),
                playersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                  ),
                  error: (e, _) => GestureDetector(
                    onTap: () => ref.invalidate(
                        nearbyPlayersProvider(_filter)),
                    child: Text('Could not load. TAP TO RETRY',
                        style: AppTextStyles.body(
                            color: AppColors.textMuted)),
                  ),
                  data: (_) => players.isEmpty
                      ? Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12),
                    child: Text(s.noPlayersNearby,
                        style: AppTextStyles.body(
                            color: AppColors.textMuted)),
                  )
                      : Column(
                    children: [
                      for (final p in players)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 10),
                          child: PlayerTile(
                            name: p['name'] as String? ??
                                'Player',
                            pinged: ref
                                .watch(pingedIdsProvider)
                                .contains(p['id'] as int),
                            subtitle: () {
                              final sports =
                                  (p['sports']
                                  as List<dynamic>?) ??
                                      [];
                              final sportName =
                              sports.isNotEmpty
                                  ? sports[0]['sport']
                              as String? ??
                                  ''
                                  : '';
                              final dist = p['distanceKm'];
                              final distText = dist is num
                                  ? '${dist.toStringAsFixed(1)} km'
                                  : 'nearby';
                              return sportName.isEmpty
                                  ? distText
                                  : '$sportName · $distText';
                            }(),
                            onTap: () => context.push(
                                '${AppRoutes.playerProfile}/${p['id']}'),
                            onPing: () async {
                              try {
                                final res = await ApiClient
                                    .instance
                                    .post(
                                    '/players/${p['id']}/ping',
                                    data: {
                                      'message':
                                      'Want to play?'
                                    });
                                final pinged = (res.data[
                                'pinged'] as bool?) ??
                                    true;
                                final current = Set<int>.from(
                                    ref.read(pingedIdsProvider));
                                if (pinged) {
                                  current.add(p['id'] as int);
                                } else {
                                  current.remove(p['id'] as int);
                                }
                                ref
                                    .read(pingedIdsProvider
                                    .notifier)
                                    .state =
                                    current;
                              } on DioException catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(e.response?.data?[
                                  'error'] as String? ??
                                      'Could not send ping'),
                                ));
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White card: tinted sport icon, title, place/date rows, fee,
/// and the SportMatcher-style spots-left progress bar.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.session});

  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context) {
    final dt =
    DateTime.fromMillisecondsSinceEpoch(session['dateTime'] as int);
    final needed = session['playersNeeded'] as int? ?? 0;
    final joined = session['playersJoined'] as int? ?? 0;
    final left = needed - joined;
    final (icon, tint) = _sportStyle(session['sport'] as String? ?? '');
    final price = session['price'] as num?;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context
            .push('${AppRoutes.sessionDetail}/${session['id']}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: tint.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: tint, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session['title'] as String? ?? '',
                            style:
                            AppTextStyles.bodyMedium(size: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        _miniRow(Icons.place_outlined,
                            session['place'] as String? ?? ''),
                        const SizedBox(height: 2),
                        _miniRow(
                          Icons.calendar_today_outlined,
                          '${_two(dt.day)}/${_two(dt.month)} · ${_two(dt.hour)}:${_two(dt.minute)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (price != null)
                    Text('${price.round()} MAD · split $needed',
                        style: AppTextStyles.bodyMedium(
                            size: 12,
                            color: AppColors.primary)),
                  const Spacer(),
                  Text(
                    left > 0 ? '$left left / $needed' : 'FULL',
                    style: AppTextStyles.label(
                        size: 11,
                        color: left > 0
                            ? AppColors.primary
                            : const Color(0xFF2E9E5B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: needed == 0 ? 0 : joined / needed,
                  minHeight: 6,
                  backgroundColor: AppColors.surface2,
                  valueColor: AlwaysStoppedAnimation(
                    left > 0 ? AppColors.primary : const Color(0xFF2E9E5B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text,
              style: AppTextStyles.body(
                  size: 12, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// Map mode: player pins + session location pins.
class _ExplorerMap extends StatelessWidget {
  const _ExplorerMap({required this.players, required this.sessions});

  final List<dynamic> players;
  final List<dynamic> sessions;

  static const _center = LatLng(30.4278, -9.5981);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: _center,
          initialZoom: 12.5,
          interactionOptions:
          InteractionOptions(flags: InteractiveFlag.all),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.trinimate',
          ),
          MarkerLayer(
            markers: [
              for (final se in sessions)
                if (se['latitude'] != null && se['longitude'] != null)
                  Marker(
                    point: LatLng((se['latitude'] as num).toDouble(),
                        (se['longitude'] as num).toDouble()),
                    width: 36,
                    height: 42,
                    alignment: const Alignment(0, 1),
                    child: GestureDetector(
                      onTap: () => context.push(
                          '${AppRoutes.sessionDetail}/${se['id']}'),
                      child: const Icon(Icons.location_pin,
                          color: AppColors.primary, size: 36),
                    ),
                  ),
              for (final p in players)
                if (p['latitude'] != null && p['longitude'] != null)
                  Marker(
                    point: LatLng((p['latitude'] as num).toDouble(),
                        (p['longitude'] as num).toDouble()),
                    width: 40,
                    height: 48,
                    alignment: const Alignment(0, 1),
                    child: GestureDetector(
                      onTap: () => context.push(
                          '${AppRoutes.playerProfile}/${p['id']}'),
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _initials(p['name'] as String? ?? '?'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11),
                              ),
                            ),
                          ),
                          CustomPaint(
                              size: const Size(10, 8),
                              painter: _PinPainter()),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SportMatcher-style segmented control (List / Carte).
class _Segmented extends StatelessWidget {
  const _Segmented(
      {required this.labels,
        required this.selected,
        required this.onChanged});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected == i
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  labels[i],
                  style: AppTextStyles.button(
                    size: 12,
                    color: selected == i
                        ? Colors.white
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Center(
          child: Text(label.toUpperCase(),
              style: AppTextStyles.button(
                  size: 12,
                  color: active ? Colors.white : AppColors.textMuted)),
        ),
      ),
    );
  }
}