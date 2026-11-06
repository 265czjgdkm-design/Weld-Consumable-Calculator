import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/auth_copy.dart';
import '../l10n/premium_account_copy.dart';
import '../l10n/strings.dart';
import '../services/account_deletion_service.dart';
import '../services/account_session.dart';
import '../services/ai_consent_store.dart';
import '../services/auth_service.dart';
import '../services/entitlement_service.dart';
import '../services/legal_links.dart';
import '../services/user_preset_store.dart';
import 'auth/auth_flows.dart';
import 'auth/auth_screens.dart';
import 'auth/auth_widgets.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'premium_paywall.dart';
import 'user_guide_screen.dart';
import 'widgets/welding_loader.dart';

/// Account management screen: shows the Firebase account (name, email,
/// verification state), Sign Out and Delete Account when signed in; Apple /
/// sign-up / sign-in entry points in the Guest state.
class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    this.accountDeletionService = const AccountDeletionService(),
    this.consentStore = const AiConsentStore(),
    this.entitlementService,
  });

  final AccountDeletionService accountDeletionService;
  final AiConsentStore consentStore;
  final EntitlementService? entitlementService;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const _presetStore = UserPresetStore();

  late final EntitlementService _entitlement =
      widget.entitlementService ?? EntitlementService();
  PremiumStatus _premiumStatus = const PremiumStatus();

  AuthUser? _user;
  bool _loading = true;
  bool _busy = false;
  bool _restoringPurchases = false;
  bool _aiConsentGiven = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final aiConsentGiven = await widget.consentStore.isAcknowledged();
    if (!mounted) return;
    setState(() {
      _aiConsentGiven = aiConsentGiven;
      _user = AuthServices.instance.currentUser;
      _loading = false;
    });
    // Not awaited: the SDK call must never keep the screen on its loader.
    _refreshPremiumStatus();
  }

  Future<PremiumStatus> _readPremiumStatus() async {
    try {
      return await _entitlement.premiumStatus();
    } catch (error) {
      debugPrint('Failed to read premium status: $error');
      return const PremiumStatus();
    }
  }

  Future<void> _refreshPremiumStatus() async {
    final status = await _readPremiumStatus();
    if (!mounted) return;
    setState(() => _premiumStatus = status);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signOut() async {
    final strings = AppLocaleScope.stringsOf(context);
    // Only the account identity is cleared -- local saved calculations
    // (UserPresetStore) are deliberately left untouched, and
    // SignupGateStore is deliberately not touched either so the app never
    // re-shows the initial splash/email-gate choice again.
    await AuthServices.instance.signOut();
    await AccountSession.apply(null, entitlement: _entitlement);
    if (!mounted) return;
    setState(() => _user = null);
    _showMessage(strings.accountSignOutSuccess);
    unawaited(_refreshPremiumStatus());
  }

  Future<void> _openAuth(Widget screen) async {
    final outcome = await Navigator.of(
      context,
    ).push<AuthOutcome>(MaterialPageRoute(builder: (_) => screen));
    await _afterAuth(outcome ?? AuthOutcome.none);
  }

  Future<void> _afterAuth(AuthOutcome outcome) async {
    if (!mounted || outcome == AuthOutcome.none) return;
    setState(() => _user = AuthServices.instance.currentUser);
    unawaited(_refreshPremiumStatus());
  }

  Future<void> _appleSignIn() async {
    setState(() => _busy = true);
    final outcome = await runAppleSignIn(context, entitlement: _entitlement);
    if (!mounted) return;
    setState(() => _busy = false);
    await _afterAuth(outcome);
  }

  /// Deletes the Firebase user, re-authenticating once when Firebase asks
  /// for a recent login. Returns false when the user backed out or it
  /// failed (a message is shown), in which case nothing was deleted.
  Future<bool> _deleteFirebaseUser() async {
    final auth = AuthServices.instance;
    final copy = authCopyFor(AppLocaleScope.of(context).language);
    try {
      try {
        await auth.deleteUser();
      } on AuthException catch (error) {
        if (error.code != AuthErrorCode.requiresRecentLogin) rethrow;
        String? password;
        if (!(_user?.isApple ?? false)) {
          if (!mounted) return false;
          password = await showDialog<String>(
            context: context,
            builder: (_) => const _ReauthPasswordDialog(),
          );
          if (password == null) return false;
        }
        await auth.reauthenticate(password: password);
        await auth.deleteUser();
      }
      return true;
    } on AuthException catch (error) {
      if (error.code != AuthErrorCode.cancelled && mounted) {
        _showMessage(authErrorText(copy, error));
      }
      return false;
    }
  }

  Future<void> _deleteAccount() async {
    final strings = AppLocaleScope.stringsOf(context);
    final user = _user;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.accountDeleteConfirmTitle),
        content: Text(strings.accountDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);

    if (!await _deleteFirebaseUser()) {
      if (mounted) setState(() => _busy = false);
      return;
    }

    // Cloud rows are keyed by the email, so only a VERIFIED user may ask for
    // them to be wiped (an unverified sign-up proves nothing about the
    // address). The screen stays busy (back navigation blocked via PopScope)
    // until the server answers; local data is cleared regardless of the
    // outcome and the email is kept in a local variable so Retry can still
    // address it.
    final cloudEmail = user.isVerified ? user.email : null;
    var deleted = false;
    var localCleared = false;
    while (true) {
      try {
        if (cloudEmail != null) {
          await widget.accountDeletionService.deleteAccount(cloudEmail);
        }
        deleted = true;
      } catch (_) {
        deleted = false;
      }
      if (!localCleared) {
        await AccountSession.apply(null, entitlement: _entitlement);
        await _presetStore.save(const []);
        localCleared = true;
      }
      if (!mounted) return;
      setState(() {
        _user = null;
        _busy = false;
      });
      if (deleted) break;
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(strings.accountDeleteFailedTitle),
          content: Text(strings.accountDeleteFailedBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.commonClose),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.accountDeleteRetryButton),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (retry != true) return;
      setState(() => _busy = true);
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.accountDeleteSuccessTitle),
        content: Text(strings.accountDeleteSuccessBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.commonContinue),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _withdrawAiConsent() async {
    final strings = AppLocaleScope.stringsOf(context);
    await widget.consentStore.revoke();
    if (!mounted) return;
    setState(() => _aiConsentGiven = false);
    _showMessage(strings.accountWithdrawAiConsentDone);
  }

  Future<void> _openLegalLink(String url) async {
    try {
      await LegalLinks.open(url);
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocaleScope.stringsOf(context).legalLinkOpenError);
    }
  }

  Future<void> _restorePurchases() async {
    if (_restoringPurchases) return;
    setState(() => _restoringPurchases = true);
    final strings = AppLocaleScope.stringsOf(context);
    final messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      final info = await _entitlement.restorePurchases();
      final status = PremiumStatus.fromCustomerInfo(info);
      if (mounted) setState(() => _premiumStatus = status);
      message = status.isActive
          ? strings.paywallRestored
          : strings.paywallNothingToRestore;
    } catch (error) {
      debugPrint('Restore purchases failed: $error');
      message = strings.paywallRestoreFailed;
    }
    if (mounted) setState(() => _restoringPurchases = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(strings.accountScreenTitle)),
        body: _loading
            ? const Center(
                child: WeldingLoader(size: 36, bladeColor: Color(0xFF12191B)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIdentityHeader(strings),
                            const SizedBox(height: 20),
                            if (_user != null)
                              _buildSignedInState(strings)
                            else
                              _buildGuestState(strings),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumCard(strings),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.menu_book_outlined),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const UserGuideScreen(),
                          ),
                        ),
                        label: Text(
                          premiumAccountCopyFor(
                            AppLocaleScope.of(context).language,
                          ).guideRow,
                        ),
                      ),
                    ),
                    if (_aiConsentGiven) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _withdrawAiConsent,
                          child: Text(strings.accountWithdrawAiConsentButton),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _buildLegalLinks(strings),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPremiumCard(L10nStrings strings) {
    final language = AppLocaleScope.of(context).language;
    final copy = premiumAccountCopyFor(language);
    final status = _premiumStatus;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF607482),
    );
    final statusText = switch (status.state) {
      PremiumState.active => copy.statusActive,
      PremiumState.expired => copy.statusExpired,
      PremiumState.none => copy.statusNone,
    };
    final planText = switch (status.plan) {
      PremiumPlan.monthly => copy.planMonthly,
      PremiumPlan.yearly => copy.planYearly,
      PremiumPlan.unknown => copy.planUnknown,
    };
    final expiry = status.expirationDate;
    String? dateLine;
    if (expiry != null && status.state != PremiumState.none) {
      final template = status.state == PremiumState.expired
          ? copy.expiredOn
          : (status.willRenew ? copy.renewsOn : copy.endsOn);
      dateLine = template.replaceFirst(
        '{date}',
        formatCopyDate(language, expiry),
      );
    }
    final statusColor = switch (status.state) {
      PremiumState.active => const Color(0xFF1E8E5A),
      PremiumState.expired => theme.colorScheme.error,
      PremiumState.none => const Color(0xFF607482),
    };

    return Card(
      key: const Key('premium-status-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: Color(0xFFFF6A35),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    copy.cardTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: statusColor,
              ),
            ),
            if (status.state != PremiumState.none) ...[
              const SizedBox(height: 4),
              Text('${copy.planLabel}: $planText'),
            ],
            if (dateLine != null) ...[
              const SizedBox(height: 2),
              Text(dateLine),
            ],
            const SizedBox(height: 12),
            Text(copy.appleIdNote, style: muted),
            if (_user == null && status.isActive) ...[
              const SizedBox(height: 8),
              Text(copy.linkHint, style: muted),
            ],
            const SizedBox(height: 16),
            if (!status.isActive) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.workspace_premium_outlined),
                  onPressed: () => showPremiumPaywall(
                    context,
                    entitlementService: _entitlement,
                    onEntitlementChanged: (_) => _refreshPremiumStatus(),
                    offerAccountLink: false,
                  ),
                  label: Text(strings.premiumSettingsRow),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _restoringPurchases
                    ? const WeldingLoader(
                        size: 18,
                        bladeColor: Color(0xFF12191B),
                      )
                    : const Icon(Icons.restore),
                onPressed: _restoringPurchases ? null : _restorePurchases,
                label: Text(strings.paywallRestore),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    _openLegalLink(LegalLinks.manageSubscriptionsUrl),
                child: Text(strings.accountManageSubscriptionsButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityHeader(L10nStrings strings) {
    final user = _user;
    final name = (user?.displayName ?? '').trim();
    final identityLabel = user == null
        ? strings.dashboardAccountCardGuestValue
        : (name.isNotEmpty ? name : (user.email ?? ''));
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF12191B),
            border: Border.all(color: const Color(0xFFFF6A35), width: 2),
          ),
          child: const Center(child: VaryosMark(size: 26)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            identityLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSignedInState(L10nStrings strings) {
    final copy = authCopyFor(AppLocaleScope.of(context).language);
    // The identity header above already renders the display name (falling
    // back to the email when there isn't one) -- this body's job is to show
    // the account's actual identifier, the email, which is a DIFFERENT
    // string for the common named-user case. Re-deriving and rendering the
    // name here too would just duplicate the header for that case.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _user!.email ?? '',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (_user!.isVerified)
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 18,
                color: Color(0xFF1E8E5A),
              ),
              const SizedBox(width: 6),
              Text(
                copy.accountVerified,
                style: const TextStyle(
                  color: Color(0xFF1E8E5A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else ...[
          Text(
            copy.accountUnverifiedNotice,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFFB45309)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy
                  ? null
                  : () => _openAuth(
                      VerifyEmailScreen(
                        email: _user!.email ?? '',
                        entitlementService: _entitlement,
                      ),
                    ),
              child: Text(copy.accountVerifyNow),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          copy.accountSignedInNote,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: _busy ? null : _signOut,
            child: Text(strings.accountSignOutButton),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _busy ? null : _deleteAccount,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            child: _busy
                ? WeldingLoader(
                    size: 18,
                    bladeColor: Theme.of(context).colorScheme.error,
                  )
                : Text(strings.accountDeleteAccountButton),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          strings.accountSubscriptionNote,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF607482)),
        ),
        if (_busy) ...[
          const SizedBox(height: 10),
          Text(
            strings.accountDeletingMessage,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildGuestState(L10nStrings strings) {
    final copy = authCopyFor(AppLocaleScope.of(context).language);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.accountGuestStateTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          copy.accountGuestBody,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 20),
        AppleAuthButton(onPressed: _busy ? null : _appleSignIn, dark: false),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy
                ? null
                : () => _openAuth(
                    RegistrationScreen(entitlementService: _entitlement),
                  ),
            child: Text(copy.registerButton),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _busy
                ? null
                : () =>
                      _openAuth(SignInScreen(entitlementService: _entitlement)),
            child: Text(copy.signInButton),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLinks(L10nStrings strings) {
    return Wrap(
      spacing: 16,
      children: [
        TextButton(
          onPressed: () => _openLegalLink(LegalLinks.privacyPolicyUrl),
          child: Text(strings.legalPrivacyPolicyLinkLabel),
        ),
        TextButton(
          onPressed: () => _openLegalLink(LegalLinks.termsOfUseUrl),
          child: Text(strings.legalTermsOfUseLinkLabel),
        ),
      ],
    );
  }
}

/// Owns its controller as State so the framework disposes it with the
/// dialog route (see calculator_page.dart's `_PresetNameDialog`).
class _ReauthPasswordDialog extends StatefulWidget {
  const _ReauthPasswordDialog();

  @override
  State<_ReauthPasswordDialog> createState() => _ReauthPasswordDialogState();
}

class _ReauthPasswordDialogState extends State<_ReauthPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final copy = authCopyFor(AppLocaleScope.of(context).language);
    return AlertDialog(
      title: Text(copy.deleteReauthTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(copy.deleteReauthBody),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: copy.passwordLabel),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(strings.commonDelete),
        ),
      ],
    );
  }
}
