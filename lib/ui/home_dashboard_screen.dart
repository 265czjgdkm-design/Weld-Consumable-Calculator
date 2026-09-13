import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../services/entitlement_service.dart';
import '../services/user_account_store.dart';
import 'account_screen.dart';
import 'ai_assistant_screen.dart';
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

  /// Gates the whole AI assistant screen at the dashboard-button level
  /// (rather than reusing calculator_page.dart's private `_PaywallSheet`,
  /// which isn't reachable from here) -- non-premium users see the paywall
  /// directly instead of ever landing on the chat screen.
  Future<void> _openAiAssistant() async {
    final entitlementService = EntitlementService();
    bool isPremium = false;
    try {
      isPremium = await entitlementService.isPremiumActive();
    } catch (error) {
      debugPrint('Failed to read entitlement status: $error');
    }
    if (!mounted) return;
    if (isPremium) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              AiAssistantScreen(entitlementService: entitlementService),
        ),
      );
      return;
    }
    await showAiAssistantPaywall(
      context,
      entitlementService: entitlementService,
      onEntitlementChanged: (isPremium) {
        if (!mounted || !isPremium) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                AiAssistantScreen(entitlementService: entitlementService),
          ),
        );
      },
    );
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
                            _DashboardTileGrid(
                              tiles: [
                                _DashboardTile(
                                  icon: Icons.calculate_outlined,
                                  label: strings.dashboardFillerConsumption,
                                  style: _TileStyle.primary,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CalculatorPage(),
                                    ),
                                  ),
                                ),
                                _DashboardTile(
                                  icon: Icons.device_thermostat_outlined,
                                  label: strings.dashboardPreheatCalculator,
                                  style: _TileStyle.primary,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PreheatCalculatorScreen(),
                                    ),
                                  ),
                                ),
                                _DashboardTile(
                                  icon: Icons.ac_unit_outlined,
                                  label:
                                      strings.dashboardCoolingTimeCalculator,
                                  style: _TileStyle.primary,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CoolingTimeCalculatorScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _DashboardSectionTitle(
                              strings.dashboardAssistantSectionTitle,
                            ),
                            const SizedBox(height: 10),
                            _DashboardTileGrid(
                              tiles: [
                                _DashboardTile(
                                  icon: Icons.smart_toy_outlined,
                                  label: strings.dashboardAiAssistant,
                                  style: _TileStyle.accent,
                                  onPressed: _openAiAssistant,
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _DashboardSectionTitle(
                              strings.dashboardLibrarySectionTitle,
                            ),
                            const SizedBox(height: 10),
                            _DashboardTileGrid(
                              tiles: [
                                _DashboardTile(
                                  icon: Icons.construction_outlined,
                                  label: strings.dashboardBaseMaterial,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BaseMaterialScreen(),
                                    ),
                                  ),
                                ),
                                _DashboardTile(
                                  icon: Icons.local_fire_department_outlined,
                                  label: strings.dashboardFillerMaterial,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FillerMaterialScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _DashboardSectionTitle(
                              strings.dashboardHistorySectionTitle,
                            ),
                            const SizedBox(height: 10),
                            _DashboardTileGrid(
                              tiles: [
                                _DashboardTile(
                                  icon: Icons.bookmark_outline,
                                  label: strings.dashboardSavedCalculations,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SavedCalculationsScreen(),
                                    ),
                                  ),
                                ),
                                _DashboardTile(
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

/// Lays [tiles] out two-per-row (last odd tile left-aligned, not stretched)
/// instead of the single-column stack of full-width bars this dashboard
/// used before -- distinct square entry points read more clearly as
/// separate destinations than a list of horizontal buttons.
class _DashboardTileGrid extends StatelessWidget {
  const _DashboardTileGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles)
              SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }
}

/// Which visual treatment a [_DashboardTile] gets. The plain boolean
/// "emphasized" this replaced only had two looks (a Material-seed teal that
/// matched nothing else in the brand, and a cold blue-grey block) -- neither
/// reads as this app's own dark/orange identity (splash, landing page,
/// TopNavigationBar mark badge). [primary] and [accent] now reuse that same
/// literal dark gradient; [neutral] switches to a plain white card (like
/// [_AccountEntryCard]) instead of a colored block, which is closer to how a
/// polished app actually differentiates "primary" vs "secondary" actions.
enum _TileStyle { primary, accent, neutral }

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style = _TileStyle.neutral,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final _TileStyle style;

  static const _brandOrange = Color(0xFFFF6A35);
  static const _darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B2326), Color(0xFF0B0F10)],
  );

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration;
    final Color foreground;
    final Color iconColor;
    switch (style) {
      case _TileStyle.primary:
        decoration = const BoxDecoration(gradient: _darkGradient);
        foreground = Colors.white;
        iconColor = Colors.white;
      case _TileStyle.accent:
        // Same dark surface as [primary] with an orange glow behind the
        // icon and an orange-tinted border -- the AI assistant is the
        // newest feature, so it gets a visibly distinct "premium" entry
        // rather than blending in as just another calculator-style tile.
        decoration = BoxDecoration(
          gradient: _darkGradient,
          border: Border.all(
            color: _brandOrange.withValues(alpha: 0.55),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: _brandOrange.withValues(alpha: 0.28),
              blurRadius: 22,
              spreadRadius: -4,
            ),
          ],
        );
        foreground = Colors.white;
        iconColor = _brandOrange;
      case _TileStyle.neutral:
        decoration = BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1E8ED)),
        );
        foreground = const Color(0xFF17303C);
        iconColor = const Color(0xFF17303C);
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: decoration.copyWith(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: iconColor),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
