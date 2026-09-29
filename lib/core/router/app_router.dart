import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_thread_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_sports_screen.dart';
import '../../features/players/presentation/screens/player_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/sessions/presentation/screens/create_session_screen.dart';
import '../../features/sessions/presentation/screens/session_detail_screen.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const discover = '/discover';
  static const playerProfile = '/player';
  static const sessionDetail = '/session';
  static const createSession = '/create-session';
  static const chats = '/chats';
  static const chatThread = '/chat';
  static const community = '/community';
  static const notifications = '/notifications';
  static const profile = '/profile';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingSportsScreen(),
    ),
    GoRoute(
      path: AppRoutes.discover,
      builder: (context, state) => const DiscoverScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.playerProfile}/:id',
      builder: (context, state) =>
          PlayerProfileScreen(playerId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '${AppRoutes.sessionDetail}/:id',
      builder: (context, state) =>
          SessionDetailScreen(sessionId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.createSession,
      builder: (context, state) => const CreateSessionScreen(),
    ),
    GoRoute(
      path: AppRoutes.chats,
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.chatThread}/:id',
      builder: (context, state) =>
          ChatThreadScreen(chatId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.community,
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);