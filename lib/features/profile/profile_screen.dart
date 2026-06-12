import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/user_settings.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/medical_disclaimer.dart';
import '../../shared/widgets/section_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final settings = ref.watch(settingsProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Profile & settings',
              subtitle: 'Manage your account and health data',
            ),
            const SizedBox(height: 20),
            _ProfileHeader(user: user),
            const SizedBox(height: 24),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Edit medical profile',
              onTap: () => _showEditProfile(context, ref, user),
            ),
            _SettingsTile(
              icon: Icons.ring_volume_outlined,
              title: 'Manage connected devices',
              subtitle: 'Pair, sync, and view ring status',
              onTap: () => context.go('/device'),
            ),
            _SettingsTile(
              icon: Icons.medical_services_outlined,
              title: 'Linked doctor',
              subtitle: user.linkedDoctor ?? 'Not linked',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.local_hospital_outlined,
              title: 'Linked clinic',
              subtitle: user.linkedClinic ?? 'Not linked',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.card_membership_outlined,
              title: 'Subscription',
              subtitle: '${settings.subscription.label} — ${settings.subscription.price}',
              onTap: () => context.push('/subscription'),
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notification settings',
              subtitle: 'Push, Email, SMS',
              onTap: () => context.push('/notification-settings'),
            ),
            _SettingsTile(
              icon: Icons.tune_outlined,
              title: 'Alert thresholds',
              subtitle:
                  'Warning at ${settings.alertThresholds.warningScore}, critical at ${settings.alertThresholds.criticalScore}',
              onTap: () => context.push('/alert-thresholds'),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.dark_mode_outlined, color: AppColors.accent),
              title: const Text('Theme'),
              subtitle: Text(
                settings.themeMode == ThemeMode.dark ? 'Dark' : 'Light',
              ),
              trailing: Switch(
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (isDark) => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light),
              ),
            ),
            _SettingsTile(
              icon: Icons.download_outlined,
              title: 'Export all data',
              subtitle: 'GDPR data portability',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export started (mock).')),
                );
              },
            ),
            const SizedBox(height: 12),
            const MedicalDisclaimer(compact: true),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Delete account',
              titleColor: AppColors.risk,
              onTap: () => _confirmDelete(context, ref),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfile user,
  ) async {
    final nameController = TextEditingController(text: user.name);
    DiabetesStatus diabetes = user.diabetesStatus;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return DropdownButtonFormField<DiabetesStatus>(
                    initialValue: diabetes,
                    decoration: const InputDecoration(labelText: 'Diabetes status'),
                    items: DiabetesStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_diabetesLabel(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => diabetes = v ?? diabetes),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).updateProfile(
                        user.copyWith(
                          name: nameController.text.trim(),
                          diabetesStatus: diabetes,
                        ),
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This will permanently delete your account and all health data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.risk)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) context.go('/login');
    }
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
            CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.accent.withOpacity(0.15),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.age} yrs · ${user.gender} · ${user.diabetesLabel}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? AppColors.accent),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
