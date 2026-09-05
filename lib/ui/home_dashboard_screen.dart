import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import 'base_material_screen.dart';
import 'calculator_page.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'cooling_time_calculator_screen.dart';
import 'filler_material_screen.dart';
import 'preheat_calculator_screen.dart';
import 'saved_calculations_screen.dart';
import 'saved_reports_screen.dart';

/// Landing screen shown after the registration/guest choice is resolved: a
/// single centered column of entry points into the app's main flows, with
/// the same top nav bar treatment as [CalculatorPage] for brand continuity.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F8FB), Color(0xFFE8EFF4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TopNavigationBar(),
                    const SizedBox(height: 32),
                    Text(
                      strings.dashboardTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            _DashboardSectionTitle(
                              strings.dashboardCalculatorsSectionTitle,
                            ),
                            const SizedBox(height: 10),
                            _DashboardButton(
                              icon: Icons.calculate_outlined,
                              label: strings.dashboardFillerConsumption,
                              emphasized: true,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CalculatorPage(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _DashboardButton(
                              icon: Icons.device_thermostat_outlined,
                              label: strings.dashboardPreheatCalculator,
                              emphasized: true,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PreheatCalculatorScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _DashboardButton(
                              icon: Icons.ac_unit_outlined,
                              label: strings.dashboardCoolingTimeCalculator,
                              emphasized: true,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CoolingTimeCalculatorScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _DashboardSectionTitle(
                              strings.dashboardLibrarySectionTitle,
                            ),
                            const SizedBox(height: 10),
                            _DashboardButton(
                              icon: Icons.construction_outlined,
                              label: strings.dashboardBaseMaterial,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BaseMaterialScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _DashboardButton(
                              icon: Icons.local_fire_department_outlined,
                              label: strings.dashboardFillerMaterial,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FillerMaterialScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _DashboardSectionTitle(
                              strings.dashboardHistorySectionTitle,
                            ),
                            const SizedBox(height: 10),
                            _DashboardButton(
                              icon: Icons.bookmark_outline,
                              label: strings.dashboardSavedCalculations,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SavedCalculationsScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _DashboardButton(
                              icon: Icons.picture_as_pdf_outlined,
                              label: strings.dashboardSavedReports,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SavedReportsScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardSectionTitle extends StatelessWidget {
  const _DashboardSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5A6B75),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
    return SizedBox(
      width: double.infinity,
      child: emphasized
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: textStyle,
              ),
            )
          : FilledButton.tonalIcon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: textStyle,
              ),
            ),
    );
  }
}
