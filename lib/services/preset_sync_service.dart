import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/weld_models.dart';
import 'apps_script_http.dart';
import 'auth_service.dart';
import 'signup_config.dart';

/// Talks to the Apps Script Web App backing account-based preset sync
/// (see Kod.gs `doGet`/`doPost` in the same project as the welcome-email
/// trigger). Presets are keyed by the account's email in a Google Sheet.
///
/// Identity comes from the Firebase ID token sent with every call; the Apps
/// Script verifies it with Google and keys rows by the verified email. The
/// `email` parameters below are NOT sent -- a bare email is never trusted
/// (see docs/apps_script/Kod_auth.gs).
///
/// Requests intentionally avoid a `Content-Type: application/json` header:
/// setting one would turn the POST into a CORS-preflighted request, which
/// Apps Script's Web App endpoint doesn't handle. The `http` package's
/// default `text/plain` body content-type keeps this a CORS-simple request,
/// and Apps Script parses the JSON body regardless of the declared type.
class PresetSyncService {
  const PresetSyncService();

  /// [skippedCount] is how many rows were dropped for being individually
  /// unreadable (not transient network/parse failures on the whole
  /// response, which still throw) -- callers should surface this to the
  /// user rather than silently shrinking their saved list (see finding #3).
  Future<({List<UserWeldPreset> presets, int skippedCount})> list(
    String email,
  ) async {
    final idToken = await requireIdToken();
    final uri = Uri.parse(
      SignupConfig.presetApiUrl,
    ).replace(queryParameters: {'action': 'listPresets', 'idToken': idToken});
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    final body = _decode(response.body);
    throwIfSignInRequired(body);
    if (body['ok'] != true) {
      throw Exception(body['error']?.toString() ?? 'Preset list failed.');
    }
    final rawPresets = body['presets'];
    if (rawPresets is! List) {
      return (presets: const <UserWeldPreset>[], skippedCount: 0);
    }
    final presets = <UserWeldPreset>[];
    var skippedCount = 0;
    for (final item in rawPresets.whereType<Map>()) {
      try {
        presets.add(UserWeldPreset.fromJson(Map<String, dynamic>.from(item)));
      } catch (error) {
        skippedCount++;
        debugPrint('Skipping unreadable synced preset row: $error');
      }
    }
    return (presets: presets, skippedCount: skippedCount);
  }

  Future<void> save(String email, UserWeldPreset preset) async {
    final idToken = await requireIdToken();
    final response = await appsScriptPost(
      Uri.parse(SignupConfig.presetApiUrl),
      body: jsonEncode({
        'action': 'save',
        'idToken': idToken,
        'preset': preset.toJson(),
      }),
      timeout: const Duration(seconds: 10),
    );
    final body = _decode(response.body);
    throwIfSignInRequired(body);
    if (body['ok'] != true) {
      throw Exception(body['error']?.toString() ?? 'Preset save failed.');
    }
  }

  Future<void> delete(String email, String presetId) async {
    final idToken = await requireIdToken();
    final response = await appsScriptPost(
      Uri.parse(SignupConfig.presetApiUrl),
      body: jsonEncode({
        'action': 'delete',
        'idToken': idToken,
        'presetId': presetId,
      }),
      timeout: const Duration(seconds: 10),
    );
    final body = _decode(response.body);
    throwIfSignInRequired(body);
    if (body['ok'] != true) {
      throw Exception(body['error']?.toString() ?? 'Preset delete failed.');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) throw const FormatException('Unexpected response.');
    return Map<String, dynamic>.from(decoded);
  }
}
