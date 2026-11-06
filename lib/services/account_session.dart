import 'dart:async';

import 'package:flutter/foundation.dart';

import '../l10n/app_locale.dart';
import 'auth_service.dart';
import 'entitlement_service.dart';
import 'preset_sync_service.dart';
import 'signup_submitter.dart';
import 'user_account_store.dart';
import 'user_preset_store.dart';
import 'user_preset_sync.dart';

typedef WelcomeSender =
    Future<bool> Function(String email, {String? firstName, String? locale});

/// Applies an auth state to the rest of the app: the email that keys cloud
/// presets ([UserAccountStore]) and the RevenueCat identity. Both are only
/// ever bound to a VERIFIED user, so an unverified registration can neither
/// read someone else's presets by typing their email nor share Premium.
///
/// Every apply runs through one queue, so a sign-out right after launch can
/// never be overtaken by the earlier sign-in's RevenueCat call.
class AccountSession {
  const AccountSession._();

  static Future<void>? _storeQueue;
  static Future<void>? _rcQueue;

  /// Tests only: completes once every queued RevenueCat call has run.
  @visibleForTesting
  static Future<void> settled() async {
    try {
      await _rcQueue;
    } catch (_) {}
  }

  /// Tests only: a test that abandoned a hanging call must not block the next
  /// (and futures created in another test's fake-async zone must not be
  /// awaited).
  @visibleForTesting
  static void resetQueues() {
    _storeQueue = null;
    _rcQueue = null;
  }

  static Future<void> apply(
    AuthUser? user, {
    EntitlementService? entitlement,
    AuthService? auth,
    PresetSyncService presetSyncService = const PresetSyncService(),
    UserPresetStore presetStore = const UserPresetStore(),
    WelcomeSender sendWelcome = submitSignupEmail,
  }) {
    final previous = _storeQueue;
    final run = () async {
      try {
        await previous;
      } catch (_) {}
      await _apply(
        user,
        entitlement: entitlement,
        auth: auth,
        presetSyncService: presetSyncService,
        presetStore: presetStore,
        sendWelcome: sendWelcome,
      );
    }();
    _storeQueue = run;
    return run;
  }

  /// RevenueCat calls are chained in call order but never awaited by
  /// [apply]: a hanging SDK call must not hold up sign-in.
  static void _syncRevenueCat(EntitlementService rc, String? appUserId) {
    final previous = _rcQueue;
    _rcQueue = () async {
      try {
        await previous;
      } catch (_) {}
      await rc.syncAccount(appUserId);
    }();
  }

  static Future<void> _apply(
    AuthUser? user, {
    required EntitlementService? entitlement,
    required AuthService? auth,
    required PresetSyncService presetSyncService,
    required UserPresetStore presetStore,
    required WelcomeSender sendWelcome,
  }) async {
    final service = auth ?? AuthServices.instance;
    // Without an auth backend (no Firebase config bundled) the legacy local
    // identity is left untouched.
    if (!service.available) return;

    const accountStore = UserAccountStore();
    final rc = entitlement ?? EntitlementService();
    final email = user?.email;
    if (user != null && user.isVerified && email != null) {
      final previous = await accountStore.getEmail();
      await accountStore.setEmail(email);
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        await accountStore.setName(user.firstName, user.lastName);
      }
      _syncRevenueCat(rc, user.revenueCatUserId);
      if (previous != email) {
        await _pullPresets(email, presetSyncService, presetStore);
      }
      await _welcomeOnce(user, email, accountStore, sendWelcome);
    } else {
      await accountStore.clear();
      _syncRevenueCat(rc, null);
    }
  }

  /// The welcome mail goes out once per account, at the first VERIFIED
  /// sign-in (so unverified or mistyped addresses never get mail).
  static Future<void> _welcomeOnce(
    AuthUser user,
    String email,
    UserAccountStore store,
    WelcomeSender send,
  ) async {
    try {
      if (await store.wasWelcomed(user.uid)) return;
      final sent = await send(
        email,
        firstName: user.firstName.isEmpty ? null : user.firstName,
        locale: await AppLocale.storedCode(),
      );
      if (sent) await store.markWelcomed(user.uid);
    } catch (error) {
      debugPrint('Welcome mail trigger failed: $error');
    }
  }

  /// First verified sign-in on this device (this is also the migration path
  /// for v1.0 users who registered with the same email): upload local-only
  /// presets, then take the cloud list.
  static Future<void> _pullPresets(
    String email,
    PresetSyncService sync,
    UserPresetStore store,
  ) async {
    try {
      final migrated = await migrateLocalPresetsToAccount(
        email: email,
        presetSyncService: sync,
        userPresetStore: store,
      );
      if (migrated) {
        await loadSyncedUserPresets(
          email: email,
          presetSyncService: sync,
          userPresetStore: store,
        );
      }
    } catch (error) {
      debugPrint('Preset pull after sign-in failed: $error');
    }
  }

  /// App start: refresh an unverified user once (they may have verified in
  /// the mail app), remember a v1.0 email-only identity for the one-time
  /// "register with the same email" sheet, then apply.
  static Future<AuthUser?> restore({
    EntitlementService? entitlement,
    AuthService? auth,
    WelcomeSender sendWelcome = submitSignupEmail,
  }) async {
    final service = auth ?? AuthServices.instance;
    var user = service.currentUser;
    if (user != null && !user.isVerified) {
      try {
        user = await service.reload() ?? user;
      } catch (_) {}
    }
    if (user == null && service.available) {
      const store = UserAccountStore();
      final legacy = await store.getEmail();
      if (legacy != null) await store.setLegacyEmailPrompt(legacy);
    }
    await apply(
      user,
      entitlement: entitlement,
      auth: service,
      sendWelcome: sendWelcome,
    );
    return user;
  }
}
