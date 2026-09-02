import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../models/consumable_selection.dart';
import '../models/weld_models.dart';
import '../services/preset_sync_service.dart';
import '../services/user_account_store.dart';
import '../services/user_preset_store.dart';
import '../services/user_preset_sync.dart';
import 'calculator_page.dart';

/// List of the user's saved calculator presets (account-based, synced via
/// [PresetSyncService]). Replaces the calculator's old inline "Preset
/// Workspace" / "My Saved Presets" section -- browsing, loading, renaming,
/// and deleting saved presets all happen here now instead.
class SavedCalculationsScreen extends StatefulWidget {
  const SavedCalculationsScreen({super.key});

  @override
  State<SavedCalculationsScreen> createState() =>
      _SavedCalculationsScreenState();
}

class _SavedCalculationsScreenState extends State<SavedCalculationsScreen> {
  static const _accountStore = UserAccountStore();
  static const _presetStore = UserPresetStore();
  static const _presetSyncService = PresetSyncService();

  List<UserWeldPreset> _presets = const [];
  String? _accountEmail;
  bool _loading = true;
  String? _busyPresetId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final email = await _accountStore.getEmail();
    _accountEmail = email;

    if (email == null) {
      if (!mounted) return;
      setState(() {
        _presets = const [];
        _loading = false;
      });
      return;
    }

    final result = await loadSyncedUserPresets(
      email: email,
      presetSyncService: _presetSyncService,
      userPresetStore: _presetStore,
    );
    final presets = result.presets;
    final skippedCount = result.skippedCount;

    if (!mounted) return;
    setState(() {
      _presets = presets;
      _loading = false;
    });
    if (skippedCount > 0) {
      final strings = AppLocaleScope.stringsOf(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              strings.savedCalculationsSkippedWarning.replaceFirst(
                '{count}',
                '$skippedCount',
              ),
            ),
          ),
        );
    }
  }

  Future<void> _openInCalculator(UserWeldPreset preset) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalculatorPage(presetToLoad: preset),
      ),
    );
    if (!mounted) return;
    _load();
  }

  Future<void> _rename(UserWeldPreset preset) async {
    final strings = AppLocaleScope.stringsOf(context);
    final email = _accountEmail;
    if (email == null) return;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => _RenamePresetDialog(initialValue: preset.name),
    );
    if (name == null || name.trim().isEmpty) return;

    setState(() => _busyPresetId = preset.id);
    try {
      final updated = preset.copyWith(
        name: name.trim(),
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
      await _presetSyncService.save(email, updated);
      final presets =
          _presets
              .map((item) => item.id == updated.id ? updated : item)
              .toList()
            ..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
      await _presetStore.save(presets);
      if (!mounted) return;
      setState(() => _presets = presets);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.savedCalculationsRenameError)),
        );
    } finally {
      if (mounted) {
        setState(() => _busyPresetId = null);
      }
    }
  }

  Future<void> _delete(UserWeldPreset preset) async {
    final strings = AppLocaleScope.stringsOf(context);
    final email = _accountEmail;
    if (email == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.savedCalculationsDeleteConfirmTitle),
        content: Text(
          strings.savedCalculationsDeleteConfirmBody.replaceFirst(
            '{name}',
            preset.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busyPresetId = preset.id);
    try {
      await _presetSyncService.delete(email, preset.id);
      final presets = _presets.where((item) => item.id != preset.id).toList();
      await _presetStore.save(presets);
      if (!mounted) return;
      setState(() => _presets = presets);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.savedCalculationsDeleteError)),
        );
    } finally {
      if (mounted) {
        setState(() => _busyPresetId = null);
      }
    }
  }

  String _summaryLine(L10nStrings strings, UserWeldPreset preset) {
    final data = preset.data;
    return '${data.jointType.labelFor(strings)} · ${data.grooveType.labelFor(strings)} · ${data.weldingProcess.label} · ${data.consumableSelection.label}';
  }

  String _formatDate(int epochMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final isGuest = _accountEmail == null;

    return Scaffold(
      appBar: AppBar(title: Text(strings.savedCalculationsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (isGuest || _presets.isEmpty)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  isGuest
                      ? strings.savedCalculationsGuestState
                      : strings.savedCalculationsEmptyState,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF607482),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final busy = _busyPresetId == preset.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _summaryLine(strings, preset),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF607482)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(preset.updatedAtEpochMs),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF8FA0AA)),
                              ),
                              const SizedBox(height: 10),
                              FilledButton.tonalIcon(
                                onPressed: busy
                                    ? null
                                    : () => _openInCalculator(preset),
                                icon: const Icon(
                                  Icons.launch_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  strings.savedCalculationsLoadButton,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: busy ? null : () => _rename(preset),
                              icon: busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.edit_outlined),
                              tooltip: strings.commonEdit,
                            ),
                            IconButton(
                              onPressed: busy ? null : () => _delete(preset),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: strings.commonDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Asks for a new name for an already-saved preset. A dedicated
/// StatefulWidget owning its own [TextEditingController], disposed by the
/// framework at the right point in the dialog route's own teardown -- see
/// the equivalent note in `calculator_page.dart`'s `_PresetNameDialog` for
/// why disposing it in the caller right after `showDialog` returns crashes
/// Flutter web with a "used after being disposed" assertion.
class _RenamePresetDialog extends StatefulWidget {
  const _RenamePresetDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_RenamePresetDialog> createState() => _RenamePresetDialogState();
}

class _RenamePresetDialogState extends State<_RenamePresetDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return AlertDialog(
      title: Text(strings.savedCalculationsRenameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: strings.savedCalculationsRenameFieldLabel,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(strings.commonSave)),
      ],
    );
  }
}
