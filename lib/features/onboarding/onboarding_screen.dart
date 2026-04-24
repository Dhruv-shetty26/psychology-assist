import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/smooth_widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _psychologistEmailController = TextEditingController();
  final _pinController = TextEditingController();
  UserRole? _role;
  DateTime? _dateOfBirth;
  bool _hasRegisteredPsychologist = true;

  @override
  void initState() {
    super.initState();
    _role = UserRole.patient;
    _psychologistEmailController.text = demoPsychologistEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _psychologistEmailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 24, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _continue() {
    if (_role == null) {
      _showMessage('Choose psychologist or patient to continue.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_role == UserRole.patient && _dateOfBirth == null) {
      _showMessage('Add your date of birth.');
      return;
    }

    final profile = AppProfile(
      role: _role!,
      name: _nameController.text.trim(),
      dateOfBirth: _role == UserRole.patient ? _dateOfBirth : null,
      email: _emailController.text.trim(),
      psychologistEmail: _role == UserRole.patient &&
              _hasRegisteredPsychologist &&
              _psychologistEmailController.text.trim().isNotEmpty
          ? _psychologistEmailController.text.trim()
          : null,
    );

    ref.read(appSessionProvider.notifier).completeOnboarding(
          profile: profile,
          lockPin: _pinController.text.trim(),
        );
  }

  void _showMessage(String message) {
    AppSnackBar.showInfo(
      context,
      title: 'Almost there',
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _NeonHeader(theme: theme),
                    const SizedBox(height: 24),
                    Text(
                      'I am a',
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            title: 'Patient',
                            icon: Icons.favorite_outline,
                            selected: _role == UserRole.patient,
                            onTap: () =>
                                setState(() => _role = UserRole.patient),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleCard(
                            title: 'Psychologist',
                            icon: Icons.psychology_alt_outlined,
                            selected: _role == UserRole.psychologist,
                            onTap: () => setState(
                              () => _role = UserRole.psychologist,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SmoothCard(
                      elevation: 18,
                      borderRadius: 22,
                      backgroundColor: Colors.white.withOpacity(0.88),
                      borderColor: AppColors.neonViolet.withOpacity(0.28),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          SmoothTextField(
                            label: 'Name',
                            hint: 'Your full name',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().length < 2) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                          ),
                          if (_role == UserRole.patient) ...[
                            const SizedBox(height: 16),
                            SmoothTextField(
                              label: 'Your email',
                              hint: 'you@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (!text.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _DateField(
                              date: _dateOfBirth,
                              onTap: _pickDate,
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _hasRegisteredPsychologist,
                              activeColor: AppColors.neonViolet,
                              title: const Text('Already consulting here?'),
                              subtitle: const Text(
                                'Link appointments to a registered psychologist.',
                              ),
                              onChanged: (value) => setState(
                                () => _hasRegisteredPsychologist = value,
                              ),
                            ),
                            if (_hasRegisteredPsychologist) ...[
                              const SizedBox(height: 12),
                              SmoothTextField(
                                label: 'Psychologist email',
                                hint: 'doctor@example.com',
                                controller: _psychologistEmailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (!_hasRegisteredPsychologist) {
                                    return null;
                                  }
                                  final text = value?.trim() ?? '';
                                  if (!text.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                          if (_role == UserRole.psychologist) ...[
                            const SizedBox(height: 16),
                            SmoothTextField(
                              label: 'Professional email',
                              hint: 'you@clinic.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (!text.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          SmoothTextField(
                            label: 'Set app lock PIN',
                            hint: '4 digit PIN',
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.length < 4) {
                                return 'Use at least 4 digits';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmoothButton(
                      label: 'Enter Calmora',
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      backgroundColor: AppColors.neonViolet,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: _continue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeonHeader extends StatelessWidget {
  final ThemeData theme;

  const _NeonHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.neonViolet, AppColors.neonPink],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonViolet.withOpacity(0.35),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
          const SizedBox(height: 20),
          Text(
            'Welcome to Calmora',
            style: AppTypography.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'A private mental wellness space for patients and psychologists.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      onTap: onTap,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      backgroundColor: selected ? AppColors.neonViolet : Colors.white,
      borderColor: selected ? AppColors.neonCyan : AppColors.lightBorder,
      elevation: selected ? 18 : 0,
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : AppColors.neonViolet,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? Colors.white : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? 'Select date of birth'
        : '${date!.day}/${date!.month}/${date!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of birth', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.lightDivider,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: AppColors.neonViolet),
                const SizedBox(width: 12),
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
