import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/account_deletion_service.dart';
import 'package:weld_consumable_calculator/services/apps_script_http.dart';
import 'package:weld_consumable_calculator/services/preset_sync_service.dart';

const _redirectTarget = 'https://script.googleusercontent.com/macros/echo?x=1';

/// Mimics Apps Script on dart:io: POST answers 302 + Location (an HTML body
/// that is not JSON), and only a GET to the Location returns the JSON.
MockClient _redirectingClient(
  List<String> log, {
  String json = '{"ok":true}',
}) => MockClient((request) async {
  log.add('${request.method} ${request.url}');
  if (request.method == 'POST') {
    return http.Response(
      '<HTML>Moved</HTML>',
      302,
      headers: {'location': _redirectTarget},
    );
  }
  return http.Response(json, 200);
});

void main() {
  test('appsScriptPost follows a 302 by GET-ing the Location', () async {
    final log = <String>[];
    final response = await appsScriptPost(
      Uri.parse('https://script.google.com/macros/s/x/exec'),
      body: '{}',
      client: _redirectingClient(log),
    );
    expect(response.statusCode, 200);
    expect(jsonDecode(response.body), {'ok': true});
    expect(log, [
      'POST https://script.google.com/macros/s/x/exec',
      'GET $_redirectTarget',
    ]);
  });

  test('appsScriptPost returns a non-redirect response untouched', () async {
    final response = await appsScriptPost(
      Uri.parse('https://script.google.com/macros/s/x/exec'),
      body: '{}',
      client: MockClient((_) async => http.Response('{"ok":true}', 200)),
    );
    expect(response.body, '{"ok":true}');
  });

  test('appsScriptPost throws on a redirect without Location', () async {
    expect(
      appsScriptPost(
        Uri.parse('https://script.google.com/macros/s/x/exec'),
        body: '{}',
        client: MockClient((_) async => http.Response('', 302)),
      ),
      throwsFormatException,
    );
  });

  test('AccountDeletionService succeeds through a 302', () async {
    final log = <String>[];
    await AccountDeletionService(
      client: _redirectingClient(log),
    ).deleteAccount('a@b.co');
    expect(log.last, 'GET $_redirectTarget');
  });

  test(
    'AccountDeletionService fails when the redirected JSON is ok:false',
    () async {
      final log = <String>[];
      expect(
        AccountDeletionService(
          client: _redirectingClient(log, json: '{"ok":false,"error":"x"}'),
        ).deleteAccount('a@b.co'),
        throwsException,
      );
    },
  );

  test('PresetSyncService save and delete succeed through a 302', () async {
    final log = <String>[];
    await http.runWithClient(() async {
      const service = PresetSyncService();
      await service.delete('a@b.co', 'p1');
      await service.save(
        'a@b.co',
        UserWeldPreset(
          id: 'p1',
          name: 'n',
          updatedAtEpochMs: 1,
          data: InputPreset.csPlateSingleVGmaw.data!,
        ),
      );
    }, () => _redirectingClient(log));
    expect(log.where((l) => l.startsWith('GET ')).length, 2);
  });
}
