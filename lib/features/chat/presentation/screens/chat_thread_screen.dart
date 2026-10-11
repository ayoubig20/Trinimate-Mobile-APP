import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../chat_controller.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _inputController = TextEditingController();
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;

  int get _chatId => int.tryParse(widget.chatId) ?? 0;

  Future<void> _connectWs() async {
    final token = await TokenStorage().accessToken;
    if (token == null) return;
    final url = '${ApiConfig.wsBase}/ws/chat?chatId=$_chatId&token=$token';
    try {
      _ws = WebSocketChannel.connect(Uri.parse(url));
      _wsSub = _ws!.stream.listen((_) {
        if (mounted) ref.invalidate(messagesProvider(_chatId));
      }, onError: (_) {}, onDone: () {});
    } catch (_) {/* REST still works */}
  }

  @override
  void initState() {
    super.initState();
    _connectWs();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _ws?.sink.close();
    _inputController.dispose();
    super.dispose();
  }

  void _send(String text, {String kind = 'text'}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _inputController.clear();
    sendMessage(ref, _chatId, trimmed, kind: kind);
  }

  void _showReactions(int messageId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final e in ['👍', '❤️', '😂', '🔥', '🎾'])
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(chatRepositoryProvider)
                      .react(messageId, e);
                  ref.invalidate(messagesProvider(_chatId));
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(e, style: const TextStyle(fontSize: 28)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(_chatId));
    final chats = ref.watch(chatsListProvider).value ?? [];
    String peerName = 'Player';
    for (final c in chats) {
      if (c['id'] == _chatId) peerName = c['peerName'] as String;
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  PlayerAvatar(name: peerName, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(peerName,
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

            // Messages
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
                error: (e, _) => Center(
                  child: GestureDetector(
                    onTap: () =>
                        ref.invalidate(messagesProvider(_chatId)),
                    child: Text('Could not load messages. TAP TO RETRY',
                        style: AppTextStyles.body(
                            color: AppColors.textMuted)),
                  ),
                ),
                data: (messages) => ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[messages.length - 1 - i];
                    final kind = m['kind'] as String? ?? 'text';
                    final dt = DateTime.fromMillisecondsSinceEpoch(
                        m['sentAt'] as int);
                    final timeLabel =
                        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                    // SYSTEM message (session reminders)
                    if (kind == 'system') {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(m['text'] as String,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(
                                  size: 12,
                                  color: AppColors.textMuted)),
                        ),
                      );
                    }

                    // LOCATION message (session place)
                    if (kind == 'location') {
                      final parts = (m['text'] as String).split(',');
                      if (parts.length == 2) {
                        final lat = parts[0].trim();
                        final lng = parts[1].trim();
                        final mapUrl =
                            'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                        return Align(
                          alignment: (m['isMine'] as bool? ?? false)
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => launchUrl(Uri.parse(mapUrl),
                                mode: LaunchMode.externalApplication),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              width: MediaQuery.of(context).size.width * 0.65,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                    const BorderRadius.vertical(
                                        top: Radius.circular(11)),
                                    child: Image.network(
                                      'https://staticmap.openstreetmap.org/staticmap.php?center=$lat,$lng&zoom=15&size=480x240&markers=$lat,$lng,red-pushpin',
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(
                                            height: 80,
                                            color: AppColors.surface2,
                                            child: const Center(
                                                child: Icon(Icons.map,
                                                    color: AppColors
                                                        .textMuted)),
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.place,
                                            color: AppColors.primary,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text('Shared location',
                                              style: AppTextStyles
                                                  .bodyMedium()),
                                        ),
                                        Text('Open',
                                            style: AppTextStyles.label(
                                                size: 11,
                                                color:
                                                AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    // NORMAL message bubble (long-press = reactions)
                    return GestureDetector(
                      onLongPress: () => _showReactions(m['id'] as int),
                      child: _Bubble(
                        text: m['text'] as String,
                        time: timeLabel,
                        mine: m['isMine'] as bool? ?? false,
                        reactions: (m['reactions'] as Map?)?.map(
                                (k, v) => MapEntry(k as String, v as int)) ??
                            {},
                      ),
                    );
                  },
                ),
              ),
            ),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _QuickChip(
                    label: 'Confirm time',
                    icon: Icons.schedule,
                    onTap: () =>
                        _send('Time confirmed on my side.', kind: 'system'),
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    label: 'Share location',
                    icon: Icons.place,
                    onTap: () async {
                      try {
                        var perm = await Geolocator.checkPermission();
                        if (perm == LocationPermission.denied) {
                          perm = await Geolocator.requestPermission();
                        }
                        if (perm == LocationPermission.denied ||
                            perm ==
                                LocationPermission.deniedForever) {
                          return;
                        }
                        final pos =
                        await Geolocator.getCurrentPosition(
                            desiredAccuracy:
                            LocationAccuracy.high);
                        _send('${pos.latitude},${pos.longitude}',
                            kind: 'location');
                      } catch (_) {/* ignore */}
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Input
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
                        onSubmitted: (v) => _send(v),
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
  const _Bubble({
    required this.text,
    required this.time,
    required this.mine,
    required this.reactions,
  });

  final String text;
  final String time;
  final bool mine;
  final Map<String, int> reactions;

  @override
  Widget build(BuildContext context) {
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
            Text(text,
                style: AppTextStyles.body(
                    color: mine ? Colors.white : AppColors.text)),
            const SizedBox(height: 3),
            Text(time,
                style: AppTextStyles.body(
                    size: 10,
                    color: mine ? Colors.white70 : AppColors.textMuted)),
            if (reactions.isNotEmpty) ...[
              const SizedBox(height: 5),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final e in reactions.entries)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: mine
                            ? Colors.white.withOpacity(0.2)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${e.key} ${e.value}',
                          style:
                          const TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(
      {required this.label, required this.icon, required this.onTap});

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