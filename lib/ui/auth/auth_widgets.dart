import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../l10n/app_locale_scope.dart';
import '../../l10n/auth_copy.dart';
import '../../services/auth_service.dart';
import '../../services/legal_links.dart';
import '../calculator_page/calculator_page_widgets.dart';

const authAccent = Color(0xFFFF6A35);

AuthCopy authCopyOf(BuildContext context) =>
    authCopyFor(AppLocaleScope.of(context).language);

String authErrorText(AuthCopy copy, AuthException error) =>
    switch (error.code) {
      AuthErrorCode.emailInUse => copy.errEmailInUse,
      AuthErrorCode.invalidEmail => copy.errInvalidEmail,
      AuthErrorCode.weakPassword => copy.errWeakPassword,
      AuthErrorCode.wrongCredentials ||
      AuthErrorCode.userNotFound => copy.errWrongCredentials,
      AuthErrorCode.network => copy.errNetwork,
      AuthErrorCode.tooManyRequests => copy.errTooMany,
      AuthErrorCode.unavailable => copy.errUnavailable,
      _ => copy.errGeneric,
    };

final authEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// A [VaryosMark] with a soft, static orange bloom behind it.
class MarkWithBloom extends StatelessWidget {
  const MarkWithBloom({
    super.key,
    required this.markSize,
    required this.bloomSize,
  });

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

/// Dark, scrollable page shell shared by the auth screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.scrollController,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final ScrollController? scrollController;
  final bool showBack;

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
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (showBack)
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        const SizedBox(width: 4),
                        const MarkWithBloom(markSize: 32, bloomSize: 64),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    child,
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

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.hint,
    this.keyboardType,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? hint;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9AA5A8)),
        floatingLabelStyle: const TextStyle(color: Color(0xFFC9D1D3)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7578)),
        errorText: errorText,
        errorMaxLines: 3,
        suffixIcon: suffixIcon,
        suffixIconColor: const Color(0xFF9AA5A8),
        filled: true,
        fillColor: const Color(0xFF161C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: authAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.errorText,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final copy = authCopyOf(context);
    return AuthTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      enabled: widget.enabled,
      obscureText: _obscured,
      errorText: widget.errorText,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        tooltip: _obscured ? copy.showPassword : copy.hidePassword,
        icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}

class AppleAuthButton extends StatelessWidget {
  const AppleAuthButton({super.key, required this.onPressed, this.dark = true});

  final VoidCallback? onPressed;

  /// True on dark backgrounds (renders the white Apple button).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SignInWithAppleButton(
      onPressed: onPressed ?? () {},
      text: authCopyOf(context).appleButton,
      style: dark
          ? SignInWithAppleButtonStyle.white
          : SignInWithAppleButtonStyle.black,
      height: 52,
      borderRadius: const BorderRadius.all(Radius.circular(14)),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: authAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF3A464A)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 13.5),
      ),
    );
  }
}

/// "By registering, you agree to our Privacy Policy and Terms of Use" with
/// the two link segments tappable (Apple guideline 5.1.1(i)).
class RegistrationConsentText extends StatelessWidget {
  const RegistrationConsentText({super.key});

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
