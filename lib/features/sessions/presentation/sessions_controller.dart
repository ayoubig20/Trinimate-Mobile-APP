import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/sessions_repository.dart';

final sessionsRepositoryProvider =
Provider<SessionsRepository>((ref) => SessionsRepository());

final sessionsListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) =>
    ref.read(sessionsRepositoryProvider).list());

final sessionDetailProvider =
FutureProvider.autoDispose.family<Map<String, dynamic>, int>(
        (ref, id) => ref.read(sessionsRepositoryProvider).getById(id));

final participantsProvider =
FutureProvider.autoDispose.family<List<dynamic>, int>((ref, id) async =>
(await ApiClient.instance.get('/sessions/$id/participants'))
    .data as List<dynamic>);
final mySessionsProvider =
FutureProvider.family<List<dynamic>, String>((ref, role) =>
    ref.read(sessionsRepositoryProvider).mine(role));