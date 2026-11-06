import 'package:flutter/material.dart';

import '../../l10n/strings.dart';

/// Scrolls [node]'s field into view and focuses it (opening the keyboard for
/// text fields). Runs after the next frame so a field that only just got
/// mounted (a wizard step swap, a mode switch) already has a context.
void revealAndFocus(FocusNode node) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final fieldContext = node.context;
    if (fieldContext == null || !fieldContext.mounted) return;
    await Scrollable.ensureVisible(
      fieldContext,
      alignment: 0.25,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    if (fieldContext.mounted) node.requestFocus();
  });
}

/// "2 fields missing: A, B" -- never a silent no-op on a failed Calculate.
void showMissingFieldsSnack(
  BuildContext context,
  L10nStrings strings,
  List<String> labels,
) {
  final shown = labels.take(3).join(', ');
  final fields = labels.length > 3 ? '$shown...' : shown;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          strings.calcMissingFieldsSnack
              .replaceFirst('{count}', '${labels.length}')
              .replaceFirst('{fields}', fields),
        ),
      ),
    );
}
