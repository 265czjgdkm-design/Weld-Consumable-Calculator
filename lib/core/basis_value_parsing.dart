/// Parses the leading number out of a formatted basis-panel value like
/// '4' or '2,5 mm', accepting either '.' or ',' as the decimal separator
/// (the numeric input fields allow both).
double? parseBasisNumber(String value) {
  final normalized = value.replaceAll(',', '.');
  final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
  if (match == null) return null;
  return double.tryParse(match.group(0)!);
}
