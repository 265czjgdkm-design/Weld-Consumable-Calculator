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
  } catch (_) {
    presets = (await userPresetStore.load()).presets;
    // The local fallback above is already the untruncated cache, so a
    // stale skip count from `list()` must not be surfaced here (see
    // finding #6).
    skippedCount = 0;
  }
  return (presets: presets, skippedCount: skippedCount);
}
