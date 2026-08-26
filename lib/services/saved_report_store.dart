import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_report.dart';

class SavedReportStore {
  const SavedReportStore();

  static const _storageKey = 'saved_reports_v1';
  static const _maxStoredReports = 20;

  Future<List<SavedReport>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final reports = <SavedReport>[];
    for (final item in decoded.whereType<Map>()) {
      try {
        reports.add(SavedReport.fromJson(Map<String, dynamic>.from(item)));
      } catch (error) {
        debugPrint('Skipping unreadable saved report row: $error');
      }
    }
    reports.sort((a, b) => b.generatedAtEpochMs.compareTo(a.generatedAtEpochMs));
    return reports;
  }

  Future<void> save(List<SavedReport> reports) async {
    final preferences = await SharedPreferences.getInstance();
    final capped = reports.length <= _maxStoredReports
        ? reports
        : (List<SavedReport>.from(
            reports,
          )..sort((a, b) => b.generatedAtEpochMs.compareTo(a.generatedAtEpochMs)))
              .take(_maxStoredReports)
              .toList();
    final payload = jsonEncode(
      capped.map((report) => report.toJson()).toList(),
    );
    await preferences.setString(_storageKey, payload);
  }

  Future<void> add(SavedReport report) async {
    final reports = await load();
    await save([report, ...reports]);
  }
}
