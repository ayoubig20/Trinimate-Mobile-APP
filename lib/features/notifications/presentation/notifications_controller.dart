import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final notificationsProvider = FutureProvider<List<dynamic>>((ref) async =>
(await ApiClient.instance.get('/notifications')).data as List<dynamic>);

/// Unread counter for the bell badge — refresh anywhere via ref.invalidate
final unreadCountProvider = FutureProvider<int>((ref) async =>
(await ApiClient.instance.get('/notifications/unread-count'))
    .data['count'] as int);

Future<void> markNotificationRead(WidgetRef ref, int id) async {
  await ApiClient.instance.put('/notifications/$id/read');
  ref.invalidate(unreadCountProvider);
  ref.invalidate(notificationsProvider);
}

Future<void> markAllNotificationsRead(WidgetRef ref) async {
  await ApiClient.instance.put('/notifications/read-all');
  ref.invalidate(unreadCountProvider);
  ref.invalidate(notificationsProvider);
}