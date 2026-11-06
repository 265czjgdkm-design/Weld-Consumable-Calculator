import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../services/signup_gate_store.dart';
import '../services/auth_service.dart';
import 'auth/auth_flows.dart';
import 'auth/auth_screens.dart';
import 'auth/auth_widgets.dart';
import 'home_dashboard_screen.dart';

/// Shown once, right after the splash animation: Apple / email sign-up /
/// sign-in, or continue as a guest. Whichever path the user takes,
/// [SignupGateStore] remembers the choice so this never shows again.
class EmailGateScreen extends StatefulWidget {
  const EmailGateScreen({super.key});

  @override
  State<EmailGateScreen> createState() => _EmailGateScreenState();
}

class _EmailGateScreenState extends State<EmailGateScreen> {
  static const _gateStore = SignupGateStore();

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeDashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _finish(AuthOutcome outcome) async {
    if (outcome == AuthOutcome.none) return;
    await _gateStore.markResolved();
    if (!mounted) return;
    _goToDashboard();
  }

  Future<void> _open(Widget screen) async {
    final outcome = await Navigator.of(
      context,
    ).push<AuthOutcome>(MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    await _finish(outcome ?? AuthOutcome.none);
  }

  Future<void> _continueAsGuest() async {
    await _gateStore.markResolved();
    if (!mounted) return;
    _goToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyOf(context);
    final available = AuthServices.instance.available;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F10),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.5),
            radius: 1.3,
            colors: [Color(0xFF232D30), Color(0xFF0B0F10)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MarkWithBloom(markSize: 44, bloomSize: 140),
                    const SizedBox(height: 28),
                    Text(
                      strings.authChoiceTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      strings.authChoiceBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFAEB8BB),
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (available) ...[
                      AuthPrimaryButton(
                        label: copy.registerButton,
                        onPressed: () => _open(const RegistrationScreen()),
                      ),
                      const SizedBox(height: 12),
                      AuthSecondaryButton(
                        label: copy.signInButton,
                        onPressed: () => _open(const SignInScreen()),
                      ),
                    ] else
                      const AuthUnavailableNote(),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _continueAsGuest,
                      child: Text(
                        copy.guestButton,
                        style: const TextStyle(
                          color: Color(0xFFAEB8BB),
                          fontWeight: FontWeight.w600,
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
