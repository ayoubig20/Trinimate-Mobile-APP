import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/network/api_client.dart';

/// Sport names from the server (GET /sports). Falls back to the built-in
/// list if the request fails, so the screens never end up empty.
final sportsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final res = await ApiClient.instance.get('/sports');
    final names =
    (res.data as List).map((s) => s['name'] as String).toList();
    return names.isEmpty ? MockData.sports : names;
  } catch (_) {
    return MockData.sports;
  }
});