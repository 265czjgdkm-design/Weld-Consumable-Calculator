import 'package:flutter/material.dart';

import '../../l10n/app_locale_scope.dart';
import '../../services/account_session.dart';
import '../../services/auth_service.dart';
import '../../services/entitlement_service.dart';
import 'auth_flows.dart';
import 'auth_widgets.dart';

/// Controllers are owned by this State so the framework disposes them at the
/// right point in the route's teardown (see calculator_page.dart's
/// `_PresetNameDialog` for the Flutter-web crash this avoids).
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.entitlementService});

  final EntitlementService? entitlementService;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _firstNameKey = GlobalKey();
  final _lastNameKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();
  final _confirmKey = GlobalKey();
  final _consentKey = GlobalKey();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _consentError;
  String? _formError;
  bool _consent = false;
  bool _submitting = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 250),
      alignment: 0.1,
    );
  }

  bool _validate() {
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyOf(context);
    final password = _password.text;
    setState(() {
      _formError = null;
      _firstNameError = _firstName.text.trim().isEmpty
          ? strings.authFormFirstNameError
          : null;
      _lastNameError = _lastName.text.trim().isEmpty
          ? strings.authFormLastNameError
          : null;
      _emailError = authEmailPattern.hasMatch(_email.text.trim())
          ? null
          : strings.emailGateInvalidEmail;
      _passwordError = password.length < 8 ? copy.passwordTooShort : null;
      _confirmError = _confirm.text != password ? copy.passwordMismatch : null;
      _consentError = _consent ? null : copy.consentRequired;
    });
    final invalid = [
      if (_firstNameError != null) _firstNameKey,
      if (_lastNameError != null) _lastNameKey,
      if (_emailError != null) _emailKey,
      if (_passwordError != null) _passwordKey,
      if (_confirmError != null) _confirmKey,
      if (_consentError != null) _consentKey,
    ];
    if (invalid.isEmpty) return true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollTo(invalid.first),
    );
    return false;
  }

  Future<void> _submit() async {
    if (_submitting || !_validate()) return;
    final copy = authCopyOf(context);
    final email = _email.text.trim();
    final firstName = _firstName.text.trim();
    setState(() => _submitting = true);
    try {
      final user = await AuthServices.instance.signUpWithEmail(
        firstName: firstName,
        lastName: _lastName.text.trim(),
        email: email,
        password: _password.text,
      );
      if (!mounted) return;
      await sendWelcomeMail(context, email: email, firstName: firstName);
      if (!mounted) return;
      final outcome = await Navigator.of(context).push<AuthOutcome>(
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            email: user.email ?? email,
            entitlementService: widget.entitlementService,
          ),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(outcome ?? AuthOutcome.unverified);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        if (error.code == AuthErrorCode.emailInUse) {
          _emailError = copy.errEmailInUse;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollTo(_emailKey),
          );
        } else if (error.code == AuthErrorCode.weakPassword) {
          _passwordError = copy.errWeakPassword;
        } else {
          _formError = authErrorText(copy, error);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyOf(context);
    final enabled = !_submitting;
    const gap = SizedBox(height: 14);
    return AuthScaffold(
      title: strings.authFormTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            key: _firstNameKey,
            controller: _firstName,
            enabled: enabled,
            label: strings.authFormFirstNameLabel,
            hint: strings.authFormFirstNameHint,
            errorText: _firstNameError,
            autofillHints: const [AutofillHints.givenName],
          ),
          gap,
          AuthTextField(
            key: _lastNameKey,
            controller: _lastName,
            enabled: enabled,
            label: strings.authFormLastNameLabel,
            hint: strings.authFormLastNameHint,
            errorText: _lastNameError,
            autofillHints: const [AutofillHints.familyName],
          ),
          gap,
          AuthTextField(
            key: _emailKey,
            controller: _email,
            enabled: enabled,
            label: strings.authFormEmailLabel,
            hint: strings.emailGateHint,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            autofillHints: const [AutofillHints.email],
          ),
          gap,
          PasswordField(
            key: _passwordKey,
            controller: _password,
            enabled: enabled,
            label: copy.passwordLabel,
            errorText: _passwordError,
          ),
          gap,
          PasswordField(
            key: _confirmKey,
            controller: _confirm,
            enabled: enabled,
            label: copy.passwordConfirmLabel,
            errorText: _confirmError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          gap,
          Row(
            key: _consentKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _consent,
                activeColor: authAccent,
                side: const BorderSide(color: Color(0xFF9AA5A8), width: 1.5),
                onChanged: enabled
                    ? (value) => setState(() {
                        _consent = value ?? false;
                        if (_consent) _consentError = null;
                      })
                    : null,
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: RegistrationConsentText(),
                ),
              ),
            ],
          ),
          if (_consentError != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(
                _consentError!,
                style: const TextStyle(
                  color: Color(0xFFFF8A80),
                  fontSize: 12.5,
                ),
              ),
            ),
          const SizedBox(height: 18),
          if (_formError != null) AuthErrorBanner(_formError!),
          AuthPrimaryButton(
            label: strings.authFormSubmitButton,
            busy: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.entitlementService});

  final EntitlementService? entitlementService;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyOf(context);
    final email = _email.text.trim();
    setState(() {
      _formError = null;
      _emailError = authEmailPattern.hasMatch(email)
          ? null
          : strings.emailGateInvalidEmail;
      _passwordError = _password.text.isEmpty ? copy.passwordRequired : null;
    });
    if (_emailError != null || _passwordError != null) return;
    setState(() => _submitting = true);
    try {
      final user = await AuthServices.instance.signInWithEmail(
        email: email,
        password: _password.text,
      );
      if (!mounted) return;
      if (!user.isVerified) {
        // Verification mail is re-sent from the verify screen on demand.
        final outcome = await Navigator.of(context).push<AuthOutcome>(
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(
              email: user.email ?? email,
              entitlementService: widget.entitlementService,
            ),
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop(outcome ?? AuthOutcome.unverified);
        return;
      }
      await AccountSession.apply(user, entitlement: widget.entitlementService);
      if (!mounted) return;
      Navigator.of(context).pop(AuthOutcome.verified);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _formError = authErrorText(copy, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyOf(context);
    return AuthScaffold(
      title: copy.signInTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _email,
            enabled: !_submitting,
            label: strings.authFormEmailLabel,
            hint: strings.emailGateHint,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 14),
          PasswordField(
            controller: _password,
            enabled: !_submitting,
            label: copy.passwordLabel,
            errorText: _passwordError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            ForgotPasswordScreen(initialEmail: _email.text),
                      ),
                    ),
              child: Text(
                copy.forgotPassword,
                style: const TextStyle(color: Color(0xFFAEB8BB)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (_formError != null) AuthErrorBanner(_formError!),
          AuthPrimaryButton(
            label: copy.signInButton,
            busy: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  String? _emailError;
  String? _formError;
  bool _sent = false;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyOf(context);
    final email = _email.text.trim();
    setState(() {
      _sent = false;
      _formError = null;
      _emailError = authEmailPattern.hasMatch(email)
          ? null
          : strings.emailGateInvalidEmail;
    });
    if (_emailError != null) return;
    setState(() => _submitting = true);
    try {
      await AuthServices.instance.sendPasswordReset(email);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _sent = true;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        // Same message as success: never reveal whether an email is registered.
        if (error.code == AuthErrorCode.userNotFound) {
          _sent = true;
        } else {
          _formError = authErrorText(copy, error);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyOf(context);
    return AuthScaffold(
      title: copy.forgotTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.forgotBody,
            style: const TextStyle(color: Color(0xFFAEB8BB), height: 1.4),
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _email,
            enabled: !_submitting,
            label: strings.authFormEmailLabel,
            hint: strings.emailGateHint,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          if (_formError != null) AuthErrorBanner(_formError!),
          if (_sent)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                copy.forgotSent,
                style: const TextStyle(color: Color(0xFF7BD88F), height: 1.4),
              ),
            ),
          AuthPrimaryButton(
            label: copy.forgotSend,
            busy: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.entitlementService,
  });

  final String email;
  final EntitlementService? entitlementService;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  String? _message;
  bool _messageIsError = false;
  bool _checking = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the mail app: pick up a verification without a button tap.
    if (state == AppLifecycleState.resumed) _check(silent: true);
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    final copy = authCopyOf(context);
    setState(() => _checking = true);
    try {
      final user = await AuthServices.instance.reload();
      if (!mounted) return;
      if (user != null && user.isVerified) {
        await AccountSession.apply(
          user,
          entitlement: widget.entitlementService,
        );
        if (!mounted) return;
        Navigator.of(context).pop(AuthOutcome.verified);
        return;
      }
      setState(() {
        _checking = false;
        if (!silent) {
          _message = copy.verifyNotYet;
          _messageIsError = true;
        }
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        if (!silent) {
          _message = authErrorText(copy, error);
          _messageIsError = true;
        }
      });
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    final copy = authCopyOf(context);
    setState(() => _resending = true);
    try {
      await AuthServices.instance.sendVerificationEmail();
      if (!mounted) return;
      setState(() {
        _resending = false;
        _message = copy.verifyResent;
        _messageIsError = false;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _message = authErrorText(copy, error);
        _messageIsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = authCopyOf(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(AuthOutcome.unverified);
      },
      child: AuthScaffold(
        title: copy.verifyTitle,
        showBack: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              color: authAccent,
              size: 44,
            ),
            const SizedBox(height: 14),
            Text(
              copy.verifyBody.replaceFirst('{email}', widget.email),
              style: const TextStyle(color: Color(0xFFAEB8BB), height: 1.45),
            ),
            const SizedBox(height: 22),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _messageIsError
                        ? const Color(0xFFFF8A80)
                        : const Color(0xFF7BD88F),
                    height: 1.4,
                  ),
                ),
              ),
            AuthPrimaryButton(
              label: copy.verifyDone,
              busy: _checking,
              onPressed: _check,
            ),
            const SizedBox(height: 12),
            AuthSecondaryButton(
              label: copy.verifyResend,
              onPressed: _resending ? null : _resend,
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(AuthOutcome.unverified),
                child: Text(
                  copy.verifyLater,
                  style: const TextStyle(color: Color(0xFFAEB8BB)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
