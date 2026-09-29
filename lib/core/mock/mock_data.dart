/// Temporary in-memory data. Stage 6 replaces this with API repositories
/// behind the exact same shapes, so UI code won't change.

enum MockSport { padel, tennis, football, running, basketball, cycling }

class MockPlayer {
  const MockPlayer({
    required this.id,
    required this.name,
    required this.city,
    required this.sport,
    required this.level,
    required this.distanceKm,
    required this.rating,
    required this.sessions,
    required this.responseRate,
    required this.bio,
  });

  final String id;
  final String name;
  final String city;
  final String sport;
  final String level;
  final double distanceKm;
  final double rating;
  final int sessions;
  final int responseRate;
  final String bio;
}

class MockSession {
  const MockSession({
    required this.id,
    required this.sport,
    required this.title,
    required this.dateTimeLabel,
    required this.place,
    required this.fee,
    required this.playersJoined,
    required this.playersNeeded,
  });

  final String id;
  final String sport;
  final String title;
  final String dateTimeLabel;
  final String place;
  final String fee;
  final int playersJoined;
  final int playersNeeded;
}

class MockEvent {
  const MockEvent({
    required this.id,
    required this.day,
    required this.month,
    required this.title,
    required this.place,
    required this.time,
  });

  final String id;
  final String day;
  final String month;
  final String title;
  final String place;
  final String time;
}

class MockChatPreview {
  const MockChatPreview({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final bool unread;
}

class MockMessage {
  const MockMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isMine,
  });

  final String id;
  final String senderName;
  final String text;
  final String time;
  final bool isMine;
}

class MockNotification {
  const MockNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
  });

  final String id;
  final String type; // ping_accepted, pickup_game, new_message, session_reminder
  final String title;
  final String body;
  final String time;
}

abstract final class MockData {
  static const List<String> sports = [
    'Padel', 'Tennis', 'Football', 'Running', 'Basketball', 'Cycling',
  ];

  static const List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced', 'Pro'];

  static const List<MockPlayer> players = [
    MockPlayer(
      id: 'p1', name: 'Yassine El Amrani', city: 'Agadir', sport: 'Padel',
      level: 'Intermediate', distanceKm: 1.2, rating: 4.8, sessions: 42,
      responseRate: 96,
      bio: 'Padel addict since 2021. Usually free weeknights after 18:00. '
          'Looking for regular doubles partners at Padel Club Agadir.',
    ),
    MockPlayer(
      id: 'p2', name: 'Sara Bennis', city: 'Agadir', sport: 'Tennis',
      level: 'Advanced', distanceKm: 2.5, rating: 4.9, sessions: 87,
      responseRate: 92,
      bio: 'Ex-college tennis player. Happy to hit with anyone advanced '
          'or ambitious intermediate.',
    ),
    MockPlayer(
      id: 'p3', name: 'Omar Tazi', city: 'Agadir', sport: 'Football',
      level: 'Intermediate', distanceKm: 0.8, rating: 4.5, sessions: 63,
      responseRate: 88,
      bio: '5-a-side every Thursday. We always need one more player — ping me.',
    ),
    MockPlayer(
      id: 'p4', name: 'Laila Idrissi', city: 'Agadir', sport: 'Running',
      level: 'Pro', distanceKm: 3.1, rating: 5.0, sessions: 210,
      responseRate: 99,
      bio: 'Marathon runner. Easy 10k at dawn, long runs on Sundays along the corniche.',
    ),
    MockPlayer(
      id: 'p5', name: 'Karim Fassi', city: 'Agadir', sport: 'Basketball',
      level: 'Beginner', distanceKm: 2.0, rating: 4.2, sessions: 12,
      responseRate: 80,
      bio: 'New to basketball, training fundamentals. Looking for patient players.',
    ),
    MockPlayer(
      id: 'p6', name: 'Nour Alaoui', city: 'Agadir', sport: 'Cycling',
      level: 'Advanced', distanceKm: 4.4, rating: 4.7, sessions: 98,
      responseRate: 94,
      bio: 'Road cyclist. Saturday morning club rides, 60–90 km, steady pace.',
    ),
  ];

