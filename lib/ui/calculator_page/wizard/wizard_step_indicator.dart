import 'package:flutter/material.dart';

/// Purely presentational row of segments showing wizard progress, plus a
/// "Step N of M" label. `currentIndex` is 0-based.
class WizardStepIndicator extends StatelessWidget {
  const WizardStepIndicator({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
  });

  final int currentIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < totalSteps; i++) ...[
              if (i != 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= currentIndex
                        ? const Color(0xFFFF6A35)
                        : const Color(0xFFD6E0E6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${currentIndex + 1} of $totalSteps',
          style: const TextStyle(
            color: Color(0xFF12191B),
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
