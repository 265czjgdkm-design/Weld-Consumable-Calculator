import 'package:flutter/material.dart';

import '../../services/entitlement_service.dart';
import 'auth_flows.dart';
import 'auth_screens.dart';
import 'auth_widgets.dart';

/// Full-height but dismissible sheet inviting a guest to create an account:
/// Apple / email sign-up / sign in / "Not now". Used after a guest purchase
/// and when a guest tries to save a preset. Resolves to how the flow ended.
Future<AuthOutcome> showAccountPrompt(
  BuildContext context, {
  required String title,
  required String body,
  EntitlementService? entitlementService,
  String initialEmail = '',
}) async {
  final outcome = await showModalBottomSheet<AuthOutcome>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF0B0F10),
    builder: (_) => _AccountPromptSheet(
      title: title,
      body: body,
      entitlementService: entitlementService,
      initialEmail: initialEmail,
    ),
  );
  return outcome ?? AuthOutcome.none;
}

class _AccountPromptSheet extends StatefulWidget {
  const _AccountPromptSheet({
    required this.title,
    required this.body,
    this.entitlementService,
    this.initialEmail = '',
  });

  final String title;
  final String body;
  final EntitlementService? entitlementService;
  final String initialEmail;

  @override
  State<_AccountPromptSheet> createState() => _AccountPromptSheetState();
}

class _AccountPromptSheetState extends State<_AccountPromptSheet> {
  Future<void> _push(Widget screen) async {
    final outcome = await Navigator.of(
      context,
    ).push<AuthOutcome>(MaterialPageRoute(builder: (_) => screen));
    if (!mounted || outcome == null || outcome == AuthOutcome.none) return;
    Navigator.of(context).pop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    final copy = authCopyOf(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () =>
                        Navigator.of(context).pop(AuthOutcome.none),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const MarkWithBloom(markSize: 44, bloomSize: 140),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFAEB8BB),
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                AuthPrimaryButton(
                  label: copy.registerButton,
                  onPressed: () => _push(
                    RegistrationScreen(
                      entitlementService: widget.entitlementService,
                      initialEmail: widget.initialEmail,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _push(
                    SignInScreen(
                      entitlementService: widget.entitlementService,
                      initialEmail: widget.initialEmail,
                    ),
                  ),
                  child: Text(
                    copy.signInButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(AuthOutcome.none),
                  child: Text(
                    copy.sheetNotNow,
                    style: const TextStyle(color: Color(0xFFAEB8BB)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
