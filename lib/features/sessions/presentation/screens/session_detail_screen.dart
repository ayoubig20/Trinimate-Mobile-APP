import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../chat/presentation/chat_controller.dart';
import '../../../profile/presentation/profile_controller.dart';
import '../sessions_controller.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(sessionId) ?? 0;
    final sessionAsync = ref.watch(sessionDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load session.',
                    style: AppTextStyles.body(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => ref.invalidate(sessionDetailProvider(id)),
                  child: Text('TAP TO RETRY',
                      style: AppTextStyles.label(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          data: (s) {
            final dt =
            DateTime.fromMillisecondsSinceEpoch(s['dateTime'] as int);
            final joined = s['playersJoined'] as int? ?? 0;
            final needed = s['playersNeeded'] as int? ?? 0;
            final price = (s['price'] as num?)?.toDouble();
            final me = ref.watch(currentUserProvider).value;
            final isOrganizer = me != null && s['createdBy'] == me['id'];
            final participantsAsync = ref.watch(participantsProvider(id));
            final meId = me?['id'];
            final joinedIds = participantsAsync.value
                ?.map((u) => u['id'])
                .toSet() ??
                {};
            final alreadyJoined = meId != null && joinedIds.contains(meId);
            final sessionPassed =
                DateTime.now().millisecondsSinceEpoch > (s['dateTime'] as int);

            return ListView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.arrow_back_ios_new,
                        color: AppColors.text, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text((s['sport'] as String).toUpperCase(),
                            style: AppTextStyles.button(size: 11)),
                      ),
                      const SizedBox(height: 12),
                      Text(s['title'] as String,
                          style: AppTextStyles.headline(size: 26)),
                      const SizedBox(height: 12),
                      _MetaRow(
                          icon: Icons.calendar_today_outlined,
                          text:
                          '${dt.day}/${dt.month}/${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'),
                      const SizedBox(height: 8),
                      _MetaRow(
                          icon: Icons.place_outlined,
                          text: s['place'] as String),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('$joined/$needed players joined',
                            style: AppTextStyles.body(
                                color: AppColors.textMuted)),
                      ),
                      if (joined < needed)
                        Text('${needed - joined} SPOTS LEFT',
                            style: AppTextStyles.label(
                                size: 11, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          color: AppColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          price != null
                              ? '${price.round()} MAD — split $needed ways'
                              : (s['fee'] as String? ??
                              'Free — split on site'),
                          style: AppTextStyles.bodyMedium(
                              color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ---- ORGANIZER VIEW ----
                if (isOrganizer) ...[
                  SecondaryButton(
                    label: 'Group chat',
                    icon: const Icon(Icons.groups_outlined,
                        color: AppColors.text, size: 20),
                    onPressed: () async {
                      try {
                        final res = await ApiClient.instance
                            .get('/sessions/$id/chat');
                        if (!context.mounted) return;
                        context.push(
                            '${AppRoutes.chatThread}/${res.data['chatId']}');
                      } on DioException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(e.response?.data?['error']
                                as String? ??
                                    'Could not open chat')));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Edit',
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.text, size: 18),
                          onPressed: () => _editDialog(context, ref, s),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Delete',
                          onPressed: () =>
                              _confirmDelete(context, ref, id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('PARTICIPANTS', style: AppTextStyles.label()),
                  const SizedBox(height: 10),
                  participantsAsync.when(
                    data: (list) => Column(
                      children: [
                        for (final u in list)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                PlayerAvatar(
                                    name: u['name'] as String? ?? '?',
                                    radius: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(u['name'] as String? ?? '',
                                      style: AppTextStyles.bodyMedium(
                                          size: 14)),
                                ),
                                if (u['id'] != s['createdBy'])
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        await ApiClient.instance.post(
                                            '/sessions/$id/kick/${u['id']}');
                                        ref.invalidate(
                                            participantsProvider(id));
                                        ref.invalidate(
                                            sessionDetailProvider(id));
                                        ref.invalidate(
                                            sessionsListProvider);
                                      } on DioException catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(e.response
                                              ?.data?['error']
                                          as String? ??
                                              'Could not remove'),
                                        ));
                                      }
                                    },
                                    child: const Icon(
                                        Icons.remove_circle,
                                        color: Color(0xFFFF3B30),
                                        size: 20),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    ),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
                ] else ...[
                  // ---- JOINER VIEW ----
                  SecondaryButton(
                    label: 'Group chat',
                    icon: const Icon(Icons.groups_outlined,
                        color: AppColors.text, size: 20),
                    onPressed: () async {
                      try {
                        final res = await ApiClient.instance
                            .get('/sessions/$id/chat');
                        if (!context.mounted) return;
                        context.push(
                            '${AppRoutes.chatThread}/${res.data['chatId']}');
                      } on DioException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(e.response?.data?['error']
                                as String? ??
                                    'Join the session first')));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label:
                    alreadyJoined ? 'Leave session' : 'Join session',
                    onPressed: () async {
                      try {
                        if (alreadyJoined) {
                          await ApiClient.instance
                              .post('/sessions/$id/leave');
                        } else {
                          await ref
                              .read(sessionsRepositoryProvider)
                              .join(id);
                        }
                        ref.invalidate(sessionDetailProvider(id));
                        ref.invalidate(participantsProvider(id));
                        ref.invalidate(sessionsListProvider);
                      } on DioException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(e.response?.data?['error']
                                as String? ??
                                    'Could not update')));
                      }
                    },
                  ),
                ],

                // ---- RATE PLAYERS (after the session happened) ----
                if (sessionPassed && meId != null && alreadyJoined) ...[
                  const SizedBox(height: 24),
                  Text('RATE PLAYERS', style: AppTextStyles.label()),
                  const SizedBox(height: 6),
                  Text('How was the game? Rate your co-players.',
                      style: AppTextStyles.body(
                          size: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  participantsAsync.when(
                    data: (list) => Column(
                      children: [
                        for (final u in list)
                          if (u['id'] != meId)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  PlayerAvatar(
                                      name: u['name'] as String? ?? '?',
                                      radius: 16),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(u['name'] as String? ?? '',
                                        style:
                                        AppTextStyles.bodyMedium(
                                            size: 14)),
                                  ),
                                  for (var star = 1; star <= 5; star++)
                                    GestureDetector(
                                      onTap: () async {
                                        try {
                                          await ApiClient.instance.post(
                                            '/sessions/$id/rate',
                                            data: {
                                              'stars': star,
                                              'userId': u['id'],
                                            },
                                          );
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Rated ${(u['name'] as String).split(' ').first} $star⭐'),
                                          ));
                                        } on DioException catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(e.response
                                                ?.data?['error']
                                            as String? ??
                                                'Could not rate'),
                                          ));
                                        }
                                      },
                                      child: const Padding(
                                        padding:
                                        EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Icon(Icons.star_border,
                                            color: AppColors.primary,
                                            size: 22),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title:
        Text('Delete session?', style: AppTextStyles.headline(size: 20)),
        content: Text('This cannot be undone.',
            style: AppTextStyles.body(color: AppColors.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('CANCEL',
                  style:
                  AppTextStyles.button(color: AppColors.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('DELETE',
                  style: AppTextStyles.button(
                      color: const Color(0xFFFF3B30)))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ApiClient.instance.delete('/sessions/$id');
        ref.invalidate(sessionsListProvider);
        if (!context.mounted) return;
        context.go(AppRoutes.community);
      } on DioException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                e.response?.data?['error'] as String? ?? 'Delete failed')));
      }
    }
  }

  Future<void> _editDialog(BuildContext context, WidgetRef ref,
      Map<String, dynamic> s) async {
    final title = TextEditingController(text: s['title'] as String);
    final place = TextEditingController(text: s['place'] as String);
    final price = TextEditingController(
        text: (s['price'] as num?)?.toString() ?? '');
    int needed = s['playersNeeded'] as int? ?? 4;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('EDIT SESSION',
              style: AppTextStyles.headline(size: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: title,
                  style: AppTextStyles.bodyMedium(),
                  decoration:
                  const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: place,
                  style: AppTextStyles.bodyMedium(),
                  decoration:
                  const InputDecoration(labelText: 'Place')),
              TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyMedium(),
                  decoration: const InputDecoration(
                      labelText: 'Court price (MAD)')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Players: ',
                      style: AppTextStyles.bodyMedium()),
                  for (final n in [2, 4, 6, 8, 10])
                    GestureDetector(
                      onTap: () => setD(() => needed = n),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: needed == n
                              ? AppColors.primary
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$n',
                            style: TextStyle(
                                color: needed == n
                                    ? Colors.white
                                    : Colors.grey)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('CANCEL',
                    style: AppTextStyles.button(
                        color: AppColors.textMuted))),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('SAVE',
                    style: AppTextStyles.button(
                        color: AppColors.primary))),
          ],
        ),
      ),
    );

    if (saved == true) {
      final p = double.tryParse(price.text.trim());
      try {
        await ApiClient.instance.put('/sessions/${s['id']}', data: {
          'sport': s['sport'],
          'title': title.text.trim(),
          'dateTime': s['dateTime'],
          'place': place.text.trim(),
          'price': p,
          'playersNeeded': needed,
          'visibleToCommunity': true,
        });
        ref.invalidate(sessionDetailProvider(s['id'] as int));
        ref.invalidate(sessionsListProvider);
      } on DioException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                e.response?.data?['error'] as String? ?? 'Update failed')));
      }
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.body(color: AppColors.textMuted)),
      ],
    );
  }
}