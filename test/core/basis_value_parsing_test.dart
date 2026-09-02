import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/basis_value_parsing.dart';

void main() {
  group('parseBasisNumber', () {
    test('parses a plain integer basis value', () {
      expect(parseBasisNumber('4'), 4.0);
    });

    test('parses a dot-decimal basis value with a unit suffix', () {
      expect(parseBasisNumber('2.4 mm'), 2.4);
    });

    test('parses a comma-decimal basis value the same as its dot form', () {
      // Regression: Quantity '2,5' must resolve to 2.5, not 2.0 (the
      // digits before the first non-digit under a naive dot-only regex).
      expect(parseBasisNumber('2,5'), 2.5);
      expect(parseBasisNumber('2,5 mm'), 2.5);
    });

    test('returns null when no number is present', () {
      expect(parseBasisNumber('Estimated'), null);
    });
  });
}
