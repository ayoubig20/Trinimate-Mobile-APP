import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/location_picker.dart';
import '../sessions_controller.dart';

String _two(int n) => n.toString().padLeft(2, '0');

(IconData, Color) _sportStyle(String sport) => switch (sport) {
  'Football' => (Icons.sports_soccer, const Color(0xFF2E9E5B)),
  'Basketball' =>
  (Icons.sports_basketball, const Color(0xFFEF8633)),
  'Tennis' => (Icons.sports_tennis, const Color(0xFF7CB342)),
  'Padel' => (Icons.sports_tennis, const Color(0xFF26A0B8)),
  'Running' => (Icons.directions_run, const Color(0xFF43A047)),
  'Cycling' => (Icons.directions_bike, const Color(0xFFEF6C00)),
  'Swimming' => (Icons.pool, const Color(0xFF1E88E5)),
  'Yoga' => (Icons.self_improvement, const Color(0xFFAB6BC0)),
  _ => (Icons.emoji_events, AppColors.primary),
};

const _stepLabels = ['Activité', 'Lieu', 'Moment', 'Participants', 'Options'];
const _durations = [30, 45, 60, 90, 120, 180, 360, 480, 1440];
const _levels = ['Débutant', 'Intermédiaire', 'Avancé', 'Tous niveaux'];
const _tagOptions = ['Chill', 'Compétitif', 'Débutants OK', 'Mixte'];
const _equipOptions = [
  'Chaussures', 'Protège-tibias', 'Ballon', 'Chasuble', 'Gants', 'Gourde',
];

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState
    extends ConsumerState<CreateSessionScreen> {
  int _step = 0;
  bool _publishing = false;

  // step 1 — activité
  String _sport = MockData.sports.first;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // step 2 — lieu
  final _cityCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  double? _lat, _lng;

  // step 3 — moment
  DateTime? _date;
  TimeOfDay? _time;
  int _duration = 120;

  // step 4 — participants
  String _level = 'Tous niveaux';
  int _capacity = 10;
  bool _openJoin = true;

  // step 5 — options
  final _priceCtrl = TextEditingController();
  final Set<String> _tags = {};
  final Set<String> _equipment = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _placeCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  int get _openSpots => (_capacity - 1).clamp(0, _capacity);

  // ---------- navigation ----------

  bool _canNext() {
    switch (_step) {
      case 0:
        return _titleCtrl.text.trim().isNotEmpty;
      case 1:
        return _cityCtrl.text.trim().isNotEmpty &&
            _placeCtrl.text.trim().isNotEmpty;
      case 2:
        return _date != null && _time != null;
      default:
        return true;
    }
  }

  Future<void> _next() async {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      await _publish();
    }
  }

  Future<void> _publish() async {
    final dt = DateTime(_date!.year, _date!.month, _date!.day,
        _time!.hour, _time!.minute);
    setState(() => _publishing = true);
    try {
      await ref.read(sessionsRepositoryProvider).create(
        sport: _sport,
        title: _titleCtrl.text.trim(),
        dateTimeMillis: dt.millisecondsSinceEpoch,
        place: _placeCtrl.text.trim(),
        playersNeeded: _capacity,
        latitude: _lat,
        longitude: _lng,
        visibleToCommunity: true,
        durationMinutes: _duration,
        level: _level,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()),
        tags: _tags.isEmpty ? null : _tags.toList(),
        equipment:
        _equipment.isEmpty ? null : _equipment.toList(),
      );
      ref.invalidate(sessionsListProvider);
      ref.invalidate(mySessionsProvider('organized'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match créé !')));
      context.go(AppRoutes.activities);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['error'] as String? ??
              'Could not publish')));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            // header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CRÉER UN MATCH',
                            style: AppTextStyles.headline(size: 26)),
                        Text('Organise ton activité sportive',
                            style: AppTextStyles.body(
                                size: 12,
                                color: AppColors.textMuted)),
                      ]),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.discover),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.close,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // step progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                Row(
                  children: [
                    for (var i = 0; i < 5; i++) ...[
                      Expanded(
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 200),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? AppColors.primary
                                : AppColors.surface2,
                            borderRadius:
                            BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      if (i < 4) const SizedBox(width: 5),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ÉTAPE ${_step + 1}/5',
                          style: AppTextStyles.label(
                              size: 11,
                              color: AppColors.primary)),
                      Text(_stepLabels[_step].toUpperCase(),
                          style: AppTextStyles.label(size: 11)),
                    ]),
              ]),
            ),
            const SizedBox(height: 8),

            // content
            Expanded(
              child: ListView(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _sectionTitle(_stepLabels[_step],
                      _stepSubtitles[_step]),
                  const SizedBox(height: 16),
                  _stepBody(),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // prev / next
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _step--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: const BorderSide(
                              color: AppColors.divider),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                        ),
                        child: Text('PRÉCÉDENT',
                            style: AppTextStyles.button(
                                color: AppColors.text)),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed:
                      (_canNext() && !_publishing)
                          ? _next
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.4),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                      ),
                      child: Text(
                        _publishing
                            ? 'CRÉATION…'
                            : (_step == 4
                            ? 'CRÉER LE MATCH'
                            : 'SUIVANT'),
                        style: AppTextStyles.button(),
                      ),
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

  static const _stepSubtitles = [
    'Sport, titre et ambiance',
    'Ville et terrain',
    'Date et heure',
    'Niveau, places et accès',
    'Tags et équipement',
  ];

  Widget _sectionTitle(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(
            left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.headline(size: 22)),
            Text(subtitle,
                style: AppTextStyles.body(
                    size: 12, color: AppColors.textMuted)),
          ]),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _stepActivity();
      case 1:
        return _stepLocation();
      case 2:
        return _stepMoment();
      case 3:
        return _stepParticipants();
      default:
        return _stepOptions();
    }
  }

  // ---- STEP 1: sport + titre + description ----
  Widget _stepActivity() {
    return Column(children: [
      for (final s in MockData.sports)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => _sport = s),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _sport == s
                    ? AppColors.primary.withOpacity(0.10)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _sport == s
                      ? AppColors.primary
                      : AppColors.divider,
                  width: _sport == s ? 1.5 : 1,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _sportStyle(s).$2.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_sportStyle(s).$1,
                      color: _sportStyle(s).$2, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(s,
                        style: AppTextStyles.bodyMedium(
                            size: 15))),
                if (_sport == s)
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 22),
              ]),
            ),
          ),
        ),
      const SizedBox(height: 12),
      _field('Titre du match *', 'match 5 vs 5', _titleCtrl),
      const SizedBox(height: 12),
      _field('Description (optionnel)',
          'Infos supplémentaires, conditions…', _descCtrl,
          maxLines: 3),
    ]);
  }

  // ---- STEP 2: lieu ----
  Widget _stepLocation() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Ville *', 'Agadir, Casablanca…', _cityCtrl),
          const SizedBox(height: 12),
          _field('Club / terrain *', 'Padel Club Agadir',
              _placeCtrl),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await pickLocation(context,
                  initialLat: _lat, initialLng: _lng);
              if (picked != null) {
                setState(() {
                  _lat = picked.lat;
                  _lng = picked.lng;
                  if (picked.placeName.isNotEmpty) {
                    _placeCtrl.text = picked.placeName;
                  }
                });
              }
            },
            child: Text('📍 CHOISIR SUR LA CARTE',
                style: AppTextStyles.label(
                    color: AppColors.primary)),
          ),
          if (_lat != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  'Position enregistrée ✓  (${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)})',
                  style: AppTextStyles.body(
                      size: 12, color: AppColors.textMuted)),
            ),
        ]);
  }

  // ---- STEP 3: date / heure / durée ----
  Widget _stepMoment() {
    return Column(children: [
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final p = await showDatePicker(
                context: context,
                initialDate:
                now.add(const Duration(days: 1)),
                firstDate: now,
                lastDate:
                now.add(const Duration(days: 90)),
              );
              if (p != null) setState(() => _date = p);
            },
            child: _pickerCard(
                Icons.calendar_today_outlined,
                'Date *',
                _date == null
                    ? 'Choisir'
                    : '${_two(_date!.day)}/${_two(_date!.month)}/${_date!.year}'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final p = await showTimePicker(
                context: context,
                initialTime:
                const TimeOfDay(hour: 18, minute: 30),
              );
              if (p != null) setState(() => _time = p);
            },
            child: _pickerCard(
                Icons.schedule,
                'Heure *',
                _time == null
                    ? 'Choisir'
                    : '${_two(_time!.hour)}:${_two(_time!.minute)}'),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: Text('DURÉE *',
            style: AppTextStyles.label()),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final d in _durations)
            _pill(
              label: d >= 60
                  ? (d % 60 == 0
                  ? '${d ~/ 60} h'
                  : '${d ~/ 60} h ${d % 60}')
                  : '$d min',
              selected: _duration == d,
              onTap: () => setState(() => _duration = d),
            ),
        ],
      ),
    ]);
  }

  // ---- STEP 4: participants ----
  Widget _stepParticipants() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NIVEAU REQUIS *',
              style: AppTextStyles.label()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in _levels)
                _pill(
                  label: l,
                  selected: _level == l,
                  onTap: () => setState(() => _level = l),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _stepperCard(
            icon: Icons.groups_outlined,
            title: 'Capacité totale',
            range: '2–100',
            value: _capacity,
            onChanged: (v) =>
                setState(() => _capacity = v.clamp(2, 100)),
          ),
          const SizedBox(height: 12),
          _stepperCard(
            icon: Icons.person_add_alt,
            title: 'Places à pourvoir',
            range: '0–${_capacity - 1}',
            value: _openSpots,
            onChanged: (v) => setState(() =>
            _capacity = (v + 1).clamp(2, 100)),
          ),
          const SizedBox(height: 8),
          Text('1 place déjà occupée (toi) · $_openSpots places ouvertes',
              style: AppTextStyles.body(
                  size: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text('Inscription libre',
                          style: AppTextStyles.bodyMedium(
                              size: 14)),
                      Text(
                          'Les participants rejoignent directement',
                          style: AppTextStyles.body(
                              size: 11,
                              color: AppColors.textMuted)),
                    ]),
              ),
              Switch(
                value: _openJoin,
                onChanged: (v) =>
                    setState(() => _openJoin = v),
                activeColor: AppColors.primary,
              ),
            ]),
          ),
        ]);
  }

  // ---- STEP 5: tags + équipement ----
  Widget _stepOptions() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Prix du terrain (MAD, optionnel)',
              'ex: 120 — divisé entre les participants', _priceCtrl,
              keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          Text('TAGS (OPTIONNEL)',
              style: AppTextStyles.label()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _tagOptions)
                _pill(
                  label: t,
                  selected: _tags.contains(t),
                  onTap: () => setState(() =>
                  _tags.contains(t)
                      ? _tags.remove(t)
                      : _tags.add(t)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('ÉQUIPEMENT REQUIS (OPTIONNEL)',
              style: AppTextStyles.label()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in _equipOptions)
                _pill(
                  label: e,
                  selected: _equipment.contains(e),
                  onTap: () => setState(() =>
                  _equipment.contains(e)
                      ? _equipment.remove(e)
                      : _equipment.add(e)),
                ),
            ],
          ),
        ]);
  }

  // ---------- small builders ----------

  Widget _field(
      String label,
      String hint,
      TextEditingController c, {
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label(size: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.bodyMedium(),
            decoration: InputDecoration(hintText: hint),
          ),
        ]);
  }

  Widget _pickerCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
          Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: AppTextStyles.body(
                      size: 11, color: AppColors.textMuted)),
              Text(value,
                  style: AppTextStyles.bodyMedium(size: 14)),
            ])),
      ]),
    );
  }

  Widget _pill(
      {required String label,
        required bool selected,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Text(label,
            style: AppTextStyles.button(
                size: 12,
                color:
                selected ? Colors.white : AppColors.textMuted)),
      ),
    );
  }

  Widget _stepperCard({
    required IconData icon,
    required String title,
    required String range,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(title,
                  style: AppTextStyles.bodyMedium(size: 14))),
          Text(range,
              style: AppTextStyles.body(
                  size: 11, color: AppColors.textMuted)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _stepBtn(Icons.remove, () => onChanged(value - 1)),
          Expanded(
            child: Center(
              child: Text('$value',
                  style: AppTextStyles.headline(size: 24)),
            ),
          ),
          _stepBtn(Icons.add, () => onChanged(value + 1)),
        ]),
      ]),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}