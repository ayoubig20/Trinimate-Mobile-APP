import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

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
String _errorMessage(DioException e, String fallback) {
  final data = e.response?.data;
  if (data is Map && data['error'] is String) return data['error'] as String;
  return fallback;
}
/// Uploads a new profile picture. Returns null on success, or an error message.
Future<String?> uploadAvatar(WidgetRef ref, XFile file) async {
  try {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
    });
    await ApiClient.instance.post('/profile/avatar', data: form);
    ref.invalidate(currentUserProvider);
    return null;
  } on DioException catch (e) {
    debugPrint('Avatar upload failed: ${e.response?.statusCode} ${e.response?.data} ${e.message}');
    return _errorMessage(
        e, 'Photo upload failed (${e.response?.statusCode ?? 'no connection'})');
  }
}

Future<bool> removeAvatar(WidgetRef ref) async {
  try {
    await ApiClient.instance.delete('/profile/avatar');
    ref.invalidate(currentUserProvider);
    return true;
  } on DioException {
    return false;
  }
}