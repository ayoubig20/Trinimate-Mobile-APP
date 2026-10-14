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
  String get activitiesNearYou => get('activities_near_you');
  String get playersNearYou => get('players_near_you');
  String get listMode => get('list_mode');
  String get mapMode => get('map_mode');
  String get searchHint => get('search_hint');
  String get spotsLeft => get('spots_left');
  String get noSessions => get('no_sessions');
  static const _t = {
    'en': {
      'discover': 'DISCOVER', 'nearby_players': 'NEARBY PLAYERS',
      'chats': 'CHATS', 'community': 'COMMUNITY', 'profile': 'PROFILE',
      'logout': 'LOG OUT', 'join_session': 'Join session',
      'publish_session': 'Publish session', 'create_session': 'CREATE SESSION',
      'no_players_nearby': 'No players found nearby yet.',
      'open_sessions': 'OPEN SESSIONS', 'events': 'EVENTS',
      'notifications': 'NOTIFICATIONS','activities_near_you': 'ACTIVITIES NEAR YOU', 'players_near_you': 'PLAYERS NEAR YOU',
      'list_mode': 'List', 'map_mode': 'Map', 'search_hint': 'Search an activity or player',
      'spots_left': 'spots left', 'no_sessions': 'No open sessions — create one!',
    },
    'fr': {
      'discover': 'DÉCOUVRIR', 'nearby_players': 'JOUEURS PROCHES',
      'chats': 'MESSAGES', 'community': 'COMMUNAUTÉ', 'profile': 'PROFIL',
      'logout': 'DÉCONNEXION', 'join_session': 'Rejoindre',
      'publish_session': 'Publier la séance', 'create_session': 'CRÉER UNE SÉANCE',
      'no_players_nearby': 'Aucun joueur trouvé à proximité.',
      'open_sessions': 'SÉANCES OUVERTES', 'events': 'ÉVÉNEMENTS',
      'notifications': 'NOTIFICATIONS','activities_near_you': 'ACTIVITÉS PRÈS DE TOI', 'players_near_you': 'JOUEURS PRÈS DE TOI',
      'list_mode': 'Liste', 'map_mode': 'Carte', 'search_hint': 'Rechercher une activité ou un joueur',
      'spots_left': 'places restantes', 'no_sessions': 'Aucune activité — crée-en une !',

    },
    'zh': {
      'discover': '发现', 'nearby_players': '附近的玩家',
      'chats': '聊天', 'community': '社区', 'profile': '个人资料',
      'logout': '退出登录', 'join_session': '加入活动',
      'publish_session': '发布活动', 'create_session': '创建活动',
      'no_players_nearby': '附近还没有找到玩家。',
      'open_sessions': '公开活动', 'events': '活动',
      'notifications': '通知','activities_near_you': '附近的活动', 'players_near_you': '附近的玩家',
      'list_mode': '列表', 'map_mode': '地图', 'search_hint': '搜索活动或玩家',
      'spots_left': '剩余名额', 'no_sessions': '暂无活动 — 创建一个吧！',
    },
  };
}

final stringsProvider =
Provider<Strings>((ref) => Strings(ref.watch(localeProvider)));