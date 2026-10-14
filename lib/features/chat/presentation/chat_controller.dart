import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider =
Provider<ChatRepository>((ref) => ChatRepository());

final chatsListProvider = FutureProvider.autoDispose<List<dynamic>>(
        (ref) => ref.read(chatRepositoryProvider).chats());

final messagesProvider =
FutureProvider.autoDispose.family<List<dynamic>, int>(
        (ref, chatId) => ref.read(chatRepositoryProvider).messages(chatId));

Future<void> sendMessage(WidgetRef ref, int chatId, String text,
    {String kind = 'text'}) async {
  await ref.read(chatRepositoryProvider).send(chatId, text, kind: kind);
  ref.invalidate(messagesProvider(chatId));
  ref.invalidate(chatsListProvider);
}