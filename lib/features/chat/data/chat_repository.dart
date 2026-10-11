import '../../../core/network/api_client.dart';

class ChatRepository {
  final _dio = ApiClient.instance;

  Future<List<dynamic>> chats() async =>
      (await _dio.get('/chats')).data as List<dynamic>;

  Future<int> openChatWith(int userId) async =>
      (await _dio.post('/chats/with/$userId')).data['chatId'] as int;

  Future<List<dynamic>> messages(int chatId) async =>
      (await _dio.get('/chats/$chatId/messages')).data as List<dynamic>;

  Future<Map<String, dynamic>> send(int chatId, String text,
      {String kind = 'text'}) async =>
      (await _dio.post('/chats/$chatId/messages',
          data: {'text': text, 'kind': kind}))
          .data as Map<String, dynamic>;

  Future<void> react(int messageId, String emoji) async =>
      _dio.post('/messages/$messageId/reactions',
          data: {'emoji': emoji});
}