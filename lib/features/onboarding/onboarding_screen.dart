import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/airings_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _ageController = TextEditingController(text: '34');
  final _heightController = TextEditingController(text: '168');
  final _weightController = TextEditingController(text: '62');
  String _gender = 'Female';
  DiabetesStatus _diabetesStatus = DiabetesStatus.none;
  final _medicationsController = TextEditingController();
  final _conditionsController = TextEditingController();

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.ring_volume_outlined,
      title: 'Wear your AIRings ring',
      body: 'Continuously collect pulse, HRV, SpO2, temperature, activity, and sleep data.',
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'AI-powered risk detection',
      body: 'Our engine identifies glucose instability patterns hours or days before symptoms.',
    ),
    _OnboardingSlide(
      icon: Icons.notifications_active_outlined,
      title: 'Proactive alerts',
      body: 'Receive personalized recommendations and doctor notifications when risk is critical.',
    ),
    _OnboardingSlide(
      icon: Icons.health_and_safety_outlined,
      title: '72-hour calibration',
      body: 'Wear the ring for 72 hours to establish your personalized baseline values.',
    ),
    _OnboardingSlide(
      icon: Icons.assignment_outlined,
      title: 'Medical profile',
      body: 'Help the AI understand your health context for more accurate insights.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final profile = user.copyWith(
      age: int.tryParse(_ageController.text) ?? user.age,
      gender: _gender,
      heightCm: double.tryParse(_heightController.text) ?? user.heightCm,
      weightKg: double.tryParse(_weightController.text) ?? user.weightKg,
      diabetesStatus: _diabetesStatus,
      medications: _medicationsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      chronicConditions: _conditionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    await ref.read(authProvider.notifier).completeOnboarding(profile);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const AiringsLogo(size: 36, showText: false),
                  const Spacer(),
                  Text(
                    '${_page + 1} / ${_slides.length}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  if (index == _slides.length - 1) {
                    return _MedicalQuestionnaire(
                      ageController: _ageController,
                      heightController: _heightController,
                      weightController: _weightController,
                      medicationsController: _medicationsController,
                      conditionsController: _conditionsController,
                      gender: _gender,
                      diabetesStatus: _diabetesStatus,
                      onGenderChanged: (v) => setState(() => _gender = v),
                      onDiabetesChanged: (v) =>
                          setState(() => _diabetesStatus = v),
                    );
                  }
                  return _slides[index];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(isLastPage ? 'Get Started' : 'Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: AppColors.accent),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalQuestionnaire extends StatelessWidget {
  const _MedicalQuestionnaire({
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.medicationsController,
    required this.conditionsController,
    required this.gender,
    required this.diabetesStatus,
    required this.onGenderChanged,
    required this.onDiabetesChanged,
  });

  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController medicationsController;
  final TextEditingController conditionsController;
  final String gender;
  final DiabetesStatus diabetesStatus;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<DiabetesStatus> onDiabetesChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical questionnaire',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This information helps personalize your risk baseline.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Female', 'Male', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => onGenderChanged(v ?? gender),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DiabetesStatus>(
            value: diabetesStatus,
            decoration: const InputDecoration(labelText: 'Diabetes status'),
            items: DiabetesStatus.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(_diabetesLabel(s)),
                  ),
                )
                .toList(),
            onChanged: (v) => onDiabetesChanged(v ?? diabetesStatus),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: medicationsController,
            decoration: const InputDecoration(
              labelText: 'Medications (comma-separated)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: conditionsController,
            decoration: const InputDecoration(
              labelText: 'Chronic conditions (comma-separated)',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _diabetesLabel(DiabetesStatus status) {
    switch (status) {
      case DiabetesStatus.none:
        return 'No diabetes';
      case DiabetesStatus.prediabetes:
        return 'Prediabetes';
      case DiabetesStatus.type1:
        return 'Type 1';
      case DiabetesStatus.type2:
        return 'Type 2';
    }
  }
}
