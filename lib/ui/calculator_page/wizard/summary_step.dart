import 'package:flutter/material.dart';

/// Step 4 of the mobile wizard: a recap of Process / Dimensions / Consumable
/// (each an "Edit" button away from its step), the active engineering basis
/// banner, and the final Calculate/Reset actions.
class WizardSummaryStep extends StatelessWidget {
  const WizardSummaryStep({
    super.key,
    required this.engineeringBasisBanner,
    required this.processSection,
    required this.dimensionsSection,
    required this.consumableSection,
    required this.onEditProcess,
    required this.onEditDimensions,
    required this.onEditConsumable,
    required this.onCalculate,
    required this.onReset,
    required this.onSaveAsPreset,
    required this.saveAsPresetBusy,
    required this.saveAsPresetLabel,
  });

  final Widget engineeringBasisBanner;
  final Widget processSection;
  final Widget dimensionsSection;
  final Widget consumableSection;
  final VoidCallback onEditProcess;
  final VoidCallback onEditDimensions;
  final VoidCallback onEditConsumable;
  final VoidCallback onCalculate;
  final VoidCallback onReset;
  final VoidCallback? onSaveAsPreset;
  final bool saveAsPresetBusy;
  final String saveAsPresetLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Calculate',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Confirm the setup below, then calculate. Edit any step to change it.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 16),
        engineeringBasisBanner,
        const SizedBox(height: 18),
        _RecapCard(
          title: 'Process',
          onEdit: onEditProcess,
          child: processSection,
        ),
        const SizedBox(height: 14),
        _RecapCard(
          title: 'Dimensions',
          onEdit: onEditDimensions,
          child: dimensionsSection,
        ),
        const SizedBox(height: 14),
        _RecapCard(
          title: 'Consumable',
          onEdit: onEditConsumable,
          child: consumableSection,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onSaveAsPreset,
            icon: saveAsPresetBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add_outlined),
            label: Text(saveAsPresetLabel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onCalculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calculate'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.title,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
