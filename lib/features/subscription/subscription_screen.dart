import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/user_settings.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.plusPremium;

  Future<void> _processPayment() async {
    final locale = Platform.localeName.toLowerCase();
    final isCIS = locale.contains('kz') || locale.contains('ru') || locale.contains('uz');
    
    final urlString = isCIS 
      ? 'https://robokassa.com/checkout?plan=${_selectedPlan.name}'
      : 'https://checkout.stripe.com/pay?plan=${_selectedPlan.name}';
      
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch payment provider')),
        );
      }
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = ref.watch(settingsProvider).subscription;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Text('Unlock Premium', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Choose your plan',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upgrade your AIRings experience to take full control of your health data.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  _PlanCard(
                    plan: SubscriptionPlan.plusPremium,
                    isSelected: _selectedPlan == SubscriptionPlan.plusPremium,
                    isCurrent: currentPlan == SubscriptionPlan.plusPremium,
                    isRecommended: true,
                    onTap: () => setState(() => _selectedPlan = SubscriptionPlan.plusPremium),
                  ),
                  const SizedBox(height: 16),
                  _PlanCard(
                    plan: SubscriptionPlan.basic,
                    isSelected: _selectedPlan == SubscriptionPlan.basic,
                    isCurrent: currentPlan == SubscriptionPlan.basic,
                    isRecommended: false,
                    onTap: () => setState(() => _selectedPlan = SubscriptionPlan.basic),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Purchases restored successfully')),
                        );
                      },
                      child: const Text('Restore Purchase', style: TextStyle(color: Color(0xFF2E6BD6), fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6BD6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Continue with ${_selectedPlan.label}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      children: [
                        const TextSpan(text: 'By continuing, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(color: Color(0xFF2E6BD6)),
                          recognizer: TapGestureRecognizer()..onTap = () => _openLink('https://airings.ai/terms'),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(color: Color(0xFF2E6BD6)),
                          recognizer: TapGestureRecognizer()..onTap = () => _openLink('https://airings.ai/privacy'),
                        ),
                        const TextSpan(text: '.'),
                      ],
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
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.isCurrent,
    required this.isRecommended,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final bool isCurrent;
  final bool isRecommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E6BD6) : const Color(0xFF30363D),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.label,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.normal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Current Plan', style: TextStyle(color: AppColors.normal, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E6BD6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Recommended', style: TextStyle(color: Color(0xFF2E6BD6), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.price,
              style: const TextStyle(color: Color(0xFF2E6BD6), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 18, color: AppColors.normal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
