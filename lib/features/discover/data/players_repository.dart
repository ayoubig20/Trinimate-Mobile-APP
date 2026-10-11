import '../../../core/network/api_client.dart';

class PlayersRepository {
  final _dio = ApiClient.instance;

  Future<List<dynamic>> nearby({
    required double lat,
    required double lng,
    double radiusKm = 5,
    String? sport,
  }) async {
    final res = await _dio.get('/players/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radiusKm': radiusKm,
      if (sport != null) 'sport': sport,
    });
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getById(int id) async =>
      (await _dio.get('/players/$id')).data as Map<String, dynamic>;
}