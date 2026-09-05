import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../services/user_account_store.dart';
import 'account_screen.dart';
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
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  static const _accountStore = UserAccountStore();

  String? _accountEmail;

  @override
  void initState() {
    super.initState();
    _loadAccountEmail();
  }

  Future<void> _loadAccountEmail() async {
    final email = await _accountStore.getEmail();
    if (!mounted) return;
    setState(() => _accountEmail = email);
  }

  Future<void> _openAccountScreen() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AccountScreen()));
    _loadAccountEmail();
  }

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
                            _AccountEntryCard(
                              strings: strings,
                              email: _accountEmail,
                              onTap: _openAccountScreen,
                            ),
                            const SizedBox(height: 20),
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

/// Compact entry point into [AccountScreen], showing the current account
/// state (email, or "Guest") -- a small addition above the existing
/// Calculators/Library/History groups, not a redesign of that layout.
class _AccountEntryCard extends StatelessWidget {
  const _AccountEntryCard({
    required this.strings,
    required this.email,
    required this.onTap,
  });

  final L10nStrings strings;
  final String? email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.account_circle_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.dashboardAccountCardLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF5A6B75),
                      ),
                    ),
                    Text(
                      email ?? strings.dashboardAccountCardGuestValue,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8FA0AA)),
            ],
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
