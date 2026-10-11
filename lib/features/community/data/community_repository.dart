import '../../../core/network/api_client.dart';

class CommunityRepository {
  final _dio = ApiClient.instance;

  /// GET /events — list all events (with joinedCount)
  Future<List<dynamic>> events() async =>
      (await _dio.get('/events')).data as List<dynamic>;

  /// POST /events — create a new event
  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String place,
    required int eventTimeMillis,
    String? sport,
    double? latitude,
    double? longitude,
  }) async =>
      (await _dio.post('/events', data: {
        'title': title,
        'place': place,
        'eventTime': eventTimeMillis,
        'sport': sport,
        'latitude': latitude,
        'longitude': longitude,
      }))
          .data as Map<String, dynamic>;

  Future<void> joinEvent(int id) async =>
      _dio.post('/events/$id/join');

  Future<void> leaveEvent(int id) async =>
      _dio.post('/events/$id/leave');

  Future<void> deleteEvent(int id) async =>
      _dio.delete('/events/$id');
}