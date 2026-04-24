import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../app/home_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../app/user_preferences_provider.dart';
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
              _PrescriptionSection(session: session),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${prescription.medicines.join(', ')}\n${prescription.note}',
                      ),
                      if (prescription.reminderTimes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Reminders: ${prescription.reminderTimes.map((t) => t.toDisplayString()).join(', ')}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  isThreeLine: prescription.note.isNotEmpty ||
                      prescription.reminderTimes.isNotEmpty,
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
    final selectedTimes = <MedicationTime>[];
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
              Row(
                children: [
                  const Text('Reminder Times:'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final medicationTime = MedicationTime(
                          hour: time.hour,
                          minute: time.minute,
                        );
                        if (!selectedTimes.contains(medicationTime)) {
                          setDialogState(
                              () => selectedTimes.add(medicationTime));
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedTimes
                    .map(
                      (time) => InputChip(
                        label: Text(time.toDisplayString()),
                        onDeleted: () {
                          setDialogState(() => selectedTimes.remove(time));
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

              final prescription = Prescription(
                patientName: patientName,
                patientEmail: patientEmail,
                prescribedByName: doctorName,
                prescribedByEmail: doctorEmail,
                medicines: List<String>.from(selectedMedicines),
                reminderTimes: List<MedicationTime>.from(selectedTimes),
                note: noteController.text.trim(),
                createdAt: DateTime.now(),
              );

              ref
                  .read(appSessionProvider.notifier)
                  .addPrescription(prescription);

              // Schedule medication reminders
              if (selectedTimes.isNotEmpty) {
                final notificationService = NotificationService();
                notificationService.scheduleMedicationReminders(
                  medicines: selectedMedicines,
                  times: selectedTimes
                      .map((t) => (hour: t.hour, minute: t.minute))
                      .toList(),
                );
              }

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

class _PrescriptionSection extends ConsumerWidget {
  final AppSession session;

  const _PrescriptionSection({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = session.profile;
    final isPsychologist = profile?.role == UserRole.psychologist;
    final email = profile?.email?.toLowerCase() ?? '';
    final prescriptions = session.prescriptions.where((item) {
      if (isPsychologist) {
        return item.doctorEmail.toLowerCase() == email;
      }
      return profile?.email != null &&
          item.patientEmail.toLowerCase() == profile!.email!.toLowerCase();
    }).toList();
    final theme = Theme.of(context);

    return SmoothCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.78),
      borderColor: theme.colorScheme.primary.withOpacity(0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPsychologist ? 'Prescriptions' : 'Your prescriptions',
            style: AppTypography.headingSmall.copyWith(
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isPsychologist
                ? 'Set daily medication reminders for each patient at a fixed time.'
                : 'Medication reminders appear here when your psychologist assigns them.',
            style: AppTypography.bodySmall.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          if (prescriptions.isEmpty)
            SmoothCard(
              borderRadius: 18,
              padding: const EdgeInsets.all(16),
              backgroundColor: theme.colorScheme.surface.withOpacity(0.75),
              child: Row(
                children: [
                  Icon(
                    isPsychologist ? Icons.add_circle_outline : Icons.inbox,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isPsychologist
                          ? 'No prescriptions yet. Add one to schedule reminders for a patient.'
                          : 'No prescriptions found for your email yet.',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: prescriptions
                  .map(
                    (prescription) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PrescriptionCard(
                        prescription: prescription,
                        isPsychologist: isPsychologist,
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (isPsychologist) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add prescription'),
                onPressed: () {
                  _showPrescriptionForm(
                      context, ref, profile?.email ?? demoPsychologistEmail);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPrescriptionForm(
    BuildContext context,
    WidgetRef ref,
    String doctorEmail,
  ) {
    final medicationController = TextEditingController();
    final patientEmailController = TextEditingController();
    final instructionsController = TextEditingController();
    var selectedTime = const TimeOfDay(hour: 20, minute: 0);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Prescription',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: medicationController,
                  decoration: const InputDecoration(
                    labelText: 'Medication name',
                    hintText: 'e.g. Sertraline 50mg',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: patientEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Patient email',
                    hintText: 'patient@example.com',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: instructionsController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes / instructions',
                    hintText: 'Take with food, morning dose, etc.',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.schedule),
                        label: Text('Time: ${selectedTime.format(context)}'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final medication = medicationController.text.trim();
                      final patientEmail = patientEmailController.text.trim();
                      if (medication.isEmpty || !patientEmail.contains('@')) {
                        AppSnackBar.showError(
                          context,
                          title: 'Need more details',
                          message:
                              'Add a medication and a valid patient email.',
                        );
                        return;
                      }
                      final prescription = Prescription(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        medicationName: medication,
                        doctorEmail: doctorEmail,
                        patientEmail: patientEmail,
                        instructions: instructionsController.text.trim(),
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                      );
                      ref
                          .read(appSessionProvider.notifier)
                          .addPrescription(prescription);

                      if (ref
                          .read(userPreferencesProvider)
                          .medicationRemindersEnabled) {
                        NotificationService().scheduleMedicationReminders(
                          ref.read(appSessionProvider).prescriptions,
                        );
                      }

                      AppSnackBar.showSuccess(
                        context,
                        title: 'Prescription added',
                        message:
                            'Daily reminder scheduled for ${selectedTime.format(context)}.',
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save prescription'),
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

class _PrescriptionCard extends ConsumerWidget {
  final Prescription prescription;
  final bool isPsychologist;

  const _PrescriptionCard({
    required this.prescription,
    required this.isPsychologist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SmoothCard(
      borderRadius: 18,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.74),
      borderColor: theme.colorScheme.primary.withOpacity(0.18),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.medication, color: Colors.white),
        ),
        title:
            Text(prescription.medicationName, style: AppTypography.labelLarge),
        subtitle: Text(
          '${prescription.patientEmail.isNotEmpty ? '${isPsychologist ? 'Patient' : 'From'}: ${prescription.patientEmail}\n' : ''}'
          'Time: ${prescription.hour.toString().padLeft(2, '0')}:${prescription.minute.toString().padLeft(2, '0')}'
          '${prescription.instructions.isNotEmpty ? '\n${prescription.instructions}' : ''}',
          style: AppTypography.bodySmall,
        ),
        isThreeLine: prescription.instructions.isNotEmpty,
        trailing: isPsychologist
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  ref
                      .read(appSessionProvider.notifier)
                      .removePrescription(prescription.id);
                  NotificationService().scheduleMedicationReminders(
                    ref.read(appSessionProvider).prescriptions,
                  );
                },
              )
            : null,
      ),
    );
  }
}
