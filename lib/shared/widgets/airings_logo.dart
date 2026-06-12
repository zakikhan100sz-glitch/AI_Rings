import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AiringsLogo extends StatelessWidget {
  const AiringsLogo({
    super.key,
    this.size = 48,
    this.showText = true,
  });

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 3),
          ),
          child: Center(
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AIRings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.appTextPrimary,
                    ),
              ),
              const Text(
                'AI-Wellness',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
