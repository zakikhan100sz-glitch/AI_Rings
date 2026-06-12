import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = compact
        ? 'Informational only — not a medical device. Consult your physician.'
        : 'AIRings is not a certified Class II/III medical device and does '
            'not replace clinical diagnosis. All recommendations are '
            'informational and must be accompanied by physician consultation.';

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: compact ? 18 : 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                fontSize: compact ? 12 : 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
