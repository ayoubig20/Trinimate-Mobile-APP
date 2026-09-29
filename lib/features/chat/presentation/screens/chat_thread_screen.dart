import 'package:flutter/material.dart';

import '../../../../shared/widgets/screen_shell.dart';

class ChatThreadScreen extends StatelessWidget {
  const ChatThreadScreen({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return ScreenShell(title: 'Chat $chatId');
  }
}