import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weld_models.dart';

class UserPresetStore {
  const UserPresetStore();

  static const _storageKey = 'user_weld_presets_v1';

  /// [skippedCount] is how many local rows were dropped for being
  /// individually unreadable, mirroring `PresetSyncService.list`'s
  /// `skippedCount` (see finding #1 of the second reviewer pass) so a
  /// future caller can surface it the same way, even though no caller
  /// currently needs it.
  Future<({List<UserWeldPreset> presets, int skippedCount})> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return (presets: const <UserWeldPreset>[], skippedCount: 0);
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return (presets: const <UserWeldPreset>[], skippedCount: 0);
    }

    final presets = <UserWeldPreset>[];
    var skippedCount = 0;
    for (final item in decoded.whereType<Map>()) {
      try {
        presets.add(UserWeldPreset.fromJson(Map<String, dynamic>.from(item)));
      } catch (error) {
        skippedCount++;
        debugPrint('Skipping unreadable saved calculation row: $error');
      }
    }
    presets.sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
    return (presets: presets, skippedCount: skippedCount);
  }

  Future<void> save(List<UserWeldPreset> presets) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      presets.map((preset) => preset.toJson()).toList(),
    );
    await preferences.setString(_storageKey, payload);
  }
}
