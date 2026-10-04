import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final _mapController = MapController();

  LatLng? _position; // null until GPS fixes
  double _radiusKm = 5;
  bool _locating = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // 1. Is GPS on?
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      setState(() {
        _locating = false;
        _locationError = 'Location services are turned off.';
      });
      return;
    }

    // 2. Ask permission.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _locating = false;
        _locationError = 'Location permission denied.';
      });
      return;
    }

    // 3. Get current position.
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = LatLng(pos.latitude, pos.longitude);
        _locating = false;
      });
    } catch (_) {
      setState(() {
        _locating = false;
        _locationError = 'Could not get your position.';
      });
    }
  }

  void _onNext() => context.push(AppRoutes.availabilitySetup);
  void _onSkip() => context.push(AppRoutes.availabilitySetup);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Where do you play?'.toUpperCase(),
                style: AppTextStyles.headline(size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'We use your location to show players and sessions nearby. Your exact position stays private.',
                style: AppTextStyles.body(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Map card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 300,
                  color: AppColors.surface,
                  child: _locating
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  )
                      : _position == null
                      ? _LocationErrorState(
                    message: _locationError!,
                    onRetry: _initLocation,
                  )
                      : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _position!,
                      initialZoom: 13,
                      interactionOptions:
                      const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.trinimate',
                      ),
                      // Match radius ring
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: _position!,
                            radius: _radiusKm * 1000,
                            useRadiusInMeter: true,
                            color: AppColors.primary
                                .withOpacity(0.12),
                            borderColor: AppColors.primary,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      // You are here
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _position!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white,
                                    width: 3),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_position != null) ...[
                Text('MATCH RADIUS', style: AppTextStyles.label()),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final r in [2.0, 5.0, 10.0, 25.0]) ...[
                      if (r != 2.0) const SizedBox(width: 10),
                      Expanded(
                        child: _RadiusPill(
                          label: '${r.toStringAsFixed(0)} km',
                          selected: _radiusKm == r,
                          onTap: () => setState(() => _radiusKm = r),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _onSkip,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: const BorderSide(color: AppColors.divider),
                          shape: const StadiumBorder(),
                        ),
                        child: Text('SKIP',
                            style: AppTextStyles.button(color: AppColors.text)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        child: Text('NEXT',
                            style: AppTextStyles.button(color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationErrorState extends StatelessWidget {
  const _LocationErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined,
                color: AppColors.textMuted, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'TAP TO RETRY',
                style: AppTextStyles.label(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => Geolocator.openAppSettings(),
              child: Text(
                'OPEN SETTINGS',
                style: AppTextStyles.label(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadiusPill extends StatelessWidget {
  const _RadiusPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.button(
            size: 13,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}