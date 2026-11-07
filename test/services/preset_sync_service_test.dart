import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/preset_sync_service.dart';
import 'package:weld_consumable_calculator/services/auth_service.dart';

import '../support/fake_auth_service.dart';

void main() {
  setUp(() => AuthServices.instance = FakeAuthService(user: fakeUser()));
  tearDown(() => AuthServices.instance = const UnavailableAuthService());

  const service = PresetSyncService();

  test(
    'list() reports how many rows were skipped instead of only debugPrint-ing '
    '(see finding #3) so callers can surface it rather than silently '
    'shrinking the local cache',
    () async {
      final validPreset = UserWeldPreset(
        id: 'preset-1',
        name: 'Valid',
        updatedAtEpochMs: 1,
        data: InputPreset.csPlateSingleVGmaw.data!,
      );
      final responseBody = jsonEncode({
        'ok': true,
        'presets': [
          validPreset.toJson(),
          // Missing the required 'id'/'data' fields -- an individually
          // unreadable row, not a whole-response failure.
          {'name': 'Malformed row with no id or data'},
        ],
      });

      final result = await http.runWithClient(
        () => service.list('test@example.com'),
        () => MockClient((request) async => http.Response(responseBody, 200)),
      );

      expect(result.presets, hasLength(1));
      expect(result.presets.single.id, 'preset-1');
      expect(result.skippedCount, 1);
    },
  );

  test(
    'list() reports zero skipped rows when every row parses cleanly',
    () async {
      final validPreset = UserWeldPreset(
        id: 'preset-1',
        name: 'Valid',
        updatedAtEpochMs: 1,
        data: InputPreset.csPlateSingleVGmaw.data!,
      );
      final responseBody = jsonEncode({
        'ok': true,
        'presets': [validPreset.toJson()],
      });

      final result = await http.runWithClient(
        () => service.list('test@example.com'),
        () => MockClient((request) async => http.Response(responseBody, 200)),
      );

      expect(result.presets, hasLength(1));
      expect(result.skippedCount, 0);
    },
  );
  test('list/save/delete POST the Kod_auth.gs contract: action + idToken in a '
      'JSON body, never a bare email or a URL query', () async {
    final preset = UserWeldPreset(
      id: 'preset-1',
      name: 'Valid',
      updatedAtEpochMs: 1,
      data: InputPreset.csPlateSingleVGmaw.data!,
    );
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(jsonEncode({'ok': true, 'presets': []}), 200);
    });

    await http.runWithClient(() async {
      await service.list('test@example.com');
      await service.save('test@example.com', preset);
      await service.delete('test@example.com', 'preset-1');
    }, () => client);

    expect(requests, hasLength(3));
    final bodies = [
      for (final request in requests)
        jsonDecode(request.body) as Map<String, dynamic>,
    ];
    for (final request in requests) {
      expect(request.method, 'POST');
      expect(request.url.query, isEmpty);
    }
    expect(bodies.map((b) => b['action']), ['listPresets', 'save', 'delete']);
    for (final body in bodies) {
      expect(body['idToken'], isA<String>());
      expect((body['idToken'] as String).isNotEmpty, isTrue);
      expect(body.containsKey('email'), isFalse);
    }
    expect((bodies[1]['preset'] as Map)['id'], 'preset-1');
    expect(bodies[2]['presetId'], 'preset-1');
  });
}
