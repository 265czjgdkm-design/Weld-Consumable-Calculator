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

    test('every standard has a display position', () {
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
    });

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

    test(
      'CET-applicable materials: unlimited elements are exactly the nulls',
      () {
        final applicable = BaseMaterialCatalog.cetApplicable;
        expect(applicable.length, greaterThan(40));
        for (final e in applicable) {
          expect(e.c, isNotNull, reason: '${e.id} needs a carbon limit');
          final nulls = {
            if (e.mn == null) 'manganese',
            if (e.cr == null) 'chromium',
            if (e.mo == null) 'molybdenum',
            if (e.ni == null) 'nickel',
            if (e.cu == null) 'copper',
          };
          expect(e.unlimitedCetElements, nulls, reason: e.id);
        }
        final s355j2 = entries.firstWhere((e) => e.name == 'S355J2');
        expect(s355j2.unlimitedCetElements, {
          'chromium',
          'molybdenum',
          'nickel',
        });
        expect(s355j2.isCetReady, isFalse);
        expect(BaseMaterialCatalog.cetApplicable, contains(s355j2));
        final ss = entries.firstWhere((e) => e.name == '1.4301 / 304');
        expect(ss.cetApplicable, isFalse);
      },
    );

    test('known spot values', () {
      final p355 = entries.firstWhere((e) => e.name == 'P355GH');
      expect((p355.c, p355.mn, p355.cu), (0.22, 1.70, 0.30));
      final a106b = entries.firstWhere((e) => e.name == 'A106 Gr B');
      expect((a106b.c, a106b.cr, a106b.mo), (0.30, 0.40, 0.15));
    });

    test(
      'API 5L entries are PSL2 welded M-condition values (45th ed. Table 5)',
      () {
        final x65 = entries.firstWhere((e) => e.name == 'API 5L X65M');
        expect((x65.standard, x65.c, x65.mn), ('API 5L PSL2', 0.12, 1.60));
        expect((x65.cr, x65.mo, x65.ni, x65.cu), (0.50, 0.50, 0.50, 0.50));
        final x52 = entries.firstWhere((e) => e.name == 'API 5L X52M');
        expect(
          (x52.c, x52.mn, x52.cr, x52.mo, x52.ni),
          (0.22, 1.40, 0.30, 0.15, 0.30),
        );
        expect(entries.where((e) => e.standard.startsWith('API 5L')).length, 7);
      },
    );
  });

  test('no submerged-arc entries until the model has a SAW process', () {
    for (final e in ConsumableCatalog.entries) {
      expect(
        ['AWS A5.17', 'AWS A5.23', 'ISO 14171-A'],
        isNot(contains(e.specification)),
        reason: e.id,
      );
    }
  });
}
