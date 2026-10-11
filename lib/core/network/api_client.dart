import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';

/// dio instance that attaches the JWT to every request and refreshes
/// the access token automatically when it expires (401).
class ApiClient {
  ApiClient._();

  static final TokenStorage _tokens = TokenStorage();
  static Dio? _dio;

  static Dio get instance {
    _dio ??= Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ))..interceptors.add(AuthInterceptor(_tokens));
    return _dio!;
  }
}

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokens);

  final TokenStorage _tokens;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokens.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra['retried'] == true) {
      handler.next(err);
      return;
    }
    // Try refresh once
    final refresh = await _tokens.refreshToken;
    if (refresh == null) {
      await _tokens.clear();
      handler.next(err);
      return;
    }
    try {
      final res = await Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      await _tokens.saveTokens(
        access: res.data['accessToken'] as String,
        refresh: res.data['refreshToken'] as String,
      );
      // Retry original request with the new token
      final opts = err.requestOptions;
      opts.extra['retried'] = true;
      opts.headers['Authorization'] =
      'Bearer ${res.data['accessToken']}';
      final response = await ApiClient.instance.fetch(opts);
      handler.resolve(response);
    } catch (_) {
      await _tokens.clear();
      handler.next(err);
    }
  }
}