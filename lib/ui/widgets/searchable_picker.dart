import 'package:flutter/material.dart';

import '../../l10n/app_locale_scope.dart';

/// One selectable row. [title] is the short primary label, [subtitle] the
/// longer secondary description; both ellipsize instead of overflowing.
class PickerOption<T> {
  const PickerOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.group,
  });

  final T value;
  final String title;
  final String? subtitle;
  final String? group;
}

/// Tap target that looks like the app's other form fields and opens
/// [showSearchablePicker]. Replaces `DropdownButtonFormField` for long
/// lists: a dropdown menu cannot search and is awkward to scroll on phones.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.helper,
  });

  final String label;
  final String title;
  final String? subtitle;
  final String? helper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 3,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF17303C),
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF607482)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable, searchable, keyboard-safe bottom sheet. Resolves to the
/// tapped [PickerOption] (so options whose value is `null` are
/// distinguishable from a dismissed sheet, which resolves to `null`).
Future<PickerOption<T>?> showSearchablePicker<T>(
  BuildContext context, {
  required String title,
  required List<PickerOption<T>> options,
  T? selected,
}) {
  return showModalBottomSheet<PickerOption<T>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) =>
        _PickerSheet<T>(title: title, options: options, selected: selected),
  );
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<PickerOption<T>> options;
  final T? selected;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  bool _matches(PickerOption<T> option) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    final haystack = [
      option.title,
      option.subtitle ?? '',
      option.group ?? '',
    ].join(' ').toLowerCase();
    return query.split(RegExp(r'\s+')).every(haystack.contains);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final filtered = widget.options.where(_matches).toList();
    final rows = <Object>[];
    String? lastGroup;
    for (final option in filtered) {
      if (option.group != null && option.group != lastGroup) {
        rows.add(option.group!);
        lastGroup = option.group;
      }
      rows.add(option);
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${filtered.length}',
                      style: const TextStyle(color: Color(0xFF607482)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  key: const ValueKey('picker-search'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: strings.pickerSearchHint,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? Center(child: Text(strings.pickerNoResults))
                    : ListView.builder(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: rows.length,
                        itemBuilder: (context, index) {
                          final row = rows[index];
                          if (row is String) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(
                                row,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F3040),
                                ),
                              ),
                            );
                          }
                          final option = row as PickerOption<T>;
                          final isSelected = option.value == widget.selected;
                          return ListTile(
                            dense: true,
                            selected: isSelected,
                            title: Text(
                              option.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: option.subtitle == null
                                ? null
                                : Text(
                                    option.subtitle!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            trailing: isSelected
                                ? const Icon(Icons.check)
                                : null,
                            onTap: () => Navigator.of(context).pop(option),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
