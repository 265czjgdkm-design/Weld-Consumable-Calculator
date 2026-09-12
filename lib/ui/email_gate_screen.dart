import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../services/legal_links.dart';
import '../services/signup_gate_store.dart';
import '../services/signup_submitter.dart';
import '../services/user_account_store.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'home_dashboard_screen.dart';
import 'widgets/welding_loader.dart';

/// Shown once, right after the splash animation: a choice between creating
/// an account (first/last name + email) and continuing as a guest.
/// Whichever path the user takes, [SignupGateStore] remembers the choice so
/// this never shows again.
class EmailGateScreen extends StatefulWidget {
  const EmailGateScreen({super.key});

  @override
  State<EmailGateScreen> createState() => _EmailGateScreenState();
}

class _EmailGateScreenState extends State<EmailGateScreen> {
  static const _gateStore = SignupGateStore();
  static const _accountStore = UserAccountStore();

  bool _showForm = false;
  bool _submitting = false;

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

  Future<void> _continueAsGuest() async {
    await _gateStore.markResolved();
    if (!mounted) return;
    _goToDashboard();
  }

  Future<void> _submitRegistration({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    setState(() => _submitting = true);

    // Best-effort: whether the submission actually reached the sheet or
    // not, the user has made their choice and shouldn't be blocked or
    // asked again -- the welcome email itself is the real confirmation.
    await submitSignupEmail(email);
    await _accountStore.setEmail(email);
    await _accountStore.setName(firstName, lastName);
    await _gateStore.markResolved();
    if (!mounted) return;
    _goToDashboard();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _showForm
                    ? _RegistrationForm(
                        submitting: _submitting,
                        onBack: () => setState(() => _showForm = false),
                        onSubmit: _submitRegistration,
                      )
                    : _AuthChoice(
                        onRegister: () => setState(() => _showForm = true),
                        onGuest: _continueAsGuest,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [VaryosMark] with a soft, static orange bloom behind it -- so the mark
/// doesn't sit on a flat black header right after the splash's glowing
/// impact flash. Reuses the same [RadialGradient] recipe as
/// splash_screen.dart's impact flash, just held at a fixed ambient opacity
/// instead of animating in and out.
class _MarkWithBloom extends StatelessWidget {
  const _MarkWithBloom({required this.markSize, required this.bloomSize});

  final double markSize;
  final double bloomSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: bloomSize,
      height: bloomSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: bloomSize,
            height: bloomSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x40FF6A35), Color(0x00FF6A35)],
              ),
            ),
          ),
          VaryosMark(size: markSize),
        ],
      ),
    );
  }
}

class _AuthChoice extends StatelessWidget {
  const _AuthChoice({required this.onRegister, required this.onGuest});

  final VoidCallback onRegister;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _MarkWithBloom(markSize: 44, bloomSize: 140),
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
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onRegister,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6A35),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              strings.authChoiceRegisterButton,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: onGuest,
          child: Text(
            strings.authChoiceGuestButton,
            style: const TextStyle(
              color: Color(0xFFAEB8BB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Owns its own [TextEditingController]s as a StatefulWidget field so they
/// are disposed by the framework at the right point in this route's own
/// teardown -- see calculator_page.dart's `_PresetNameDialog` for the same
/// pattern and why disposing controllers right after a caller callback
/// returns can crash Flutter web.
class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm({
    required this.submitting,
    required this.onBack,
    required this.onSubmit,
  });

  final bool submitting;
  final VoidCallback onBack;
  final Future<void> Function({
    required String firstName,
    required String lastName,
    required String email,
  })
  onSubmit;

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final strings = AppLocaleScope.stringsOf(context);
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _firstNameError = firstName.isEmpty
          ? strings.authFormFirstNameError
          : null;
      _lastNameError = lastName.isEmpty ? strings.authFormLastNameError : null;
      _emailError = _emailPattern.hasMatch(email)
          ? null
          : strings.emailGateInvalidEmail;
    });

    if (_firstNameError != null ||
        _lastNameError != null ||
        _emailError != null) {
      return;
    }

    widget.onSubmit(firstName: firstName, lastName: lastName, email: email);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.submitting ? null : widget.onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 4),
            const _MarkWithBloom(markSize: 32, bloomSize: 64),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          strings.authFormTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 22),
        _AuthTextField(
          controller: _firstNameController,
          enabled: !widget.submitting,
          label: strings.authFormFirstNameLabel,
          hint: strings.authFormFirstNameHint,
          errorText: _firstNameError,
        ),
        const SizedBox(height: 14),
        _AuthTextField(
          controller: _lastNameController,
          enabled: !widget.submitting,
          label: strings.authFormLastNameLabel,
          hint: strings.authFormLastNameHint,
          errorText: _lastNameError,
        ),
        const SizedBox(height: 14),
        _AuthTextField(
          controller: _emailController,
          enabled: !widget.submitting,
          label: strings.authFormEmailLabel,
          hint: strings.emailGateHint,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        const _RegistrationConsentText(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6A35),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: widget.submitting
                ? const WeldingLoader(size: 20)
                : Text(
                    strings.authFormSubmitButton,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.errorText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9AA5A8)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7578)),
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFF161C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6A35), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}

/// "By registering, you agree to our Privacy Policy and Terms of Use" with
/// the two link segments tappable -- required for Apple guideline 5.1.1(i)
/// (the app must present a Privacy Policy link wherever an account is
/// created).
class _RegistrationConsentText extends StatelessWidget {
  const _RegistrationConsentText();

  Future<void> _openLink(BuildContext context, String url) async {
    final strings = AppLocaleScope.stringsOf(context);
    try {
      await LegalLinks.open(url);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(strings.legalLinkOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    const textStyle = TextStyle(color: Color(0xFFAEB8BB), fontSize: 12.5);
    const linkStyle = TextStyle(
      color: Color(0xFFAEB8BB),
      fontSize: 12.5,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );
    return Wrap(
      children: [
        Text('${strings.authFormConsentPrefix} ', style: textStyle),
        GestureDetector(
          onTap: () => _openLink(context, LegalLinks.privacyPolicyUrl),
          child: Text(strings.legalPrivacyPolicyLinkLabel, style: linkStyle),
        ),
        Text(' ${strings.authFormConsentConnector} ', style: textStyle),
        GestureDetector(
          onTap: () => _openLink(context, LegalLinks.termsOfUseUrl),
          child: Text(strings.legalTermsOfUseLinkLabel, style: linkStyle),
        ),
        Text(strings.authFormConsentSuffix, style: textStyle),
      ],
    );
  }
}
