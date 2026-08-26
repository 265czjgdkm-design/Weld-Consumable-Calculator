import 'package:flutter/material.dart';

/// Step 3 of the mobile wizard: consumable classification, rate basis, and
/// the remaining input fields not covered by the dimensions step (diameters,
/// manual rate fields, density, waste factor). Pure presentation, mirroring
/// [WizardDimensionsStep].
class WizardConsumableStep extends StatelessWidget {
  const WizardConsumableStep({
    super.key,
    required this.consumableClassificationDropdown,
    required this.rateBasisSection,
    required this.consumableFields,
    required this.onBack,
    required this.onContinue,
  });

  final Widget consumableClassificationDropdown;
  final Widget rateBasisSection;
  final List<Widget> consumableFields;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consumable & Rate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                consumableClassificationDropdown,
                const SizedBox(height: 14),
                rateBasisSection,
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFF7FBFD),
                    border: Border.all(color: const Color(0xFFDCE5EB)),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final field in consumableFields)
                        SizedBox(width: double.infinity, child: field),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
