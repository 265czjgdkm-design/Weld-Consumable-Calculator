import 'package:flutter/material.dart';

/// Step 2 of the mobile wizard: technical drawing preview, joint type,
/// member geometry, groove type, and dimension fields. Pure presentation --
/// every section is pre-built by the caller in `calculator_page.dart`,
/// which owns all the underlying state.
class WizardDimensionsStep extends StatelessWidget {
  const WizardDimensionsStep({
    super.key,
    required this.drawingHeader,
    required this.jointTypeSection,
    required this.memberGeometrySection,
    required this.grooveTypeDropdown,
    required this.dimensionFields,
    required this.onBack,
    required this.onContinue,
  });

  final Widget drawingHeader;
  final Widget jointTypeSection;
  final Widget memberGeometrySection;
  final Widget grooveTypeDropdown;
  final List<Widget> dimensionFields;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        drawingHeader,
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Joint & Dimensions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                jointTypeSection,
                memberGeometrySection,
                const SizedBox(height: 18),
                grooveTypeDropdown,
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
                      for (final field in dimensionFields)
                        SizedBox(
                          width: double.infinity,
                          child: field,
                        ),
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
