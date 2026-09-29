import 'package:flutter/material.dart';

import '../../../../shared/widgets/screen_shell.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return ScreenShell(title: 'Session $sessionId');
  }
}