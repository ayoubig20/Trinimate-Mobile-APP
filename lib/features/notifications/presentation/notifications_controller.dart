import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final notificationsProvider = FutureProvider<List<dynamic>>((ref) async =>
(await ApiClient.instance.get('/notifications')).data as List<dynamic>);