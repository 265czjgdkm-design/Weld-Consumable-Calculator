import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/preset_sync_service.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';
import 'package:weld_consumable_calculator/services/user_preset_sync.dart';

void main() {
  const presetSyncService = PresetSyncService();
  const userPresetStore = UserPresetStore();

  UserWeldPreset preset(String id, String name) => UserWeldPreset(
    id: id,
    name: name,
    updatedAtEpochMs: 1000,
    data: InputPreset.csPlateSingleVGmaw.data!,
  );

  test(
    'migrateLocalPresetsToAccount uploads a genuinely guest-created local '
    'cache (no owner tag) into the first account that signs in -- the '
    'original bug this helper was written to fix',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_weld_presets_v1': jsonEncode([
          preset('guest-1', 'Guest Preset').toJson(),
        ]),
      });

      final savedUnderEmail = <String, List<String>>{};
      final migrated = await http.runWithClient(
        () => migrateLocalPresetsToAccount(
          email: 'first@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        () => MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final email = body['email'] as String;
          savedUnderEmail
              .putIfAbsent(email, () => [])
              .add((body['preset'] as Map<String, dynamic>)['id'] as String);
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      expect(migrated, isTrue);
      expect(savedUnderEmail['first@example.com'], ['guest-1']);
      expect(await userPresetStore.getOwnerEmail(), 'first@example.com');
    },
  );

  test(
    'migrateLocalPresetsToAccount does NOT upload a local cache tagged to '
    'a different, previously signed-in account (reviewer finding #1: '
    'alice signs in, signs out -- her local presets stay on the device -- '
    'then bob signs in and must not get alice\'s preset uploaded to his '
    'cloud account)',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_weld_presets_v1': jsonEncode([
          preset('alice-1', 'Alice Confidential Joint').toJson(),
        ]),
      });
      // Simulates alice having already signed in on this device (which is
      // what tags the local cache as hers) before signing out and leaving
      // her local presets in place, per the Sign Out contract.
      await userPresetStore.setOwnerEmail('alice@example.com');

      var saveCalled = false;
      final migrated = await http.runWithClient(
        () => migrateLocalPresetsToAccount(
          email: 'bob@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        () => MockClient((request) async {
          saveCalled = true;
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      expect(migrated, isTrue);
      expect(
        saveCalled,
        isFalse,
        reason: "alice's preset must never be uploaded to bob's account",
      );
      // Ownership stays alice's -- it's the caller's subsequent
      // cloud-authoritative refresh (loadSyncedUserPresets) that re-tags
      // the cache once bob's real cloud data replaces it.
      expect(await userPresetStore.getOwnerEmail(), 'alice@example.com');
    },
  );

  test(
    'migrateLocalPresetsToAccount uploads again for the SAME returning '
    'account (owner tag matches the email signing in)',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_weld_presets_v1': jsonEncode([
          preset('alice-1', 'Alice Preset').toJson(),
        ]),
      });
      await userPresetStore.setOwnerEmail('alice@example.com');

      var saveCalled = false;
      final migrated = await http.runWithClient(
        () => migrateLocalPresetsToAccount(
          email: 'alice@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        () => MockClient((request) async {
          saveCalled = true;
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      expect(migrated, isTrue);
      expect(saveCalled, isTrue);
    },
  );

  test(
    'migrateLocalPresetsToAccount returns false when an upload fails, so '
    'the caller can skip the cloud-authoritative refresh instead of '
    'wiping local data with a stale cloud list (reviewer finding #2)',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_weld_presets_v1': jsonEncode([
          preset('local-1', 'Local Preset').toJson(),
        ]),
      });

      final migrated = await http.runWithClient(
        () => migrateLocalPresetsToAccount(
          email: 'existing@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        // The write side is down -- e.g. quota exceeded or a revoked
        // write permission -- even though reads would still succeed.
        () => MockClient((request) async => http.Response('Internal error', 500)),
      );

      expect(migrated, isFalse);
      // Ownership must not be claimed for an account whose upload failed.
      expect(await userPresetStore.getOwnerEmail(), isNull);

      final survivingPresets = (await userPresetStore.load()).presets;
      expect(survivingPresets, hasLength(1));
      expect(survivingPresets.single.id, 'local-1');
    },
  );

  test(
    'A failed migration followed by skipping loadSyncedUserPresets leaves '
    'local presets untouched, matching the caller contract in '
    'account_screen.dart and calculator_page.dart (reviewer finding #2)',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_weld_presets_v1': jsonEncode([
          preset('local-1', 'Local Preset').toJson(),
        ]),
      });

      var listWasCalled = false;
      await http.runWithClient(
        () async {
          final migrated = await migrateLocalPresetsToAccount(
            email: 'existing@example.com',
            presetSyncService: presetSyncService,
            userPresetStore: userPresetStore,
          );
          expect(migrated, isFalse);
          if (migrated) {
            await loadSyncedUserPresets(
              email: 'existing@example.com',
              presetSyncService: presetSyncService,
              userPresetStore: userPresetStore,
            );
          }
        },
        () => MockClient((request) async {
          if (request.method == 'GET') {
            listWasCalled = true;
            return http.Response(
              jsonEncode({'ok': true, 'presets': []}),
              200,
            );
          }
          return http.Response('Internal error', 500);
        }),
      );

      expect(
        listWasCalled,
        isFalse,
        reason:
            'the cloud-authoritative refresh must be skipped entirely '
            'after a failed migration upload',
      );
      final survivingPresets = (await userPresetStore.load()).presets;
      expect(survivingPresets, hasLength(1));
      expect(survivingPresets.single.id, 'local-1');
    },
  );

  test(
    "loadSyncedUserPresets' offline fallback does NOT serve a local cache "
    "tagged to a different account when the cloud list() call throws "
    '(reviewer finding #2, MEDIUM: bob signs in while offline/backend-down '
    "and must not see -- or later re-upload -- alice's leftover cache)",
    () async {
      SharedPreferences.setMockInitialValues({
        'user_weld_presets_v1': jsonEncode([
          preset('alice-1', 'Alice Confidential Joint').toJson(),
        ]),
      });
      await userPresetStore.setOwnerEmail('alice@example.com');

      final result = await http.runWithClient(
        () => loadSyncedUserPresets(
          email: 'bob@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        () => MockClient((request) async => http.Response('Backend down', 500)),
      );

      expect(
        result.presets,
        isEmpty,
        reason: "alice's cache must not be served to bob",
      );

      // A subsequent local save (e.g. bob creating his own preset while
      // still offline) must not carry alice's preset forward either.
      await userPresetStore.save(result.presets);
      final localAfterSave = (await userPresetStore.load()).presets;
      expect(localAfterSave, isEmpty);
    },
  );

  test(
    "loadSyncedUserPresets' offline fallback still serves the local cache "
    'when its owner tag matches the account being loaded for, or is unset '
    '(genuinely unowned/guest cache)',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_weld_presets_v1': jsonEncode([
          preset('alice-1', 'Alice Preset').toJson(),
        ]),
      });
      await userPresetStore.setOwnerEmail('alice@example.com');

      final matchingOwnerResult = await http.runWithClient(
        () => loadSyncedUserPresets(
          email: 'alice@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        () => MockClient((request) async => http.Response('Backend down', 500)),
      );
      expect(matchingOwnerResult.presets.map((p) => p.id), ['alice-1']);

      await userPresetStore.setOwnerEmail(null);
      final unownedResult = await http.runWithClient(
        () => loadSyncedUserPresets(
          email: 'anyone@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        () => MockClient((request) async => http.Response('Backend down', 500)),
      );
      expect(unownedResult.presets.map((p) => p.id), ['alice-1']);
    },
  );

  test(
    'loadSyncedUserPresets re-tags ownership to the account whose cloud '
    'data was just loaded, so a returning same-user sign-in still '
    'migrates/matches correctly next time',
    () async {
      SharedPreferences.setMockInitialValues({});

      await http.runWithClient(
        () => loadSyncedUserPresets(
          email: 'alice@example.com',
          presetSyncService: presetSyncService,
          userPresetStore: userPresetStore,
        ),
        () => MockClient(
          (request) async =>
              http.Response(jsonEncode({'ok': true, 'presets': []}), 200),
        ),
      );

      expect(await userPresetStore.getOwnerEmail(), 'alice@example.com');
    },
  );
}
