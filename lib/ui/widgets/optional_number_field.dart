import 'package:flutter/material.dart';

/// Result of parsing an optional numeric form field: empty input is valid
/// (`value: null, invalid: false`); a non-empty value that fails to parse
/// as a finite number is flagged via `invalid: true`.
typedef OptionalNumberParseResult = ({double? value, bool invalid});

/// Parses [text] as an optional decimal number, accepting both `.` and `,`
/// as the decimal separator. Shared by the custom base/filler material
/// forms so every optional numeric field (thickness, chemical composition,
/// CET/Pcm, density) validates the same way.
OptionalNumberParseResult parseOptionalNumberField(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return (value: null, invalid: false);
  }
  final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
  if (parsed == null || !parsed.isFinite) {
    return (value: null, invalid: true);
  }
  return (value: parsed, invalid: false);
}

/// A compact optional numeric text field, used for chemical composition,
/// sheet thickness, and CET/Pcm entries across the custom material forms.
class OptionalNumberField extends StatelessWidget {
  const OptionalNumberField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.width,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
    if (width == null) return field;
    return SizedBox(width: width, child: field);
  }
}
