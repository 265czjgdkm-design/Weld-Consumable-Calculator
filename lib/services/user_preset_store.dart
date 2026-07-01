import 'dart:convert';

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

    return decoded
        .whereType<Map>()
        .map((item) => UserWeldPreset.fromJson(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
  }

  Future<void> save(List<UserWeldPreset> presets) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      presets.map((preset) => preset.toJson()).toList(),
    );
    await preferences.setString(_storageKey, payload);
  }
}
