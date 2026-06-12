import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/mock_data.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/airings_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: MockData.demoEmail);
  final _passwordController = TextEditingController(text: MockData.demoPassword);
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      final auth = ref.read(authProvider);
      if (auth.onboardingComplete) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const AiringsLogo(size: 56),
              const SizedBox(height: 32),
              Text(
                'Health monitoring &\nearly risk detection',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in to AIRings AI-Wellness to track your metrics and receive proactive health insights.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),
              _FeatureBullet(
                icon: Icons.monitor_heart_outlined,
                title: 'Continuous monitoring',
                subtitle: 'Track key health indicators 24/7 in real time.',
              ),
              const SizedBox(height: 12),
              _FeatureBullet(
                icon: Icons.auto_awesome_outlined,
                title: 'AI early warnings',
                subtitle: 'Detect risks before symptoms appear.',
              ),
              const SizedBox(height: 12),
              _FeatureBullet(
                icon: Icons.shield_outlined,
                title: 'Secure health data',
                subtitle: 'Protected according to medical security standards.',
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use demo credentials or any email with a 6+ character password.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(authProvider.notifier)
                                    .signInWithProvider('google');
                                if (!context.mounted) return;
                                context.go('/home');
                              },
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Sign in with Google'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(authProvider.notifier)
                                    .signInWithProvider('apple');
                                if (!context.mounted) return;
                                context.go('/home');
                              },
                        icon: const Icon(Icons.apple),
                        label: const Text('Sign in with Apple'),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Reset password'),
                                content: const Text(
                                  'Password reset will be available when the API is connected. '
                                  'For now, use demo@airings.ai / demo1234.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      if (auth.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          auth.error!,
                          style: const TextStyle(color: AppColors.risk),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final success = await ref
                                    .read(authProvider.notifier)
                                    .signIn(
                                      MockData.demoEmail,
                                      MockData.demoPassword,
                                    );
                                if (success && mounted) context.go('/home');
                              },
                        child: const Text('Demo Access'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
