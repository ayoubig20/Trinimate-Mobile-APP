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
import '../discover_controller.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _filter = 'All';

  static const _center = LatLng(30.4278, -9.5981);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider); // ← translations
    final playersAsync = ref.watch(nearbyPlayersProvider(_filter));
    final players = playersAsync.value ?? [];


    return TabScaffold(
      current: AppTab.discover,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.discover, style: AppTextStyles.headline(size: 30)),
              GestureDetector(
                onTap: () => context.push(AppRoutes.notifications),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppColors.text, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Map (mock pins — cosmetic)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 170,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: _center,
                  initialZoom: 12.5,
                  interactionOptions:
                  InteractionOptions(flags: InteractiveFlag.all),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.trinimate',
                  ),
              MarkerLayer(
                markers: [
                  for (final p in players)
                    if (p['latitude'] != null &&
                        p['longitude'] != null)
                      Marker(
                        point: LatLng(
                          (p['latitude'] as num).toDouble(),
                          (p['longitude'] as num).toDouble(),
                        ),
                        width: 34,
                        height: 34,
                        child: GestureDetector(
                          onTap: () => context.push(
                              '${AppRoutes.playerProfile}/${p['id']}'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                ],
              ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.place_outlined,
                  color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text('Agadir · 2.5 km radius',
                  style: AppTextStyles.body(size: 12,
                      color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),

          // Filter chips
          SizedBox(
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
          const SizedBox(height: 16),

          Text(s.nearbyPlayers,
              style: AppTextStyles.headline(size: 20)),
          const SizedBox(height: 12),

          playersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text('Could not load players.',
                      textAlign: TextAlign.center,
                      style:
                      AppTextStyles.body(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        ref.invalidate(nearbyPlayersProvider(_filter)),
                    child: Text('TAP TO RETRY',
                        style: AppTextStyles.label(
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            data: (players) => players.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(s.noPlayersNearby,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                      color: AppColors.textMuted)),
            )
                : Column(
              children: [
                for (final p in players)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PlayerTile(
                      name: p['name'] as String? ?? 'Player',
                      pinged: ref.watch(pingedIdsProvider)
                          .contains(p['id'] as int),
                      subtitle: () {
                        final sports =
                            (p['sports'] as List<dynamic>?) ?? [];
                        final sportName = sports.isNotEmpty
                            ? sports[0]['sport'] as String? ?? ''
                            : '';
                        final dist = p['distanceKm'];
                        final distText = dist is num
                            ? '${dist.toStringAsFixed(1)} km away'
                            : 'nearby';
                        return sportName.isEmpty
                            ? distText
                            : '$sportName · $distText';
                      }(),
                      onTap: () => context.push(
                          '${AppRoutes.playerProfile}/${p['id']}'),
                        onPing: () async {
                          try {
                            final res = await ApiClient.instance.post(
                                '/players/${p['id']}/ping',
                                data: {'message': 'Want to play?'});
                            final pinged =
                                (res.data['pinged'] as bool?) ?? true;
                            final set = ref
                                .read(pingedIdsProvider.notifier);
                            final current =
                            Set<int>.from(ref.read(pingedIdsProvider));
                            if (pinged) {
                              current.add(p['id'] as int);
                            } else {
                              current.remove(p['id'] as int);
                            }
                            set.state = current;
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(pinged
                                      ? 'Ping sent!'
                                      : 'Ping removed')),
                            );
                          } on DioException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(e.response?.data?['error']
                              as String? ??
                                  'Could not send ping'),
                            ));
                          }
                        },
                    ),
                  ),
              ],
            ),
          ),
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
          color: active ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
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