import 'dart:convert';

import 'package:http/http.dart' as http;

import 'apps_script_http.dart';
import 'auth_service.dart';
import 'signup_config.dart';

/// Asks the Apps Script backend (same Web App as [PresetSyncService]) to
/// remove an email's signup row(s) and preset rows. See
/// docs/apps_script/Kod_auth.gs for the server side.
///
/// Throws on any failure -- network, non-JSON response, or `ok != true`
/// (including an older script that doesn't know the `deleteAccount` action
/// yet) -- so callers never report a deletion that wasn't confirmed.
class AccountDeletionService {
  const AccountDeletionService({this.client});

  /// Injectable for tests; defaults to the top-level `http` functions.
  final http.Client? client;

  /// The server derives the email from the (fresh) ID token, so only the
  /// signed-in, verified owner can delete -- never a bare email.
  Future<void> deleteAccount() async {
    final idToken = await requireIdToken(forceRefresh: true);
    final response = await appsScriptPost(
      Uri.parse(SignupConfig.presetApiUrl),
      body: jsonEncode({'action': 'deleteAccount', 'idToken': idToken}),
      client: client,
    );
    final decoded = jsonDecode(response.body);
    // An unverified account has no cloud data: nothing to delete.
    if (decoded is Map && decoded['error'] == 'email_not_verified') return;
    if (decoded is Map) throwIfSignInRequired(decoded);
    if (decoded is! Map || decoded['ok'] != true) {
      throw Exception(
        decoded is Map
            ? decoded['error']?.toString() ?? 'Account deletion failed.'
            : 'Unexpected response.',
      );
    }
  }
}
