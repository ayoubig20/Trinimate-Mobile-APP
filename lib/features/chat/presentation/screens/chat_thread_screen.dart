import 'dart:async';
import '../../../../core/network/api_client.dart';
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
import 'dart:convert';

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
  bool _disposed = false;
  Timer? _retry;
  int _retries = 0;

  int get _chatId => int.tryParse(widget.chatId) ?? 0;

  Future<void> _connectWs() async {
    final token = await TokenStorage().accessToken;
    if (token == null || _disposed) return;
    final url = '${ApiConfig.wsBase}/ws/chat?chatId=$_chatId&token=$token';
    try {
      _ws = WebSocketChannel.connect(Uri.parse(url));
      _wsSub = _ws!.stream.listen(
            (_) {
          _retries = 0;
          if (!mounted) return;
          ref.invalidate(messagesProvider(_chatId));
          _markRead();
        },
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _retries >= 10) return;
    _retries++;
    _retry?.cancel();
    _retry = Timer(const Duration(seconds: 3), () async {
      if (_disposed) return;
      _wsSub?.cancel();
      // A REST call first: it refreshes an expired token and catches up missed messages
      try {
        await ref.read(chatRepositoryProvider).messages(_chatId);
      } catch (_) {}
      if (!mounted) return;
      ref.invalidate(messagesProvider(_chatId));
      _connectWs();
    });
  }

  Future<void> _markRead() async {
    try {
      await ref.read(chatRepositoryProvider).markRead(_chatId);
      if (mounted) ref.invalidate(chatsListProvider);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _connectWs();
    _wsSub = _ws!.stream.listen((_) {
      if (!mounted) return;
      ref.invalidate(messagesProvider(_chatId));
      ApiClient.instance
          .post('/chats/$_chatId/read')
          .catchError((_) => true);
    }, onError: (_) {}, onDone: () {});
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _wsSub?.cancel();
    _ws?.sink.close();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _send(String text, {String kind = 'text'}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _inputController.clear();
    try {
      await sendMessage(ref, _chatId, trimmed, kind: kind);
    } catch (_) {
      if (!mounted) return;
      if (kind == 'text') _inputController.text = trimmed; // give the text back
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message not sent')));
    }
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
    String? peerAvatar;
    for (final c in chats) {
      if (c['id'] == _chatId) {
        peerName = c['peerName'] as String;
        peerAvatar = c['peerAvatarUrl'] as String?;
      }
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
                    onTap: () {
                      ref.invalidate(chatsListProvider);
                      context.pop();
                     },
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.text, size: 20),
                  ),
                  const SizedBox(width: 12),
                  PlayerAvatar(name: peerName, radius: 20, imageUrl: peerAvatar),
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
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.network(
                                          'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=15&size=480x240&markers=$lat,$lng,red-pushpin',
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (c, w, p) => p ==
                                              null
                                              ? w
                                              : Container(
                                            height: 130,
                                            color: const Color(
                                                0xFF1B2A26),
                                            child: const Center(
                                              child:
                                              CircularProgressIndicator(
                                                color: AppColors
                                                    .primary,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                height: 130,
                                                decoration:
                                                const BoxDecoration(
                                                  gradient:
                                                  LinearGradient(
                                                    colors: [
                                                      Color(0xFF15352C),
                                                      Color(0xFF0B1F1A),
                                                    ],
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.map_outlined,
                                                      color: Colors
                                                          .white38,
                                                      size: 40),
                                                ),
                                              ),
                                        ),
                                        // WhatsApp-style pin on top
                                        const Icon(
                                            Icons.location_pin,
                                            color: Color(0xFFFF5252),
                                            size: 42),
                                      ],
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
// SESSION card (sent automatically when someone joins)
                    if (kind == 'session') {
                      Map<String, dynamic>? s;
                      try {
                        s = jsonDecode(m['text'] as String) as Map<String, dynamic>;
                      } catch (_) {}
                      if (s != null) {
                        final when = DateTime.fromMillisecondsSinceEpoch(
                            (s['dateTime'] as num).toInt());
                        String two(int n) => n.toString().padLeft(2, '0');
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            width: MediaQuery.of(context).size.width * 0.78,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: AppColors.primary.withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event_available,
                                        color: AppColors.primary, size: 18),
                                    const SizedBox(width: 6),
                                    Text('SESSION CONFIRMED',
                                        style: AppTextStyles.label(
                                            size: 11, color: AppColors.primary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(s['title'] as String? ?? '',
                                    style: AppTextStyles.bodyMedium(size: 15)),
                                const SizedBox(height: 4),
                                Text('${s['place'] ?? ''}',
                                    style: AppTextStyles.body(
                                        size: 12, color: AppColors.textMuted)),
                                const SizedBox(height: 6),
                                Text(
                                    '${when.day}/${when.month}/${when.year} · ${two(when.hour)}:${two(when.minute)}',
                                    style: AppTextStyles.bodyMedium(size: 13)),
                                Text('${s['players']} players needed',
                                    style: AppTextStyles.body(
                                        size: 12, color: AppColors.textMuted)),
                              ],
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
                    onTap: () => _send('✅ Time confirmed on my side.'),
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