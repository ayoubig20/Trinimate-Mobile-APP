import '../../../core/network/api_client.dart';

class SessionsRepository {
  final _dio = ApiClient.instance;

  Future<List<dynamic>> list() async =>
      (await _dio.get('/sessions')).data as List<dynamic>;

  Future<Map<String, dynamic>> getById(int id) async =>
      (await _dio.get('/sessions/$id')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> create({
    required String sport,
    required String title,
    required int dateTimeMillis,
    required String place,
    required int playersNeeded,
    double? price,
    double? latitude,
    double? longitude,
    bool visibleToCommunity = true,
    int? durationMinutes,
    String? level,
    String? description,
    List<String>? tags,
    List<String>? equipment,
  }) async {
    final res = await _dio.post('/sessions', data: {
      'sport': sport,
      'title': title,
      'dateTime': dateTimeMillis,
      'place': place,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'playersNeeded': playersNeeded,
      'visibleToCommunity': visibleToCommunity,
      'durationMinutes': durationMinutes,
      'level': level,
      'description': description,
      'tags': tags,
      'equipment': equipment,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> join(int id) async =>
      (await _dio.post('/sessions/$id/join')).data as Map<String, dynamic>;

  Future<List<dynamic>> mine(String role) async =>
      (await _dio.get('/sessions/mine', queryParameters: {'role': role}))
          .data as List<dynamic>;
}