import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/players_repository.dart';

final playersRepositoryProvider =
Provider<PlayersRepository>((ref) => PlayersRepository());

/// ids the current user has already pinged (for the toggle button)
final pingedIdsProvider = StateProvider<Set<int>>((ref) => {});

/// Nearby players: centered on me, same city, excluding me.
final nearbyPlayersProvider =
FutureProvider.autoDispose.family<List<dynamic>, String>((ref, sportFilter) async {
  final meRes = await ApiClient.instance.get('/profile');
  final me = meRes.data as Map<String, dynamic>;
  final lat = (me['latitude'] as num?)?.toDouble() ?? 30.4278;
  final lng = (me['longitude'] as num?)?.toDouble() ?? -9.5981;
  final radius = (me['radiusKm'] as num?)?.toDouble() ?? 5.0;
  final myCity = me['city'] as String?;

  final list = await ref.read(playersRepositoryProvider).nearby(
    lat: lat, lng: lng, radiusKm: radius,
    sport: sportFilter == 'All' ? null : sportFilter,
  );
  return list
      .where((p) =>
  p['id'] != me['id'] &&
      (myCity == null ||
          p['city'] == null ||
          p['city'] == myCity))
      .toList();
});

final playerDetailProvider =
FutureProvider.family<Map<String, dynamic>, int>(
        (ref, id) => ref.read(playersRepositoryProvider).getById(id));