import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../models/saved_report.dart';
import '../services/pdf_report_exporter.dart';
import '../services/saved_report_store.dart';

/// List of PDF reports exported from the calculator, persisted locally
/// (SharedPreferences + base64-encoded bytes) so they can be re-shared or
/// deleted without recalculating anything.
class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({super.key});

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  static const _store = SavedReportStore();

  List<SavedReport> _reports = const [];
  bool _loading = true;
  String? _busyReportId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reports = await _store.load();
      if (!mounted) return;
      setState(() => _reports = reports);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _share(SavedReport report) async {
    setState(() => _busyReportId = report.id);
    try {
      await exportPdfReport(base64Decode(report.pdfBytesBase64), report.fileName);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                AppLocaleScope.stringsOf(context).savedReportsShareError,
              ),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _busyReportId = null);
      }
    }
  }

  Future<void> _delete(SavedReport report) async {
    final strings = AppLocaleScope.stringsOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.savedReportsDeleteConfirmTitle),
        content: Text(
          strings.savedReportsDeleteConfirmBody.replaceFirst(
            '{name}',
            report.fileName,
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

    final reports = _reports.where((item) => item.id != report.id).toList();
    await _store.save(reports);
    if (!mounted) return;
    setState(() => _reports = reports);
  }

  String _formatDate(int epochMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.savedReportsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  strings.savedReportsEmptyState,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF607482),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                final busy = _busyReportId == report.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text(
                      report.fileName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(_formatDate(report.generatedAtEpochMs)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: busy ? null : () => _share(report),
                          icon: busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.ios_share_outlined),
                          tooltip: strings.savedReportsShareButton,
                        ),
                        IconButton(
                          onPressed: busy ? null : () => _delete(report),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: strings.savedReportsDeleteButton,
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
