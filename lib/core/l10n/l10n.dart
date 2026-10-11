import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider =
StateProvider<Locale>((ref) => const Locale('en'));

class Strings {
  const Strings(this.locale);
  final Locale locale;

  String get(String key) =>
      _t[locale.languageCode]?[key] ??
          _t['en']![key] ??
          key;

  // Convenience getters for the most-used strings
  String get discover => get('discover');
  String get nearbyPlayers => get('nearby_players');
  String get chats => get('chats');
  String get community => get('community');
  String get profile => get('profile');
  String get logout => get('logout');
  String get joinSession => get('join_session');
  String get publishSession => get('publish_session');
  String get createSession => get('create_session');
  String get noPlayersNearby => get('no_players_nearby');
  String get openSessions => get('open_sessions');
  String get events => get('events');
  String get notifications => get('notifications');

  static const _t = {
    'en': {
      'discover': 'DISCOVER', 'nearby_players': 'NEARBY PLAYERS',
      'chats': 'CHATS', 'community': 'COMMUNITY', 'profile': 'PROFILE',
      'logout': 'LOG OUT', 'join_session': 'Join session',
      'publish_session': 'Publish session', 'create_session': 'CREATE SESSION',
      'no_players_nearby': 'No players found nearby yet.',
      'open_sessions': 'OPEN SESSIONS', 'events': 'EVENTS',
      'notifications': 'NOTIFICATIONS',
    },
    'fr': {
      'discover': 'DÉCOUVRIR', 'nearby_players': 'JOUEURS PROCHES',
      'chats': 'MESSAGES', 'community': 'COMMUNAUTÉ', 'profile': 'PROFIL',
      'logout': 'DÉCONNEXION', 'join_session': 'Rejoindre',
      'publish_session': 'Publier la séance', 'create_session': 'CRÉER UNE SÉANCE',
      'no_players_nearby': 'Aucun joueur trouvé à proximité.',
      'open_sessions': 'SÉANCES OUVERTES', 'events': 'ÉVÉNEMENTS',
      'notifications': 'NOTIFICATIONS',
    },
    'zh': {
      'discover': '发现', 'nearby_players': '附近的玩家',
      'chats': '聊天', 'community': '社区', 'profile': '个人资料',
      'logout': '退出登录', 'join_session': '加入活动',
      'publish_session': '发布活动', 'create_session': '创建活动',
      'no_players_nearby': '附近还没有找到玩家。',
      'open_sessions': '公开活动', 'events': '活动',
      'notifications': '通知',
    },
  };
}

final stringsProvider =
Provider<Strings>((ref) => Strings(ref.watch(localeProvider)));