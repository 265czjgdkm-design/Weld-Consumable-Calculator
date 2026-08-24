import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weld_models.dart';
import 'signup_config.dart';

/// Talks to the Apps Script Web App backing account-based preset sync
/// (see Kod.gs `doGet`/`doPost` in the same project as the welcome-email
/// trigger). Presets are keyed by the account's email in a Google Sheet.
///
/// Requests intentionally avoid a `Content-Type: application/json` header:
/// setting one would turn the POST into a CORS-preflighted request, which
/// Apps Script's Web App endpoint doesn't handle. The `http` package's
/// default `text/plain` body content-type keeps this a CORS-simple request,
/// and Apps Script parses the JSON body regardless of the declared type.
class PresetSyncService {
  const PresetSyncService();

  Future<List<UserWeldPreset>> list(String email) async {
    final uri = Uri.parse(SignupConfig.presetApiUrl).replace(
      queryParameters: {'action': 'listPresets', 'email': email},
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    final body = _decode(response.body);
    if (body['ok'] != true) {
      throw Exception(body['error']?.toString() ?? 'Preset list failed.');
    }
    final presets = body['presets'];
    if (presets is! List) return const [];
    return presets
        .whereType<Map>()
        .map((item) => UserWeldPreset.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> save(String email, UserWeldPreset preset) async {
    final response = await http
        .post(
          Uri.parse(SignupConfig.presetApiUrl),
          body: jsonEncode({
            'action': 'save',
            'email': email,
            'preset': preset.toJson(),
          }),
        )
        .timeout(const Duration(seconds: 10));
    final body = _decode(response.body);
    if (body['ok'] != true) {
      throw Exception(body['error']?.toString() ?? 'Preset save failed.');
    }
  }

  Future<void> delete(String email, String presetId) async {
    final response = await http
        .post(
          Uri.parse(SignupConfig.presetApiUrl),
          body: jsonEncode({
            'action': 'delete',
            'email': email,
            'presetId': presetId,
          }),
        )
        .timeout(const Duration(seconds: 10));
    final body = _decode(response.body);
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
