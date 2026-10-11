import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _acceptedTerms = false;
  bool _loading = false;
  bool _obscure = true;
  bool _gpsLoading = false;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _autofillFromGps();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Detect GPS position → reverse-geocode city + country via OpenStreetMap.
  Future<void> _autofillFromGps() async {
    setState(() => _gpsLoading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      final res = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': pos.latitude,
          'lon': pos.longitude,
        },
        options: Options(
          headers: {'User-Agent': 'trinimate-app'},
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final addr = res.data['address'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _cityController.text =
            (addr['city'] ?? addr['town'] ?? addr['village'] ?? '')
                .toString();
        _countryController.text = (addr['country'] ?? '').toString();
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (_) {
      // GPS or network failed — user types city/country manually
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _onCreateAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms to continue')),
      );
      return;
    }
    setState(() => _loading = true);
    final ok = await ref.read(authControllerProvider.notifier).register(
      name: _nameController.text.trim(),
      email: _emailController.text,
      password: _passwordController.text,
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      latitude: _lat,
      longitude: _lng,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.go(AppRoutes.intro);
    } else {
      final error =
          ref.read(authControllerProvider).error ?? 'Registration failed';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints:
                BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          Center(
                            child: Image.asset(
                              'assets/images/trinimate_logo.png',
                              width: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "LET'S TRAIN TOGETHER !",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.label(
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            label: 'Full name',
                            hint: 'e.g. Yassine El Amrani',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Full name is required';
                              if (v.length < 3) return 'Name is too short';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Email',
                            hint: 'you@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Email is required';
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(v)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Password',
                            hint: 'Min. 6 characters',
                            controller: _passwordController,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.lock_outline,
                            suffix: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscure = !_obscure),
                              child: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              final v = value ?? '';
                              if (v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'City',
                            hint: _gpsLoading
                                ? 'Detecting your location…'
                                : 'e.g. Agadir',
                            controller: _cityController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.location_city_outlined,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'City is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Country',
                            hint: 'e.g. Morocco',
                            controller: _countryController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.public_outlined,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Phone (optional)',
                            hint: 'e.g. +212 6 12 34 56 78',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onCreateAccount(),
                            prefixIcon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (v) => setState(
                                          () => _acceptedTerms = v ?? false),
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.white,
                                  side: const BorderSide(
                                      color: AppColors.textMuted),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() =>
                                  _acceptedTerms = !_acceptedTerms),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: AppTextStyles.body(
                                          size: 12,
                                          color: AppColors.textMuted),
                                      children: [
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style:
                                          AppTextStyles.bodyMedium(
                                              size: 12,
                                              color:
                                              AppColors.primary),
                                        ),
                                        TextSpan(
                                          text: ' and ',
                                          style: AppTextStyles.body(
                                              size: 12,
                                              color:
                                              AppColors.textMuted),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style:
                                          AppTextStyles.bodyMedium(
                                              size: 12,
                                              color:
                                              AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          PrimaryButton(
                            label: _loading
                                ? 'Creating account…'
                                : 'Create account',
                            onPressed: _loading ? null : _onCreateAccount,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                  child:
                                  Divider(color: AppColors.divider)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text('OR',
                                    style:
                                    AppTextStyles.label(size: 11)),
                              ),
                              const Expanded(
                                  child:
                                  Divider(color: AppColors.divider)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SecondaryButton(
                            label: 'Continue with Google',
                            icon: const Icon(Icons.g_mobiledata,
                                color: AppColors.text, size: 26),
                            onPressed: () {},
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            label: 'Continue with Apple',
                            icon: const Icon(Icons.apple,
                                color: AppColors.text, size: 24),
                            onPressed: () {},
                          ),
                          const Spacer(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                  style: AppTextStyles.body(
                                      color: AppColors.textMuted)),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Text('Log in',
                                    style: AppTextStyles.bodyMedium(
                                        color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}