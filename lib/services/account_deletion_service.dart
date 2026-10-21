import 'dart:convert';

import 'package:http/http.dart' as http;

import 'signup_config.dart';

/// Asks the Apps Script backend (same Web App as [PresetSyncService]) to
/// remove an email's signup row(s) and preset rows. See
/// docs/apps_script/delete_account.gs for the server side.
///
/// Throws on any failure -- network, non-JSON response, or `ok != true`
/// (including an older script that doesn't know the `deleteAccount` action
/// yet) -- so callers never report a deletion that wasn't confirmed.
class AccountDeletionService {
  const AccountDeletionService({this.client});

  /// Injectable for tests; defaults to the top-level `http` functions.
  final http.Client? client;

  Future<void> deleteAccount(String email) async {
    final response = await (client?.post ?? http.post)(
      Uri.parse(SignupConfig.presetApiUrl),
      body: jsonEncode({'action': 'deleteAccount', 'email': email}),
    ).timeout(const Duration(seconds: 20));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['ok'] != true) {
      throw Exception(
        decoded is Map
            ? decoded['error']?.toString() ?? 'Account deletion failed.'
            : 'Unexpected response.',
      );
    }
  }
}
