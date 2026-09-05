import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weld_models.dart';

class UserPresetStore {
  const UserPresetStore();

  static const _storageKey = 'user_weld_presets_v1';

  /// Which account's data the local cache above currently holds -- unset
  /// (null) means the cache is either genuinely guest-created (never
  /// synced under any account) or predates this key, both of which are
  /// safe to migrate to whichever account signs in first. See
  /// `migrateLocalPresetsToAccount` in user_preset_sync.dart, the only
  /// place this distinction matters: it must never upload one account's
  /// local cache into a *different* account's cloud data.
  static const _ownerEmailKey = 'user_weld_presets_owner_email_v1';

  Future<String?> getOwnerEmail() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(_ownerEmailKey);
    return (email == null || email.isEmpty) ? null : email;
  }

  Future<void> setOwnerEmail(String? email) async {
    final preferences = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await preferences.remove(_ownerEmailKey);
    } else {
      await preferences.setString(_ownerEmailKey, email);
    }
  }

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
