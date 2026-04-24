import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../app/home_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/smooth_widgets.dart';

class PsychologistsScreen extends ConsumerWidget {
  const PsychologistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;
    final isPsychologist = profile?.role == UserRole.psychologist;
    final psychologists = _dynamicPsychologists(profile);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Text(
                isPsychologist ? 'Patient Requests' : 'Psychologists',
                style: AppTypography.headingLarge,
              ),
              const SizedBox(height: 8),
              Text(
                isPsychologist
                    ? 'Appointments linked to your professional email appear here.'
                    : 'Choose a care provider, then book from the appointments tab.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.lightSubtext,
                ),
              ),
              const SizedBox(height: 18),
              if (isPsychologist)
                _PsychologistPracticeView(session: session)
              else
                ...psychologists.map(
                  (psychologist) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PsychologistCard(psychologist: psychologist),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<AppPsychologist> _dynamicPsychologists(AppProfile? profile) {
    final linkedEmail = profile?.psychologistEmail;
    if (linkedEmail == null ||
        demoPsychologists.any((item) => item.email == linkedEmail)) {
      return demoPsychologists;
    }
    return [
      AppPsychologist(
        name: 'Linked psychologist',
        email: linkedEmail,
        specialty: 'Your saved provider',
        availability: 'By appointment',
      ),
      ...demoPsychologists,
    ];
  }
}

class _PsychologistPracticeView extends ConsumerWidget {
  final AppSession session;

  const _PsychologistPracticeView({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = session.profile?.email ?? demoPsychologistEmail;
    final linkedAppointments = session.appointments
        .where((appointment) => appointment.psychologistEmail == email)
        .toList();
    final doctorPrescriptions = session.prescriptions
        .where((prescription) => prescription.prescribedByEmail == email)
        .toList();
    final patients = <String>{};
    for (final appointment in linkedAppointments) {
      patients.add(appointment.patientName);
    }

    if (linkedAppointments.isEmpty) {
      return SmoothCard(
        borderRadius: 18,
        backgroundColor:
            Theme.of(context).colorScheme.surface.withOpacity(0.72),
        child: const Row(
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.neonViolet),
            SizedBox(width: 12),
            Expanded(child: Text('No linked patient appointments yet.')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmoothCard(
          borderRadius: 18,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.72),
          borderColor: AppColors.neonCyan.withOpacity(0.24),
          child: Row(
            children: [
              const Icon(Icons.groups_2_outlined, color: AppColors.neonCyan),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${patients.length} active patients',
                  style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SmoothCard(
          borderRadius: 18,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.72),
          borderColor: AppColors.success.withOpacity(0.24),
          child: Row(
            children: [
              const Icon(Icons.medical_information_outlined,
                  color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Prescriptions issued: ${doctorPrescriptions.length}',
                  style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...linkedAppointments.map(
          (appointment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SmoothCard(
              borderRadius: 18,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.72),
              borderColor: appointment.confirmed
                  ? AppColors.success.withOpacity(0.22)
                  : AppColors.warning.withOpacity(0.32),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: appointment.confirmed
                      ? AppColors.success
                      : AppColors.warning,
                  child: const Icon(Icons.person_outline, color: Colors.white),
                ),
                title: Text(
                  appointment.patientName,
                  style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                ),
                subtitle: Text(
                  '${appointment.type}\n${appointment.startsAt.day}/${appointment.startsAt.month}/${appointment.startsAt.year}'
                  ' at ${appointment.startsAt.hour}:${appointment.startsAt.minute.toString().padLeft(2, '0')}'
                  '${appointment.note.isEmpty ? '' : '\n${appointment.note}'}',
                ),
                isThreeLine: appointment.note.isNotEmpty,
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (appointment.confirmed)
                      const Icon(
                        Icons.verified_outlined,
                        color: AppColors.success,
                      )
                    else
                      FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(appSessionProvider.notifier)
                              .approveAppointment(appointment);
                          AppSnackBar.showSuccess(
                            context,
                            title: 'Approved',
                            message: 'Appointment approved.',
                          );
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                      ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {
                        _showPrescriptionDialog(context, ref, appointment);
                      },
                      icon: const Icon(Icons.medical_services, size: 16),
                      label: const Text('Prescribe'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (doctorPrescriptions.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Prescription history',
            style: AppTypography.headingSmall,
          ),
          const SizedBox(height: 12),
          ...doctorPrescriptions.map(
            (prescription) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SmoothCard(
                borderRadius: 18,
                backgroundColor:
                    Theme.of(context).colorScheme.surface.withOpacity(0.72),
                child: ListTile(
                  title: Text(prescription.patientName,
                      style: AppTypography.labelLarge),
                  subtitle: Text(
                    '${prescription.medicines.join(', ')}\n${prescription.note}',
                  ),
                  isThreeLine: prescription.note.isNotEmpty,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showPrescriptionDialog(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) async {
    final session = ref.read(appSessionProvider);
    final selectedMedicines = <String>[];
    final noteController = TextEditingController();
    final patientName = appointment.patientName;
    final patientEmail = appointment.patientEmail;
    final doctorName = session.profile?.name ?? 'Dr.';
    final doctorEmail = session.profile?.email ?? demoPsychologistEmail;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prescribe medication'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Patient: $patientName', style: AppTypography.bodySmall),
              const SizedBox(height: 12),
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  final query = textEditingValue.text.toLowerCase();
                  if (query.isEmpty) {
                    return demoMedicines;
                  }
                  return demoMedicines.where(
                    (medicine) => medicine.toLowerCase().contains(query),
                  );
                },
                displayStringForOption: (option) => option,
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Medicine',
                      hintText: 'Search or type a medicine',
                    ),
                    onSubmitted: (value) {
                      final trimmed = value.trim();
                      if (trimmed.isNotEmpty &&
                          !selectedMedicines.contains(trimmed)) {
                        setDialogState(() => selectedMedicines.add(trimmed));
                      }
                      controller.clear();
                      onFieldSubmitted();
                    },
                  );
                },
                onSelected: (selection) {
                  if (!selectedMedicines.contains(selection)) {
                    setDialogState(() => selectedMedicines.add(selection));
                  }
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedMedicines
                    .map(
                      (medicine) => InputChip(
                        label: Text(medicine),
                        onDeleted: () {
                          setDialogState(
                              () => selectedMedicines.remove(medicine));
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Prescription notes',
                  hintText: 'Dose, timing, or pharmacy instructions',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (selectedMedicines.isEmpty) {
                AppSnackBar.showInfo(
                  context,
                  message: 'Add at least one medicine to prescribe.',
                );
                return;
              }

              ref.read(appSessionProvider.notifier).addPrescription(
                    Prescription(
                      patientName: patientName,
                      patientEmail: patientEmail,
                      prescribedByName: doctorName,
                      prescribedByEmail: doctorEmail,
                      medicines: List<String>.from(selectedMedicines),
                      note: noteController.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
              Navigator.of(context).pop();
              AppSnackBar.showSuccess(
                context,
                title: 'Prescription saved',
                message: 'Medicine list added for $patientName.',
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _PsychologistCard extends ConsumerWidget {
  final AppPsychologist psychologist;

  const _PsychologistCard({required this.psychologist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmoothCard(
      borderRadius: 18,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.72),
      borderColor: AppColors.neonViolet.withOpacity(0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.neonViolet,
            child: Icon(Icons.psychology_alt_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(psychologist.name, style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text(psychologist.specialty, style: AppTypography.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.neonViolet,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        psychologist.availability,
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(selectedTabProvider.notifier).state = 3;
                    },
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Book'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
