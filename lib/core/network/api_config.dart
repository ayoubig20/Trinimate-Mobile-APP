class ApiConfig {
  /// For a real phone on the same Wi-Fi → your PC's IPv4 address.
  /// (For the emulator instead: 'http://10.0.2.2:8080/api/v1')
  static const String baseUrl = 'http://192.168.1.15:8080/api/v1';
  /// ws://IP:8080 derived from the http base URL (for the chat socket)
  static String get wsBase =>
      baseUrl.replaceFirst('http://', 'ws://').replaceFirst('/api/v1', '');
}