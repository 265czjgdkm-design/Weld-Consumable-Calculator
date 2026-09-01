import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weld_models.dart';

class UserPresetStore {
  const UserPresetStore();

  static const _storageKey = 'user_weld_presets_v1';

  Future<List<UserWeldPreset>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final presets = <UserWeldPreset>[];
    for (final item in decoded.whereType<Map>()) {
      try {
        presets.add(UserWeldPreset.fromJson(Map<String, dynamic>.from(item)));
      } catch (error) {
        debugPrint('Skipping unreadable saved calculation row: $error');
      }
    }
    presets.sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
    return presets;
  }

  Future<void> save(List<UserWeldPreset> presets) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      presets.map((preset) => preset.toJson()).toList(),
    );
    await preferences.setString(_storageKey, payload);
  }
}
