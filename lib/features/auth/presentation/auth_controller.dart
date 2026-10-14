import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../profile/presentation/profile_controller.dart';
import '../data/auth_repository.dart';
import '../../chat/presentation/chat_controller.dart';
import '../../sessions/presentation/sessions_controller.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../community/presentation/community_controller.dart';
import '../../discover/presentation/discover_controller.dart';

final authRepositoryProvider =
Provider<AuthRepository>((ref) => AuthRepository());

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.error});
  final AuthStatus status;
  final String? error;
}

final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>(
        (ref) => AuthController(ref));

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref)
      : super(const AuthState(status: AuthStatus.unknown)) {
    _restore();
  }

  final Ref _ref;
  final _tokens = TokenStorage();

  Future<void> _restore() async {
    state = AuthState(
      status: (await _tokens.hasToken)
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
    );
  }

  Future<bool> login(String email, String password) async {
    try {
      final data = await _ref
          .read(authRepositoryProvider)
          .login(email.trim(), password);
      await _tokens.saveTokens(
        access: data['accessToken'] as String,
        refresh: data['refreshToken'] as String,
      );
      state = const AuthState(status: AuthStatus.authenticated);
      _ref.invalidate(currentUserProvider);
      return true;
    } on DioException catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.response?.data?['error'] as String? ??
            'Login failed. Check your connection.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String city,
    String? country,
    double? latitude,
    double? longitude,
    String? phone,
  }) async {
    try {
      final data = await _ref.read(authRepositoryProvider).register(
        name: name,
        email: email.trim(),
        password: password,
        city: city,
        country: country,
        latitude: latitude,
        longitude: longitude,
        phone: phone,
      );
      await _tokens.saveTokens(
        access: data['accessToken'] as String,
        refresh: data['refreshToken'] as String,
      );
      state = const AuthState(status: AuthStatus.authenticated);
      _ref.invalidate(currentUserProvider);
      return true;
    } on DioException catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.response?.data?['error'] as String? ??
            'Registration failed. Check your connection.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _tokens.clear();
    _ref.invalidate(currentUserProvider);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
  void _resetUserState() {
    _ref.invalidate(currentUserProvider);
    _ref.invalidate(chatsListProvider);
    _ref.invalidate(messagesProvider);       // invalidating a family clears every instance
    _ref.invalidate(sessionsListProvider);
    _ref.invalidate(sessionDetailProvider);
    _ref.invalidate(participantsProvider);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(eventsProvider);
    _ref.invalidate(nearbyPlayersProvider);
    _ref.invalidate(pingedIdsProvider);
  }
}