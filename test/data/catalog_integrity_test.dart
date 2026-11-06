import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/data/base_material_catalog.dart';
import 'package:weld_consumable_calculator/data/consumable_catalog.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';

void main() {
  group('ConsumableCatalog', () {
    final entries = ConsumableCatalog.entries;

    test('has at least 100 entries with unique ids', () {
      expect(entries.length, greaterThanOrEqualTo(100));
      final ids = entries.map((e) => e.id).toSet();
      expect(ids.length, entries.length);
    });

    test('required fields are present and plausible', () {
      for (final e in entries) {
        expect(e.label.trim(), isNotEmpty, reason: e.id);
        expect(e.specification.trim(), isNotEmpty, reason: e.id);
        expect(e.description.trim(), isNotEmpty, reason: e.id);
        expect(e.processes, isNotEmpty, reason: e.id);
        expect(e.densityGPerCm3, inInclusiveRange(2.0, 9.5), reason: e.id);
        if (e.family == ConsumableFamily.aluminium) {
          expect(e.densityGPerCm3, lessThan(3.0), reason: e.id);
        } else {
          expect(e.densityGPerCm3, greaterThan(7.0), reason: e.id);
        }
      }
    });

    test('does not duplicate a built-in preset label', () {
      final builtIn = ConsumablePreset.values.map((p) => p.label).toSet();
      for (final e in entries) {
        expect(builtIn.contains(e.label), isFalse, reason: e.label);
      }
    });

    test(
      'every standard has a display position and every process is covered',
      () {
        for (final e in entries) {
          expect(
            ConsumableCatalog.groupOrder,
            contains(e.specification),
            reason: e.id,
          );
        }
        for (final process in WeldingProcess.values) {
          expect(ConsumableCatalog.forProcess(process), isNotEmpty);
        }
      },
    );

    test('filler snapshot keeps id, density and spec', () {
      final e = ConsumableCatalog.byId('catalog:aws_a5.1:e7016')!;
      final f = e.toFiller();
      expect(f.id, e.id);
      expect(f.awsSpecification, 'AWS A5.1');
      expect(f.densityGPerCm3, 7.85);
      expect(f.updatedAtEpochMs, 0);
    });
  });

  group('BaseMaterialCatalog', () {
    final entries = BaseMaterialCatalog.entries;

    test('has at least 50 entries with unique ids', () {
      expect(entries.length, greaterThanOrEqualTo(50));
      expect(entries.map((e) => e.id).toSet().length, entries.length);
    });

    test('required fields present, groups known, values in range', () {
      for (final e in entries) {
        expect(e.name.trim(), isNotEmpty);
        expect(e.standard.trim(), isNotEmpty);
        expect(e.description.trim(), isNotEmpty);
        expect(BaseMaterialCatalog.groupOrder, contains(e.group), reason: e.id);
        for (final v in [e.c, e.si, e.mn, e.cr, e.mo, e.ni, e.cu, e.v]) {
          if (v != null) expect(v, inInclusiveRange(0, 30), reason: e.id);
        }
      }
    });

    test('CET-ready materials have all six CET elements, none are guessed', () {
      final ready = BaseMaterialCatalog.cetReady;
      expect(ready, isNotEmpty);
      for (final e in ready) {
        for (final v in [e.c, e.mn, e.cr, e.mo, e.ni, e.cu]) {
          expect(v, isNotNull, reason: e.id);
        }
      }
      // Standards that do not limit Cr/Ni/Mo must stay out of the CET list.
      final s355j2 = entries.firstWhere((e) => e.name == 'S355J2');
      expect(s355j2.isCetReady, isFalse);
      final api = entries.firstWhere((e) => e.name == 'API 5L X52');
      expect(api.isCetReady, isFalse);
    });

    test('known spot values', () {
      final p355 = entries.firstWhere((e) => e.name == 'P355GH');
      expect((p355.c, p355.mn, p355.cu), (0.22, 1.70, 0.30));
      final a106b = entries.firstWhere((e) => e.name == 'A106 Gr B');
      expect((a106b.c, a106b.cr, a106b.mo), (0.30, 0.40, 0.15));
    });
  });
}
