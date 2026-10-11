import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/event_card.dart';
import '../../../../shared/widgets/location_picker.dart';
import '../../../../shared/widgets/session_card.dart';
import '../../../../shared/widgets/tab_scaffold.dart';
import '../../../sessions/presentation/sessions_controller.dart';
import '../community_controller.dart';

String _two(int n) => n.toString().padLeft(2, '0');
String _time(int millis) {
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${_two(dt.hour)}:${_two(dt.minute)}';
}

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final sessionsAsync = ref.watch(sessionsListProvider);

    return TabScaffold(
      current: AppTab.community,
      child: Stack(
        children: [
          ListView(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text('COMMUNITY', style: AppTextStyles.headline(size: 30)),
              const SizedBox(height: 6),
              Text('Open sessions and events near you',
                  style: AppTextStyles.body(color: AppColors.textMuted)),
              const SizedBox(height: 20),

              // ---- OPEN SESSIONS ----
              Text('OPEN SESSIONS',
                  style: AppTextStyles.headline(size: 20)),
              const SizedBox(height: 12),
              sessionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary)),
                ),
                error: (e, _) => GestureDetector(
                  onTap: () => ref.invalidate(sessionsListProvider),
                  child: Text('Could not load sessions. TAP TO RETRY',
                      style: AppTextStyles.body(
                          color: AppColors.textMuted)),
                ),
                data: (sessions) => sessions.isEmpty
                    ? Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No open sessions — create one!',
                      style: AppTextStyles.body(
                          color: AppColors.textMuted)),
                )
                    : Column(
                  children: [
                    for (final s in sessions)
                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 10),
                        child: SessionCard(
                          sport: s['sport'] as String,
                          title: s['title'] as String,
                          meta:
                          '${_two(DateTime.fromMillisecondsSinceEpoch(s['dateTime'] as int).day)}/${_two(DateTime.fromMillisecondsSinceEpoch(s['dateTime'] as int).month)} · ${_time(s['dateTime'] as int)} · ${s['place']}',
                          fee: (s['price'] as num?) != null
                              ? '${(s['price'] as num).round()} MAD — split ${s['playersNeeded']} ways'
                              : (s['fee'] as String? ??
                              'Free — split on site'),
                          spotsLeft:
                          '${(s['playersNeeded'] as int) - (s['playersJoined'] as int)} spots left',
                          onTap: () => context.push(
                              '${AppRoutes.sessionDetail}/${s['id']}'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- EVENTS (+ ADD) ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('EVENTS',
                      style: AppTextStyles.headline(size: 20)),
                  GestureDetector(
                    onTap: () => _createEventSheet(context, ref),
                    child: Text('＋ ADD',
                        style: AppTextStyles.label(
                            color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              eventsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary)),
                ),
                error: (e, _) => GestureDetector(
                  onTap: () => ref.invalidate(eventsProvider),
                  child: Text('Could not load events. TAP TO RETRY',
                      style: AppTextStyles.body(
                          color: AppColors.textMuted)),
                ),
                data: (events) => events.isEmpty
                    ? Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No events scheduled. Tap ＋ ADD!',
                      style: AppTextStyles.body(
                          color: AppColors.textMuted)),
                )
                    : Column(
                  children: [
                    for (final e in events)
                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 10),
                        child: EventCard(
                          day: _two(DateTime
                              .fromMillisecondsSinceEpoch(
                              e['eventTime'] as int)
                              .day),
                          month: [
                            'JAN','FEB','MAR','APR','MAY','JUN',
                            'JUL','AUG','SEP','OCT','NOV','DEC'
                          ][DateTime.fromMillisecondsSinceEpoch(
                              e['eventTime'] as int)
                              .month -
                              1],
                          title: e['title'] as String,
                          place: e['place'] as String,
                          time: _time(e['eventTime'] as int),
                          onTap: () =>
                              _showEventDetails(context, ref, e),
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.createSession),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- EVENT DETAIL ----------

  void _showEventDetails(
      BuildContext context, WidgetRef ref, Map<String, dynamic> e) {
    final dt = DateTime.fromMillisecondsSinceEpoch(e['eventTime'] as int);
    final isCreator = e['createdBy'] != null; // backend sets it
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (e['sport'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text((e['sport'] as String).toUpperCase(),
                      style: AppTextStyles.button(size: 11)),
                ),
              const SizedBox(height: 12),
              Text(e['title'] as String,
                  style: AppTextStyles.headline(size: 24)),
              const SizedBox(height: 12),
              _Row(Icons.place_outlined, e['place'] as String),
              const SizedBox(height: 8),
              _Row(
                  Icons.calendar_today_outlined,
                  '${dt.day}/${dt.month}/${dt.year} · ${_two(dt.hour)}:${_two(dt.minute)}'),
              const SizedBox(height: 8),
              _Row(Icons.people_outline,
                  '${e['joinedCount'] ?? 0} joined'),
              if (e['latitude'] != null && e['longitude'] != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${e['latitude']},${e['longitude']}'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text('OPEN IN GOOGLE MAPS',
                      style: AppTextStyles.label(
                          color: AppColors.primary)),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          await ApiClient.instance
                              .post('/events/${e['id']}/join');
                          ref.invalidate(eventsProvider);
                          setS(() => e['joinedCount'] =
                              (e['joinedCount'] as int? ?? 0) + 1);
                        } on DioException catch (err) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(err.response?.data?['error']
                              as String? ??
                                  'Could not join')));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: const BorderSide(color: AppColors.divider),
                        shape: const StadiumBorder(),
                      ),
                      child: Text('JOIN',
                          style: AppTextStyles.button(
                              color: AppColors.text)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                      ),
                      child: Text('CLOSE', style: AppTextStyles.button()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- EVENT CREATION ----------

  void _createEventSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final placeCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    String sport = MockData.sports.first;
    DateTime? pickedDate;
    TimeOfDay? pickedTime;
    double? lat, lng;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.screenBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CREATE EVENT',
                    style: AppTextStyles.headline(size: 24)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: AppTextStyles.bodyMedium(),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Beach volleyball tournament',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in MockData.sports)
                      GestureDetector(
                        onTap: () => setS(() => sport = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sport == s
                                ? AppColors.primary
                                : AppColors.surface2,
                            borderRadius:
                            BorderRadius.circular(999),
                          ),
                          child: Text(s,
                              style: AppTextStyles.bodyMedium(
                                  size: 12,
                                  color: sport == s
                                      ? Colors.white
                                      : AppColors.text)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          final p = await showDatePicker(
                            context: ctx,
                            initialDate:
                            now.add(const Duration(days: 1)),
                            firstDate: now,
                            lastDate:
                            now.add(const Duration(days: 180)),
                          );
                          if (p != null) {
                            setS(() {
                              pickedDate = p;
                              dateCtrl.text =
                              '${_two(p.day)}/${_two(p.month)}/${p.year}';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: dateCtrl,
                            style: AppTextStyles.bodyMedium(),
                            decoration: const InputDecoration(
                                labelText: 'Date'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final p = await showTimePicker(
                            context: ctx,
                            initialTime:
                            const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (p != null) {
                            setS(() {
                              pickedTime = p;
                              timeCtrl.text =
                              '${_two(p.hour)}:${_two(p.minute)}';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: timeCtrl,
                            style: AppTextStyles.bodyMedium(),
                            decoration: const InputDecoration(
                                labelText: 'Time'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: placeCtrl,
                  style: AppTextStyles.bodyMedium(),
                  decoration: const InputDecoration(
                      labelText: 'Location (auto-filled from map)'),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked =
                    await pickLocation(ctx, initialLat: lat, initialLng: lng);
                    if (picked != null) {
                      setS(() {
                        lat = picked.lat;
                        lng = picked.lng;
                        if (picked.placeName.isNotEmpty) {
                          placeCtrl.text = picked.placeName;
                        }
                      });
                    }
                  },
                  child: Text('CHOOSE ON MAP',
                      style: AppTextStyles.label(
                          color: AppColors.primary)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty ||
                          placeCtrl.text.trim().isEmpty ||
                          pickedDate == null ||
                          pickedTime == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Fill title, location, date and time')));
                        return;
                      }
                      final dt = DateTime(
                        pickedDate!.year,
                        pickedDate!.month,
                        pickedDate!.day,
                        pickedTime!.hour,
                        pickedTime!.minute,
                      );
                      try {
                        await ref
                            .read(communityRepositoryProvider)
                            .createEvent(
                          title: titleCtrl.text.trim(),
                          place: placeCtrl.text.trim(),
                          eventTimeMillis:
                          dt.millisecondsSinceEpoch,
                          sport: sport,
                          latitude: lat,
                          longitude: lng,
                        );
                        ref.invalidate(eventsProvider);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text('Event created!')));
                      } on DioException catch (err) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                                content: Text(err.response
                                    ?.data?['error']
                                as String? ??
                                    'Could not create')));
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: Text('PUBLISH EVENT',
                        style: AppTextStyles.button()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style:
              AppTextStyles.body(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}