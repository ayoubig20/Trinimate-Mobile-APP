import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final currentUserProvider =
FutureProvider<Map<String, dynamic>>((ref) async {
  final res = await ApiClient.instance.get('/profile');
  return res.data as Map<String, dynamic>;
});

/// PUT /profile with whichever fields changed; then refresh the provider.
Future<bool> updateProfile(WidgetRef ref, Map<String, dynamic> data) async {
  try {
    await ApiClient.instance.put('/profile', data: data);
    ref.invalidate(currentUserProvider);
    return true;
  } on DioException {
    return false;
  }
}