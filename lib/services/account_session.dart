import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'entitlement_service.dart';
import 'preset_sync_service.dart';
import 'user_account_store.dart';
import 'user_preset_store.dart';
import 'user_preset_sync.dart';

/// Applies an auth state to the rest of the app: the email that keys cloud
/// presets ([UserAccountStore]) and the RevenueCat identity. Both are only
/// ever bound to a VERIFIED user, so an unverified registration can neither
/// read someone else's presets by typing their email nor share Premium.
class AccountSession {
  const AccountSession._();

  static Future<void> apply(
    AuthUser? user, {
    EntitlementService? entitlement,
    AuthService? auth,
    PresetSyncService presetSyncService = const PresetSyncService(),
    UserPresetStore presetStore = const UserPresetStore(),
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
      // Hanging/failed SDK calls must never hold up sign-in.
      unawaited(rc.syncAccount(user.revenueCatUserId));
      if (previous != email) {
        await _pullPresets(email, presetSyncService, presetStore);
      }
    } else {
      await accountStore.clear();
      unawaited(rc.syncAccount(null));
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
  /// the mail app), then apply.
  static Future<AuthUser?> restore({
    EntitlementService? entitlement,
    AuthService? auth,
  }) async {
    final service = auth ?? AuthServices.instance;
    var user = service.currentUser;
    if (user != null && !user.isVerified) {
      try {
        user = await service.reload() ?? user;
      } catch (_) {}
    }
    await apply(user, entitlement: entitlement, auth: service);
    return user;
  }
}
