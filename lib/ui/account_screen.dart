import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../services/legal_links.dart';
import '../services/preset_sync_service.dart';
import '../services/user_account_store.dart';
import '../services/user_preset_store.dart';
import '../services/user_preset_sync.dart';

/// Account management screen: shows the current account (email, optional
/// name), Sign Out, and Delete Account when signed in; a plain
/// email-sign-in form when in the Guest state. There is no password
/// anywhere in this app's model -- an email is simply what identifies an
/// account (see [UserAccountStore]).
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const _accountStore = UserAccountStore();
  static const _presetStore = UserPresetStore();
  static const _presetSyncService = PresetSyncService();
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _emailController = TextEditingController();

  String? _email;
  String? _firstName;
  String? _lastName;
  String? _emailError;
  bool _loading = true;
  bool _busy = false;

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
    if (!mounted) return;
    setState(() {
      _email = email;
      _firstName = firstName;
      _lastName = lastName;
      _loading = false;
    });
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
    // the same guest->account sequence in calculator_page.dart).
    await migrateLocalPresetsToAccount(
      email: email,
      presetSyncService: _presetSyncService,
      userPresetStore: _presetStore,
    );
    // Reuse the same refresh mechanism the calculator/saved-calculations
    // screens use after an account's email becomes available, so this
    // screen's sign-in has the same effect as signing in anywhere else.
    await loadSyncedUserPresets(
      email: email,
      presetSyncService: _presetSyncService,
      userPresetStore: _presetStore,
    );
    if (!mounted) return;
    setState(() {
      _email = email;
      _busy = false;
    });
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

    // Cloud presets are listed and deleted one by one -- this achieves full
    // cloud deletion with zero backend changes, reusing the existing
    // list/delete API. A failure partway through must not leave the user
    // in an ambiguous state: the local/account clear below always runs
    // regardless, and the outcome message is chosen based on whether every
    // cloud delete actually succeeded.
    var cloudFullyDeleted = true;
    try {
      final result = await _presetSyncService.list(email);
      if (result.skippedCount > 0) {
        // Rows the cloud response couldn't parse are never reached by the
        // delete loop below -- claiming full success would be dishonest.
        cloudFullyDeleted = false;
      }
      for (final preset in result.presets) {
        try {
          await _presetSyncService.delete(email, preset.id);
        } catch (_) {
          cloudFullyDeleted = false;
        }
      }
    } catch (_) {
      cloudFullyDeleted = false;
    }

    await _accountStore.clear();
    await _presetStore.save(const []);

    if (!mounted) return;
    setState(() {
      _email = null;
      _firstName = null;
      _lastName = null;
      _busy = false;
    });

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.accountDeleteSuccessTitle),
        content: Text(
          cloudFullyDeleted
              ? strings.accountDeleteSuccessBody
              : strings.accountDeletePartialFailureBody,
        ),
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

  Future<void> _openLegalLink(String url) async {
    try {
      await LegalLinks.open(url);
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocaleScope.stringsOf(context).legalLinkOpenError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.accountScreenTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_email != null)
                    _buildSignedInState(strings)
                  else
                    _buildGuestState(strings),
                  const SizedBox(height: 32),
                  _buildLegalLinks(strings),
                ],
              ),
            ),
    );
  }

  Widget _buildSignedInState(L10nStrings strings) {
    final name = [
      _firstName,
      _lastName,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty) ...[
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 4),
        ],
        Text(_email!, style: Theme.of(context).textTheme.bodyLarge),
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
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                : Text(strings.accountDeleteAccountButton),
          ),
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
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : _signIn,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
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
