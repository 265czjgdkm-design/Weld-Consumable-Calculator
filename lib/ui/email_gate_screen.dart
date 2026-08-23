import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../services/signup_gate_store.dart';
import '../services/signup_submitter.dart';
import 'calculator_page.dart';
import 'calculator_page/calculator_page_widgets.dart';

/// Shown once, right after the splash animation: a single-field, skippable
/// prompt for the user's email (soft gate -- see the onboarding research
/// this screen is based on: a mandatory multi-field sign-up costs far more
/// completion than a one-field, skip-friendly ask). Whichever path the user
/// takes, [SignupGateStore] remembers the choice so this never shows again.
class EmailGateScreen extends StatefulWidget {
  const EmailGateScreen({super.key});

  @override
  State<EmailGateScreen> createState() => _EmailGateScreenState();
}

class _EmailGateScreenState extends State<EmailGateScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _gateStore = SignupGateStore();

  final _controller = TextEditingController();
  String? _errorText;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToCalculator() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CalculatorPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _continueAsGuest() async {
    await _gateStore.markResolved();
    if (!mounted) return;
    _goToCalculator();
  }

  Future<void> _continueWithEmail() async {
    final strings = AppLocaleScope.stringsOf(context);
    final email = _controller.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _errorText = strings.emailGateInvalidEmail);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    // Best-effort: whether the submission actually reached the sheet or
    // not, the user has made their choice and shouldn't be blocked or
    // asked again -- the welcome email itself is the real confirmation.
    await submitSignupEmail(email);
    await _gateStore.markResolved();
    if (!mounted) return;
    _goToCalculator();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F10),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VaryosMark(size: 44),
                  const SizedBox(height: 28),
                  Text(
                    strings.emailGateTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.emailGateBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFAEB8BB),
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _controller,
                    enabled: !_submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _continueWithEmail(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: strings.emailGateHint,
                      hintStyle: const TextStyle(color: Color(0xFF6B7578)),
                      errorText: _errorText,
                      filled: true,
                      fillColor: const Color(0xFF161C1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _continueWithEmail,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A35),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              strings.emailGateContinue,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _submitting ? null : _continueAsGuest,
                    child: Text(
                      strings.emailGateGuest,
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
    );
  }
}
