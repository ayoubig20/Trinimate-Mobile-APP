/// Holds onboarding choices across screens, then syncs them to the API
/// when onboarding finishes.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class OnboardingData {
  static List<Map<String, String>> sports = []; // [{'sport': 'Padel', 'level': 'Intermediate'}]
  static double? latitude;
  static double? longitude;
  static double? radiusKm;

  static void reset() {
    sports = [];
    latitude = null;
    longitude = null;
    radiusKm = null;
  }

  static Future<bool> syncToBackend() async {
    try {
      await ApiClient.instance.put('/profile', data: {
        if (sports.isNotEmpty) 'sports': sports,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radiusKm != null) 'radiusKm': radiusKm,
      });
      reset();
      return true;
    } on DioException {
      return false;
    }
  }
}