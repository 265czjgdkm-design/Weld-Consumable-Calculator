import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/premium_account_copy.dart';
import '../l10n/strings.dart';
import '../services/account_deletion_service.dart';
import '../services/ai_consent_store.dart';
import '../services/entitlement_service.dart';
import '../services/legal_links.dart';
import '../services/preset_sync_service.dart';
import '../services/user_account_store.dart';
import '../services/user_preset_store.dart';
import '../services/user_preset_sync.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'premium_paywall.dart';
import 'user_guide_screen.dart';
import 'widgets/welding_loader.dart';

/// Account management screen: shows the current account (email, optional
/// name), Sign Out, and Delete Account when signed in; a plain
/// email-sign-in form when in the Guest state. There is no password
/// anywhere in this app's model -- an email is simply what identifies an
/// account (see [UserAccountStore]).
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
  static const _accountStore = UserAccountStore();
  static const _presetStore = UserPresetStore();
  static const _presetSyncService = PresetSyncService();
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _emailController = TextEditingController();
  late final EntitlementService _entitlement =
      widget.entitlementService ?? EntitlementService();
  PremiumStatus _premiumStatus = const PremiumStatus();

  String? _email;
  String? _firstName;
  String? _lastName;
  String? _emailError;
  bool _loading = true;
  bool _busy = false;
  bool _restoringPurchases = false;
  bool _aiConsentGiven = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final email = await _accountStore.getEmail();
    final firstName = await _accountStore.getFirstName();
    final lastName = await _accountStore.getLastName();
    final aiConsentGiven = await widget.consentStore.isAcknowledged();
    if (!mounted) return;
    setState(() {
      _aiConsentGiven = aiConsentGiven;
      _email = email;
      _firstName = firstName;
      _lastName = lastName;
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

  /// Fire-and-forget from the UI: RevenueCat calls must never hold up
  /// sign-in/out, and the premium card refreshes once the id switch lands.
  Future<void> _syncAccountAndRefresh(String? email) async {
    await _entitlement.syncAccount(email);
    await _refreshPremiumStatus();
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
    await _accountStore.clear();
    if (!mounted) return;
    setState(() {
      _email = null;
      _firstName = null;
      _lastName = null;
    });
    _showMessage(strings.accountSignOutSuccess);
    unawaited(_syncAccountAndRefresh(null));
  }

  Future<void> _signIn() async {
    final strings = AppLocaleScope.stringsOf(context);
    final email = _emailController.text.trim().toLowerCase();
    setState(() {
      _emailError = _emailPattern.hasMatch(email)
          ? null
          : strings.emailGateInvalidEmail;
    });
    if (_emailError != null) return;

    setState(() => _busy = true);
    await _accountStore.setEmail(email);
    // A device that already has local-only presets must have them uploaded
    // to the cloud under this email BEFORE the cloud-authoritative refresh
    // below, or an empty/partial cloud list would silently wipe them (see
    // the same guest->account sequence in calculator_page.dart). This is a
    // no-op (and uploads nothing) if the local cache belongs to a
    // different, previously signed-in account -- see the doc comment on
    // migrateLocalPresetsToAccount.
    final migrated = await migrateLocalPresetsToAccount(
      email: email,
      presetSyncService: _presetSyncService,
      userPresetStore: _presetStore,
    );
    // A failed upload must not be followed by the cloud-authoritative
    // refresh below, or the not-yet-uploaded local presets would be wiped
    // by a cloud list that doesn't reflect them yet.
    if (migrated) {
      // Reuse the same refresh mechanism the calculator/saved-calculations
      // screens use after an account's email becomes available, so this
      // screen's sign-in has the same effect as signing in anywhere else.
      await loadSyncedUserPresets(
        email: email,
        presetSyncService: _presetSyncService,
        userPresetStore: _presetStore,
      );
    }
    if (!mounted) return;
    setState(() {
      _email = email;
      _busy = false;
    });
    unawaited(_syncAccountAndRefresh(email));
    _showMessage(strings.accountSignInSuccess.replaceFirst('{email}', email));
  }

  Future<void> _deleteAccount() async {
    final strings = AppLocaleScope.stringsOf(context);
    final email = _email;
    if (email == null) return;

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
    if (confirmed != true) return;

    setState(() => _busy = true);

    // The screen stays signed-in (with the "Deleting..." message, and back
    // navigation blocked via PopScope) until the server answers. Local data
    // is then cleared regardless of the outcome; the email is kept in a
    // local variable so Retry can still address it.
    var deleted = false;
    var localCleared = false;
    while (true) {
      try {
        await widget.accountDeletionService.deleteAccount(email);
        deleted = true;
      } catch (_) {
        deleted = false;
      }
      if (!localCleared) {
        await _accountStore.clear();
        await _presetStore.save(const []);
        unawaited(_entitlement.syncAccount(null));
        localCleared = true;
      }
      if (!mounted) return;
      setState(() {
        _email = null;
        _firstName = null;
        _lastName = null;
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
                            if (_email != null)
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
            if (_email == null && status.isActive) ...[
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
    final name = [
      _firstName,
      _lastName,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
    final identityLabel = _email == null
        ? strings.dashboardAccountCardGuestValue
        : (name.isNotEmpty ? name : _email!);
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
        Text(identityLabel, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  Widget _buildSignedInState(L10nStrings strings) {
    // The identity header above already renders the display name (falling
    // back to the email when there isn't one) -- this body's job is to show
    // the account's actual identifier, the email, which is a DIFFERENT
    // string for the common named-user case. Re-deriving and rendering the
    // name here too would just duplicate the header for that case.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _email!,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          strings.accountNoPasswordNotice,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.accountGuestStateTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          strings.accountGuestStateBody,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _signIn(),
          decoration: InputDecoration(
            labelText: strings.accountSignInEmailLabel,
            hintText: strings.emailGateHint,
            errorText: _emailError,
            filled: true,
            fillColor: const Color(0xFFF1F5F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : _signIn,
            child: _busy
                ? const WeldingLoader(size: 18)
                : Text(strings.accountSignInButton),
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
