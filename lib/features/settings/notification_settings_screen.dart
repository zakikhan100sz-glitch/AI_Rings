import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(settingsProvider).notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose how you receive alerts when your Risk Score exceeds your thresholds.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('In-app and device push when Risk Score > 70'),
            value: notifications.pushEnabled,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateNotifications(notifications.copyWith(pushEnabled: v)),
          ),
          SwitchListTile(
            title: const Text('Email'),
            subtitle: const Text('Summary and critical alerts to your email'),
            value: notifications.emailEnabled,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateNotifications(notifications.copyWith(emailEnabled: v)),
          ),
          SwitchListTile(
            title: const Text('SMS'),
            subtitle: const Text('Critical alerts only (>90 Risk Score)'),
            value: notifications.smsEnabled,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateNotifications(notifications.copyWith(smsEnabled: v)),
          ),
        ],
      ),
    );
  }
}