  static const List<MockSession> sessions = [
    MockSession(
      id: 's1', sport: 'Padel', title: 'Padel doubles — mixed level',
      dateTimeLabel: 'Sat 4 Oct · 18:30', place: 'Padel Club Agadir',
      fee: '120 MAD — split 4 ways', playersJoined: 3, playersNeeded: 4,
    ),
    MockSession(
      id: 's2', sport: 'Football', title: '5-a-side night game',
      dateTimeLabel: 'Thu 9 Oct · 21:00', place: 'City Arena Agadir',
      fee: '300 MAD — split 10 ways', playersJoined: 8, playersNeeded: 10,
    ),
    MockSession(
      id: 's3', sport: 'Running', title: 'Sunday corniche long run',
      dateTimeLabel: 'Sun 12 Oct · 07:00', place: 'Marina Agadir',
      fee: 'Free', playersJoined: 5, playersNeeded: 12,
    ),
  ];

  static const List<MockEvent> events = [
    MockEvent(
      id: 'e1', day: '04', month: 'OCT',
      title: 'Agadir Padel Open — mixed doubles',
      place: 'Padel Club Agadir', time: '10:00',
    ),
    MockEvent(
      id: 'e2', day: '11', month: 'OCT',
      title: 'Community 5-a-side pickup game',
      place: 'City Arena Agadir', time: '20:30',
    ),
    MockEvent(
      id: 'e3', day: '19', month: 'OCT',
      title: 'Sunrise group ride — 70 km',
      place: 'Marina Agadir', time: '06:30',
    ),
  ];

  static const List<MockChatPreview> chats = [
    MockChatPreview(
      id: 'c1', name: 'Yassine El Amrani',
      lastMessage: 'Perfect, see you at 18:30 then', time: '14:02', unread: true,
    ),
    MockChatPreview(
      id: 'c2', name: 'Sara Bennis',
      lastMessage: 'Court 3 is booked', time: 'Yesterday', unread: true,
    ),
    MockChatPreview(
      id: 'c3', name: 'Omar Tazi',
      lastMessage: 'We still need a keeper 😅', time: 'Mon', unread: false,
    ),
    MockChatPreview(
      id: 'c4', name: 'Laila Idrissi',
      lastMessage: 'Great run today!', time: 'Sun', unread: false,
    ),
  ];

  static const List<MockMessage> threadYassine = [
    MockMessage(
      id: 'm1', senderName: 'Yassine El Amrani',
      text: 'Hey! Saw your ping — up for padel this Saturday?',
      time: '13:40', isMine: false,
    ),
    MockMessage(
      id: 'm2', senderName: 'Me',
      text: 'Definitely. What time works for you?', time: '13:47', isMine: true,
    ),
    MockMessage(
      id: 'm3', senderName: 'Yassine El Amrani',
      text: '18:30 at Padel Club Agadir. Court fee is 120 MAD, 4 of us splitting.',
      time: '13:52', isMine: false,
    ),
    MockMessage(
      id: 'm4', senderName: 'Me',
      text: 'Perfect, see you at 18:30 then', time: '14:02', isMine: true,
    ),
  ];

  static const List<MockNotification> notifications = [
    MockNotification(
      id: 'n1', type: 'ping_accepted',
      title: 'Ping accepted',
      body: 'Yassine accepted your ping — padel on Saturday at 18:30.',
      time: '2 min ago',
    ),
    MockNotification(
      id: 'n2', type: 'pickup_game',
      title: 'New pickup game nearby',
      body: '5-a-side football at City Arena, 2.1 km away, starts 21:00.',
      time: '1 h ago',
    ),
    MockNotification(
      id: 'n3', type: 'new_message',
      title: 'New message',
      body: 'Sara: Court 3 is booked.',
      time: 'Yesterday',
    ),
    MockNotification(
      id: 'n4', type: 'session_reminder',
      title: 'Session reminder',
      body: 'Padel doubles starts in 2 hours at Padel Club Agadir.',
      time: 'Yesterday',
    ),
  ];
}