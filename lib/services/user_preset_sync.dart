import '../models/weld_models.dart';
import 'preset_sync_service.dart';
import 'user_preset_store.dart';

/// Fetches an account's synced presets and merges back in any local-cache
/// copies of rows the cloud response couldn't parse (see finding #1 of the
/// second reviewer pass), so a preset already known locally isn't lost.
///
/// The returned `skippedCount` is already adjusted for that recovery --
/// rows the merge successfully restored from the local cache are not
/// counted, so callers can show a "skipped" warning to the user using this
/// count directly without double-reporting a loss that didn't happen (see
/// finding #1 of the third reviewer pass).
Future<({List<UserWeldPreset> presets, int skippedCount})>
loadSyncedUserPresets({
  required String email,
  required PresetSyncService presetSyncService,
  required UserPresetStore userPresetStore,
}) async {
  List<UserWeldPreset> presets;
  var skippedCount = 0;
  try {
    final result = await presetSyncService.list(email);
    presets = result.presets;
    skippedCount = result.skippedCount;
    if (skippedCount > 0) {
      final localPresets = (await userPresetStore.load()).presets;
      final cloudIds = presets.map((preset) => preset.id).toSet();
      final recovered = [
        for (final local in localPresets)
          if (!cloudIds.contains(local.id)) local,
      ];
      presets = [...presets, ...recovered]
        ..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
      skippedCount = skippedCount - recovered.length;
      if (skippedCount < 0) skippedCount = 0;
    }
    await userPresetStore.save(presets);
    // The cache now authoritatively holds `email`'s cloud data (even if
    // empty), so it's safe to re-tag ownership to `email` regardless of
    // who owned it before this refresh.
    await userPresetStore.setOwnerEmail(email);
  } catch (_) {
    // A local cache tagged for a *different* account must never be served
    // as this account's fallback -- that would leak the previous account's
    // presets, and a subsequent edit/save would re-upload them under this
    // email (see finding #2, third reviewer pass).
    final ownerEmail = await userPresetStore.getOwnerEmail();
    presets = (ownerEmail != null && ownerEmail != email)
        ? const []
        : (await userPresetStore.load()).presets;
    // The local fallback above is already the untruncated cache, so a
    // stale skip count from `list()` must not be surfaced here (see
    // finding #6).
    skippedCount = 0;
  }
  return (presets: presets, skippedCount: skippedCount);
}

/// A device that already had local-only presets before accounts existed
/// shouldn't lose them the first time it signs in -- upload each one under
/// the new account so they show up alongside (or merge with) whatever that
/// email already has saved in the cloud. Must run before any cloud-
/// authoritative refresh (like [loadSyncedUserPresets]), which overwrites
/// the local cache with whatever the cloud returns.
///
/// The local cache is tagged with the email of whichever account it was
/// last synced under (see [UserPresetStore.getOwnerEmail]). If it's tagged
/// with a *different* account than the one signing in now, it must NOT be
/// uploaded here -- that would leak the previous account's presets into
/// this one's cloud data (e.g. Sign Out deliberately leaves local presets
/// in place, so signing in as someone else on the same device must not
/// treat them as this new account's own unsynced data). In that case
/// nothing is uploaded and the caller's subsequent cloud-authoritative
/// refresh is left to replace the local cache with the signing-in
/// account's real data.
///
/// Returns whether it's safe for the caller to proceed with that
/// cloud-authoritative refresh: true if nothing needed uploading (mismatched
/// owner) or every preset uploaded successfully, false if an upload was
/// attempted and any of it failed -- in that case the caller should skip
/// the refresh, since it would otherwise overwrite local data with a cloud
/// list that doesn't yet reflect the failed upload (see finding #2).
Future<bool> migrateLocalPresetsToAccount({
  required String email,
  required PresetSyncService presetSyncService,
  required UserPresetStore userPresetStore,
}) async {
  final ownerEmail = await userPresetStore.getOwnerEmail();
  if (ownerEmail != null && ownerEmail != email) {
    return true;
  }

  final localPresets = (await userPresetStore.load()).presets;
  var allUploaded = true;
  for (final preset in localPresets) {
    try {
      await presetSyncService.save(email, preset);
    } catch (_) {
      allUploaded = false;
    }
  }
  if (allUploaded) {
    await userPresetStore.setOwnerEmail(email);
  }
  return allUploaded;
}
