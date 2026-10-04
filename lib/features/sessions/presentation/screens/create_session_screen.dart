import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();

  String _sport = MockData.sports.first;
  int _playersNeeded = 4;
  bool _visibleToCommunity = true;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme:
          const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateController.text =
      '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 30),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme:
          const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _timeController.text = picked.format(context);
    }
  }

  void _publish() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session published!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CREATE SESSION',
                      style: AppTextStyles.headline(size: 28)),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close,
                        color: AppColors.textMuted, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('SPORT', style: AppTextStyles.label()),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  for (final s in MockData.sports)
                    _SportChip(
                      label: s,
                      selected: _sport == s,
                      onTap: () => setState(() => _sport = s),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: AppTextField(
                          label: 'Date',
                          hint: 'DD/MM/YYYY',
                          controller: _dateController,
                          prefixIcon: Icons.calendar_today_outlined,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Pick a date'
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: AbsorbPointer(
                        child: AppTextField(
                          label: 'Time',
                          hint: '18:30',
                          controller: _timeController,
                          prefixIcon: Icons.schedule_outlined,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Pick a time'
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Location',
                hint: 'e.g. Padel Club Agadir',
                controller: _locationController,
                prefixIcon: Icons.place_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Location is required'
                    : null,
              ),
              const SizedBox(height: 20),
              Text('PLAYERS NEEDED', style: AppTextStyles.label()),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final n in [2, 4, 6, 8, 10]) ...[
                    if (n != 2) const SizedBox(width: 8),
                    Expanded(
                      child: _PlayersPill(
                        n: n,
                        selected: _playersNeeded == n,
                        onTap: () =>
                            setState(() => _playersNeeded = n),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Visible to community',
                        style: AppTextStyles.bodyMedium()),
                    Switch(
                      value: _visibleToCommunity,
                      onChanged: (v) =>
                          setState(() => _visibleToCommunity = v),
                      activeColor: AppColors.primary,
                      activeTrackColor:
                      AppColors.primary.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                  label: 'Publish session', onPressed: _publish),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip(
      {required this.label,
        required this.selected,
        required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: AppTextStyles.bodyMedium(
                size: 13,
                color: selected ? Colors.white : AppColors.text)),
      ),
    );
  }
}

class _PlayersPill extends StatelessWidget {
  const _PlayersPill(
      {required this.n, required this.selected, required this.onTap});

  final int n;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('$n',
            textAlign: TextAlign.center,
            style: AppTextStyles.button(
                size: 14,
                color: selected ? Colors.white : AppColors.textMuted)),
      ),
    );
  }
}