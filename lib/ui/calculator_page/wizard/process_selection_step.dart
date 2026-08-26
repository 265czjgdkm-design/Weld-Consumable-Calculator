import 'package:flutter/material.dart';

import '../../../models/weld_models.dart';
import 'process_icons.dart';

/// Step 1 of the mobile wizard: pick a welding process via a grid of
/// pictorial choice cards, with an optional preset-shortcut widget slotted
/// underneath, then continue.
class WizardProcessStep extends StatelessWidget {
  const WizardProcessStep({
    super.key,
    required this.selectedProcess,
    required this.onSelected,
    required this.onContinue,
    required this.presetShortcut,
  });

  final WeldingProcess selectedProcess;
  final ValueChanged<WeldingProcess> onSelected;
  final VoidCallback onContinue;
  final Widget presetShortcut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welding Process',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the process used for this weld. This sets the deposition defaults and filler options for the next steps.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final process in WeldingProcess.values)
              SizedBox(
                width: 154,
                child: _ProcessChoiceCard(
                  process: process,
                  selected: process == selectedProcess,
                  onTap: () => onSelected(process),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        presetShortcut,
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
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
    );
  }
}

class _ProcessChoiceCard extends StatelessWidget {
  const _ProcessChoiceCard({
    required this.process,
    required this.selected,
    required this.onTap,
  });

  final WeldingProcess process;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF12191B) : const Color(0xFFF1F5F7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF12191B)
                  : const Color(0xFFD6E0E6),
            ),
          ),
          child: Column(
            children: [
              ProcessIcon(
                process: process,
                size: 56,
                color: selected ? Colors.white : const Color(0xFF12191B),
              ),
              const SizedBox(height: 10),
              Text(
                process.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF29414D),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
