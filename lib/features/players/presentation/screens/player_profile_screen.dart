import 'package:flutter/material.dart';

import '../../../../shared/widgets/screen_shell.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context) {
    return ScreenShell(title: 'Player profile $playerId');
  }
}