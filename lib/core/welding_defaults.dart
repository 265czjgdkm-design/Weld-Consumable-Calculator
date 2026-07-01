import '../models/weld_models.dart';

class WeldingDefaults {
  const WeldingDefaults._();

  static const double densityGPerCm3 = 7.85;
  static const double wasteFactorPercent = 10;

  static double efficiencyFor(WeldingProcess process) => switch (process) {
    WeldingProcess.gtaw => 0.95,
    WeldingProcess.smaw => 0.65,
    WeldingProcess.gtawSmaw => 0.80,
    WeldingProcess.gmaw => 0.90,
    WeldingProcess.fcaw => 0.85,
  };

  static double depositionRateFor(WeldingProcess process) => switch (process) {
    WeldingProcess.gtaw => 0.8,
    WeldingProcess.smaw => 1.2,
    WeldingProcess.gtawSmaw => 1.0,
    WeldingProcess.gmaw => 3.5,
    WeldingProcess.fcaw => 4.0,
  };

  static double gtawRateForWire(double? diameterMm) {
    if (diameterMm == null || diameterMm <= 0) return 0.8;
    if (diameterMm <= 1.6) return 0.5;
    if (diameterMm <= 2.0) return 0.65;
    if (diameterMm <= 2.4) return 0.8;
    if (diameterMm <= 3.2) return 1.1;
    return 1.3;
  }

  static double smawRateForElectrode(double? diameterMm) {
    if (diameterMm == null || diameterMm <= 0) return 1.2;
    if (diameterMm <= 2.5) return 0.8;
    if (diameterMm <= 3.2) return 1.2;
    if (diameterMm <= 4.0) return 1.8;
    if (diameterMm <= 5.0) return 2.4;
    return 2.8;
  }

  static double gmawRateForWire(double? diameterMm) {
    if (diameterMm == null || diameterMm <= 0) return 3.5;
    if (diameterMm <= 0.8) return 2.2;
    if (diameterMm <= 1.0) return 3.0;
    if (diameterMm <= 1.2) return 3.5;
    if (diameterMm <= 1.6) return 4.2;
    return 4.8;
  }

  static double fcawRateForWire(double? diameterMm) {
    if (diameterMm == null || diameterMm <= 0) return 4.0;
    if (diameterMm <= 1.2) return 3.4;
    if (diameterMm <= 1.6) return 4.0;
    if (diameterMm <= 2.0) return 4.8;
    return 5.4;
  }

  static List<ConsumablePreset> consumablesFor(WeldingProcess process) =>
      ConsumablePreset.values
          .where((preset) => preset.supportedProcesses.contains(process))
          .toList();

  static ConsumablePreset defaultConsumableFor(WeldingProcess process) =>
      switch (process) {
        WeldingProcess.gtaw => ConsumablePreset.er70s2,
        WeldingProcess.smaw => ConsumablePreset.e7018,
        WeldingProcess.gtawSmaw => ConsumablePreset.gtawRootSmawFill,
        WeldingProcess.gmaw => ConsumablePreset.er70s6,
        WeldingProcess.fcaw => ConsumablePreset.e71t1,
      };
}
