import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  int _cycleCount = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _breathAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ));

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _cycleCount++);
        if (_cycleCount < 5) {
          _breathController.reverse();
        } else {
          setState(() => _isRunning = false);
          _cycleCount = 0;
        }
      } else if (status == AnimationStatus.dismissed) {
        _breathController.forward();
      }
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() => _isRunning = true);
    _breathController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '4-7-8 Breathing',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isRunning
                  ? (_breathController.status == AnimationStatus.forward
                      ? 'Inhale for 4 seconds'
                      : 'Exhale for 8 seconds')
                  : 'Tap to start',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _breathAnimation,
              builder: (context, child) {
                return Container(
                  width: 150 * _breathAnimation.value,
                  height: 150 * _breathAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonCyan.withOpacity(0.3),
                    border: Border.all(
                      color: AppColors.neonCyan,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.air,
                    size: 50,
                    color: AppColors.neonCyan,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            if (!_isRunning)
              ElevatedButton(
                onPressed: _startExercise,
                child: const Text('Start Breathing'),
              ),
            if (_isRunning)
              Text(
                'Cycle: ${_cycleCount + 1}/5',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
