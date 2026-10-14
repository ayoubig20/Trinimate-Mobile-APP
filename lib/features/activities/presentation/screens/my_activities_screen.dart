import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/session_card.dart';
import '../../../../shared/widgets/tab_scaffold.dart';
import '../../../sessions/presentation/sessions_controller.dart';

String _two(int n) => n.toString().padLeft(2, '0');

class MyActivitiesScreen extends ConsumerStatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  ConsumerState<MyActivitiesScreen> createState() =>
      _MyActivitiesScreenState();
}

class _MyActivitiesScreenState
    extends ConsumerState<MyActivitiesScreen> {
  bool _organized = false; // false = Rejointes, true = Organisées
  bool _showPast = false;

  @override
  Widget build(BuildContext context) {
    final role = _organized ? 'organized' : 'joined';
    final sessionsAsync = ref.watch(mySessionsProvider(role));

    final all = sessionsAsync.value ?? [];
    final now = DateTime.now().millisecondsSinceEpoch;
    final sessions = all
        .where((s) => _showPast
        ? (s['dateTime'] as int) < now
        : (s['dateTime'] as int) >= now)
        .toList();

    return TabScaffold(
      current: AppTab.activities,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MES ACTIVITÉS',
                  style: AppTextStyles.headline(size: 30)),
              const SizedBox(height: 6),
              Text('Rejointes et organisées',
                  style: AppTextStyles.body(color: AppColors.textMuted)),
              const SizedBox(height: 16),

              // Rejointes | Organisées
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    for (final (label, value) in [
                      ('REJOINTES', false),
                      ('ORGANISÉES', true),
                    ])
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _organized = value),
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: _organized == value
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius:
                              BorderRadius.circular(999),
                            ),
                            child: Center(
                              child: Text(label,
                                  style: AppTextStyles.button(
                                    size: 12,
                                    color: _organized == value
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  )),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // À venir | Passées
              Row(
                children: [
                  for (final (label, value) in [
                    ('À VENIR', false),
                    ('PASSÉES', true),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _showPast = value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _showPast == value
                                ? AppColors.primary.withOpacity(0.12)
                                : AppColors.surface,
                            borderRadius:
                            BorderRadius.circular(999),
                            border: Border.all(
                              color: _showPast == value
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            label,
                            style: AppTextStyles.button(
                              size: 11,
                              color: _showPast == value
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (sessionsAsync.hasValue)
                    Text('${sessions.length}',
                        style: AppTextStyles.label(
                            size: 12, color: AppColors.primary)),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: sessionsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary)),
              error: (e, _) => Center(
                child: GestureDetector(
                  onTap: () =>
                      ref.invalidate(mySessionsProvider(role)),
                  child: Text('Could not load. TAP TO RETRY',
                      style: AppTextStyles.body(
                          color: AppColors.textMuted)),
                ),
              ),
              data: (_) => sessions.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showPast
                            ? 'Aucune activité passée.'
                            : (_organized
                            ? 'Tu n’as rien organisé. Crée ton premier match !'
                            : 'Aucune activité rejointe. Explore et joins-en une !'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(
                            color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showPast
                            ? null
                            : context.push(
                            _organized
                                ? AppRoutes.createSession
                                : AppRoutes.discover),
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                            BorderRadius.circular(999),
                          ),
                          child: Text(
                            _organized
                                ? 'CRÉER UN MATCH'
                                : 'EXPLORER',
                            style: AppTextStyles.button(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () async => ref
                    .invalidate(mySessionsProvider(role)),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  children: [
                    for (final s in sessions)
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10),
                        child: SessionCard(
                          sport: s['sport'] as String,
                          title: s['title'] as String,
                          meta:
                          '${_two(DateTime.fromMillisecondsSinceEpoch(s['dateTime'] as int).day)}/${_two(DateTime.fromMillisecondsSinceEpoch(s['dateTime'] as int).month)} · ${_two(DateTime.fromMillisecondsSinceEpoch(s['dateTime'] as int).hour)}:${_two(DateTime.fromMillisecondsSinceEpoch(s['dateTime'] as int).minute)} · ${s['place']}',
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
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}