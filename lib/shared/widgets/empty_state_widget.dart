import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A reusable empty state widget for screens with no data.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  final IconData iconData;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 64,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  ctaLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
