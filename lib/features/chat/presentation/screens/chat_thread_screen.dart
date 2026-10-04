import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, required this.chatId});

  final String chatId;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _inputController = TextEditingController();
  late final List<MockMessage> _messages =
  List.of(MockData.threadYassine);

  String get _peerName {
    for (final c in MockData.chats) {
      if (c.id == widget.chatId) return c.name;
    }
    return 'Player';
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _messages.add(MockMessage(
        id: 'local_${_messages.length}',
        senderName: 'Me',
        text: trimmed,
        time: 'now',
        isMine: true,
      ));
    });
    _inputController.clear();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.text, size: 20),
                  ),
                  const SizedBox(width: 12),
                  PlayerAvatar(name: _peerName, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_peerName,
                            style: AppTextStyles.bodyMedium(size: 15)),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text('Active now',
                                style: AppTextStyles.body(
                                    size: 11,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[_messages.length - 1 - i];
                  return _Bubble(message: m);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _QuickChip(
                    label: 'Confirm time',
                    icon: Icons.schedule,
                    onTap: () => _send('Time confirmed on my side.'),
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    label: 'Share location',
                    icon: Icons.place,
                    onTap: () => _send('Sharing my location...'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: AppTextStyles.bodyMedium(),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _send,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _send(_inputController.text),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final MockMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 4),
            bottomRight: Radius.circular(mine ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text,
                style: AppTextStyles.body(
                    color: mine ? Colors.white : AppColors.text)),
            const SizedBox(height: 3),
            Text(message.time,
                style: AppTextStyles.body(
                    size: 10,
                    color: mine ? Colors.white70 : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(
      {required this.label,
        required this.icon,
        required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.body(
                    size: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}