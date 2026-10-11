import '../../../core/network/api_client.dart';

class AuthRepository {
  final _dio = ApiClient.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login',
        data: {'email': email, 'password': password});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String city,
    String? country,
    double? latitude,
    double? longitude,
    String? phone
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'city': city,
      'phone': phone,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return res.data as Map<String, dynamic>;
  }
}