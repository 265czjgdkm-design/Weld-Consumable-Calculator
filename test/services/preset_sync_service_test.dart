import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/preset_sync_service.dart';

void main() {
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

  test('list() reports zero skipped rows when every row parses cleanly', () async {
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
  });
}
