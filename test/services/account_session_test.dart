import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/account_session.dart';
import 'package:weld_consumable_calculator/services/auth_service.dart';
import 'package:weld_consumable_calculator/services/entitlement_service.dart';
import 'package:weld_consumable_calculator/services/user_account_store.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';

import '../support/fake_auth_service.dart';

class _RecordingEntitlement extends EntitlementService {
  final calls = <String?>[];

  @override
  Future<void> syncAccount(String? appUserId) async => calls.add(appUserId);
}

UserWeldPreset _preset(String id) => UserWeldPreset(
  id: id,
  name: id,
  updatedAtEpochMs: 1000,
  data: InputPreset.csPlateSingleVGmaw.data!,
);

Future<void> _apply(
  AuthUser? user,
  _RecordingEntitlement rc, {
  http.Client Function()? client,
}) => http.runWithClient(
  () => AccountSession.apply(user, entitlement: rc, auth: FakeAuthService()),
  client ??
      () => MockClient(
        (_) async =>
            http.Response(jsonEncode({'ok': true, 'presets': []}), 200),
      ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AuthUser.revenueCatUserId', () {
    test('verified email user and Apple user get their uid', () {
      expect(fakeUser(uid: 'a').revenueCatUserId, 'a');
      expect(
        fakeUser(
          uid: 'b',
          emailVerified: false,
          isApple: true,
        ).revenueCatUserId,
        'b',
      );
    });

    test('unverified email user gets none', () {
      expect(fakeUser(emailVerified: false).revenueCatUserId, isNull);
    });
  });

  group('RevenueCat logIn only for verified users', () {
    test(
      'verified user: logIn(uid) and email bound for cloud presets',
      () async {
        final rc = _RecordingEntitlement();
        await _apply(fakeUser(uid: 'uid-9', email: 'a@b.co'), rc);
        expect(rc.calls, ['uid-9']);
        expect(await const UserAccountStore().getEmail(), 'a@b.co');
      },
    );

    test(
      'unverified user: no logIn (logOut instead), no cloud email',
      () async {
        await const UserAccountStore().setEmail('legacy@b.co');
        final rc = _RecordingEntitlement();
        await _apply(fakeUser(uid: 'uid-9', emailVerified: false), rc);
        expect(rc.calls, [null]);
        expect(await const UserAccountStore().getEmail(), isNull);
      },
    );

    test('Apple user counts as verified', () async {
      final rc = _RecordingEntitlement();
      await _apply(
        fakeUser(uid: 'ap', emailVerified: false, isApple: true),
        rc,
      );
      expect(rc.calls, ['ap']);
    });

    test('signed out: logOut and legacy email cleared', () async {
      await const UserAccountStore().setEmail('legacy@b.co');
      final rc = _RecordingEntitlement();
      await _apply(null, rc);
      expect(rc.calls, [null]);
      expect(await const UserAccountStore().getEmail(), isNull);
    });

    test('no auth backend leaves the legacy identity alone', () async {
      await const UserAccountStore().setEmail('legacy@b.co');
      final rc = _RecordingEntitlement();
      await AccountSession.apply(
        null,
        entitlement: rc,
        auth: const UnavailableAuthService(),
      );
      expect(rc.calls, isEmpty);
      expect(await const UserAccountStore().getEmail(), 'legacy@b.co');
    });
  });

  group('preset migration on first verified sign-in', () {
    test(
      'registering with the legacy email brings the cloud presets back',
      () async {
        final cloud = _preset('cloud-1');
        await _apply(
          fakeUser(email: 'old@user.com'),
          _RecordingEntitlement(),
          client: () => MockClient((request) async {
            return http.Response(
              jsonEncode({
                'ok': true,
                'presets': [cloud.toJson()],
              }),
              200,
            );
          }),
        );
        final presets = (await const UserPresetStore().load()).presets;
        expect(presets.map((p) => p.id), ['cloud-1']);
      },
    );

    test('local presets are uploaded before the cloud refresh', () async {
      await const UserPresetStore().save([_preset('local-1')]);
      final actions = <String>[];
      await _apply(
        fakeUser(email: 'old@user.com'),
        _RecordingEntitlement(),
        client: () => MockClient((request) async {
          final body = request.body.isEmpty
              ? <String, dynamic>{}
              : jsonDecode(request.body) as Map<String, dynamic>;
          actions.add(
            request.method == 'GET'
                ? 'list'
                : body['action']?.toString() ?? '?',
          );
          return http.Response(jsonEncode({'ok': true, 'presets': []}), 200);
        }),
      );
      expect(actions, ['save', 'list']);
    });

    test(
      'a failed upload skips the refresh so local presets survive',
      () async {
        await const UserPresetStore().save([_preset('local-1')]);
        var listed = false;
        await _apply(
          fakeUser(email: 'old@user.com'),
          _RecordingEntitlement(),
          client: () => MockClient((request) async {
            if (request.method == 'GET') listed = true;
            return http.Response(jsonEncode({'ok': false, 'error': 'x'}), 200);
          }),
        );
        expect(listed, isFalse);
        expect((await const UserPresetStore().load()).presets, hasLength(1));
      },
    );

    test('an unchanged email does not re-pull on every launch', () async {
      await const UserAccountStore().setEmail('old@user.com');
      var requests = 0;
      await _apply(
        fakeUser(email: 'old@user.com'),
        _RecordingEntitlement(),
        client: () => MockClient((request) async {
          requests++;
          return http.Response(jsonEncode({'ok': true, 'presets': []}), 200);
        }),
      );
      expect(requests, 0);
    });
  });
}
