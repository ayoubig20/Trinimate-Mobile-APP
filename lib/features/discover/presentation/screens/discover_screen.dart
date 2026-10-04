import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_tile.dart';
import '../../../../shared/widgets/tab_scaffold.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _filter = 'All';

  static const _center = LatLng(30.4278, -9.5981);
  static const _pinOffsets = [
    LatLng(0.006, 0.004), LatLng(-0.004, 0.009), LatLng(0.009, -0.006),
    LatLng(-0.008, -0.009), LatLng(0.002, 0.013), LatLng(-0.012, 0.003),
  ];

  @override
  Widget build(BuildContext context) {
    final players = _filter == 'All'
        ? MockData.players
        : MockData.players.where((p) => p.sport == _filter).toList();

    return TabScaffold(
      current: AppTab.discover,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DISCOVER', style: AppTextStyles.headline(size: 30)),
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
                      for (var i = 0;
                      i < MockData.players.length && i < _pinOffsets.length;
                      i++)
                        Marker(
                          point: LatLng(
                            _center.latitude + _pinOffsets[i].latitude,
                            _center.longitude + _pinOffsets[i].longitude,
                          ),
                          width: 34,
                          height: 34,
                          child: GestureDetector(
                            onTap: () => context.push(
                                '${AppRoutes.playerProfile}/${MockData.players[i].id}'),
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
          Text('NEARBY PLAYERS', style: AppTextStyles.headline(size: 20)),
          const SizedBox(height: 12),
          if (players.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('No players found for this sport nearby.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(color: AppColors.textMuted)),
            )
          else
            for (final p in players) ...[
              PlayerTile(
                name: p.name,
                subtitle:
                '${p.sport} · ${p.level} · ${p.distanceKm} km away',
                onTap: () =>
                    context.push('${AppRoutes.playerProfile}/${p.id}'),
                onPing: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                      Text('Ping sent to ${p.name.split(' ').first}!')),
                ),
              ),
              const SizedBox(height: 10),
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