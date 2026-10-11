import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PickedLocation {
  final double lat, lng;
  final String placeName;
  PickedLocation(this.lat, this.lng, this.placeName);
}

/// Full-screen map: tap to drop a pin, confirm → reverse-geocoded place name.
Future<PickedLocation?> pickLocation(BuildContext context,
    {double? initialLat, double? initialLng}) async {
  LatLng? chosen = (initialLat != null && initialLng != null)
      ? LatLng(initialLat, initialLng)
      : null;

  final result = await showModalBottomSheet<PickedLocation>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.screenBackground,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.85,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text('TAP THE COURT LOCATION',
                style: AppTextStyles.headline(size: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: chosen ?? const LatLng(30.4278, -9.5981),
                  initialZoom: 14,
                  onTap: (tapPos, point) => setS(() => chosen = point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.trinimate',
                  ),
                  if (chosen != null)
                    MarkerLayer(markers: [
                      Marker(
                        point: chosen!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin,
                            color: AppColors.primary, size: 40),
                      ),
                    ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: const BorderSide(color: AppColors.divider),
                        shape: const StadiumBorder(),
                      ),
                      child: Text('CANCEL',
                          style: AppTextStyles.button(
                              color: AppColors.text)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: chosen == null
                          ? null
                          : () async {
                        String name = '';
                        try {
                          final res = await Dio().get(
                            'https://nominatim.openstreetmap.org/reverse',
                            queryParameters: {
                              'format': 'jsonv2',
                              'lat': chosen!.latitude,
                              'lon': chosen!.longitude,
                            },
                            options: Options(headers: {
                              'User-Agent': 'trinimate-app'
                            }),
                          );
                          final d = res.data['display_name']
                          as String? ??
                              '';
                          name = d.split(',').take(3).join(',');
                        } catch (_) {}
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx, PickedLocation(
                            chosen!.latitude,
                            chosen!.longitude,
                            name));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                      ),
                      child: Text('CONFIRM',
                          style: AppTextStyles.button()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result;
}