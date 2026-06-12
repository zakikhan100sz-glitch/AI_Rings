import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/providers.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class AiringsApp extends ConsumerWidget {
  const AiringsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'AIRings',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
