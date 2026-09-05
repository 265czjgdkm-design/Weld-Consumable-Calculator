import 'package:flutter/material.dart';

import '../../../l10n/app_locale_scope.dart';

/// Step 2 of the mobile wizard: technical drawing preview, joint type,
/// member geometry, groove type, and dimension fields. Pure presentation --
/// every section is pre-built by the caller in `calculator_page.dart`,
/// which owns all the underlying state.
class WizardDimensionsStep extends StatelessWidget {
  const WizardDimensionsStep({
    super.key,
    required this.drawingHeader,
    required this.starterPresetSection,
    required this.jointTypeSection,
    required this.memberGeometrySection,
    required this.grooveTypeDropdown,
    required this.primaryDimensionFields,
    required this.capDimensionFields,
    required this.initiallyExpandCapSection,
    required this.onBack,
    required this.onContinue,
  });

  final Widget drawingHeader;
  final Widget starterPresetSection;
  final Widget jointTypeSection;
  final Widget memberGeometrySection;
  final Widget grooveTypeDropdown;
  final List<Widget> primaryDimensionFields;
  final List<Widget> capDimensionFields;
  final bool initiallyExpandCapSection;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  Widget _buildFieldsContainer(List<Widget> fields) {
    return Container(
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
          for (final field in fields)
            SizedBox(width: double.infinity, child: field),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final groupTitleStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800);
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
                  strings.wizardJointDimensionsTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Text(strings.calcJointGeometryGroupTitle, style: groupTitleStyle),
                const SizedBox(height: 10),
                starterPresetSection,
                const SizedBox(height: 18),
                jointTypeSection,
                memberGeometrySection,
                const SizedBox(height: 18),
                grooveTypeDropdown,
                const SizedBox(height: 22),
                Text(strings.calcMainDimensionsGroupTitle, style: groupTitleStyle),
                const SizedBox(height: 10),
                _buildFieldsContainer(primaryDimensionFields),
                if (capDimensionFields.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: initiallyExpandCapSection,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(top: 10),
                      title: Text(
                        strings.calcCapDimensionsGroupTitle,
                        style: groupTitleStyle,
                      ),
                      children: [_buildFieldsContainer(capDimensionFields)],
                    ),
                  ),
                ],
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
                child: Text(strings.commonBack),
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
                child: Text(strings.commonContinue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
