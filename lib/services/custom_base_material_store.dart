import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_material_models.dart';

class CustomBaseMaterialStore {
  const CustomBaseMaterialStore();

  static const _storageKey = 'custom_base_materials_v1';

  Future<List<CustomBaseMaterial>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final materials = <CustomBaseMaterial>[];
    for (final item in decoded.whereType<Map>()) {
      try {
        materials.add(
          CustomBaseMaterial.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (error) {
        debugPrint('Skipping unreadable custom base material row: $error');
      }
    }
    materials.sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
    return materials;
  }

  Future<void> save(List<CustomBaseMaterial> materials) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      materials.map((material) => material.toJson()).toList(),
    );
    await preferences.setString(_storageKey, payload);
  }
}
