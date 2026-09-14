import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/app_language.dart';
import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../models/chat_message.dart';
import '../services/ai_assistant_service.dart';
import '../services/ai_consent_store.dart';
import '../services/entitlement_service.dart';
import '../services/purchases_config.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'widgets/welding_loader.dart';

/// In-app AI chat that answers questions about this app's calculators and
/// general welding-standard concepts (see the implementation plan's
/// systemPrompt.ts for the exact scope/copyright rules the Worker enforces
/// server-side). Premium-gated the same way PDF export is gated in
/// calculator_page.dart -- see [EntitlementService].
class AiAssistantScreen extends StatefulWidget {
  AiAssistantScreen({
    super.key,
    EntitlementService? entitlementService,
    AiAssistantService? assistantService,
    AiConsentStore? consentStore,
  }) : entitlementService = entitlementService ?? EntitlementService(),
       assistantService = assistantService ?? const AiAssistantService(),
       consentStore = consentStore ?? const AiConsentStore();

  final EntitlementService entitlementService;
  final AiAssistantService assistantService;
  final AiConsentStore consentStore;

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  bool _isPremium = false;
  bool _isSending = false;
  bool _consentAcknowledged = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<bool>? _premiumStatusSubscription;

  @override
  void initState() {
    super.initState();
    _initEntitlement();
    _initConsent();
  }

  Future<void> _initConsent() async {
    final acknowledged = await widget.consentStore.isAcknowledged();
    if (!mounted) return;
    setState(() => _consentAcknowledged = acknowledged);
  }

  Future<void> _acknowledgeConsent() async {
    await widget.consentStore.markAcknowledged();
    if (!mounted) return;
    setState(() => _consentAcknowledged = true);
  }

  Future<void> _initEntitlement() async {
    try {
      final isPremium = await widget.entitlementService.isPremiumActive();
      if (!mounted) return;
      setState(() => _isPremium = isPremium);
    } catch (error) {
      debugPrint('Failed to read entitlement status: $error');
    }
    // Same defensive re-check as CalculatorPage._initEntitlement: dispose()
    // may already have run while the call above was in flight.
    if (!mounted) return;
    _premiumStatusSubscription = widget.entitlementService
        .premiumStatusStream()
        .listen((isPremium) {
          if (!mounted) return;
          setState(() => _isPremium = isPremium);
        });
  }

  @override
  void dispose() {
    _premiumStatusSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending || !_consentAcknowledged) return;
    final strings = AppLocaleScope.stringsOf(context);
    final locale = AppLocaleScope.of(context).language.code;

    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, content: trimmed));
      _isSending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final reply = await widget.assistantService.send(
        messages: _messages,
        locale: locale,
      );
      if (!mounted) return;
      setState(
        () => _messages.add(ChatMessage(role: ChatRole.assistant, content: reply)),
      );
    } catch (error) {
      if (!mounted) return;
      final code = error is AiAssistantException ? error.code : 'network_error';
      _showMessage(_errorMessageFor(strings, code));
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  String _errorMessageFor(L10nStrings strings, String code) => switch (code) {
    'rate_limited' => strings.aiAssistantErrorRateLimited,
    'bad_request' => strings.aiAssistantErrorBadRequest,
    'timeout' => strings.aiAssistantErrorTimeout,
    'network_error' => strings.aiAssistantErrorNetwork,
    _ => strings.aiAssistantErrorUpstream,
  };

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackToDashboardButton(),
                    const TopNavigationBar(),
                    const SizedBox(height: 24),
                    Text(
                      strings.aiAssistantScreenTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.aiAssistantScreenSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF607482),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isPremium
                          ? _buildChat(strings)
                          : _buildPremiumGate(strings),
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

  Widget _buildChat(L10nStrings strings) {
    if (!_consentAcknowledged) {
      return _buildConsentGate(strings);
    }
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildSuggestions(strings)
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _MessageBubble(message: _messages[index]),
                ),
        ),
        if (_isSending)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: WeldingLoader(size: 18, bladeColor: Color(0xFF12191B)),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                enabled: !_isSending,
                decoration: InputDecoration(
                  hintText: strings.aiAssistantInputHint,
                ),
                onSubmitted: _send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isSending ? null : () => _send(_inputController.text),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestions(L10nStrings strings) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          ActionChip(
            label: Text(strings.aiAssistantSuggestionFillerLabel),
            onPressed: () => _send(strings.aiAssistantSuggestionFillerPrompt),
          ),
          ActionChip(
            label: Text(strings.aiAssistantSuggestionPreheatLabel),
            onPressed: () => _send(strings.aiAssistantSuggestionPreheatPrompt),
          ),
          ActionChip(
            label: Text(strings.aiAssistantSuggestionCoolingLabel),
            onPressed: () => _send(strings.aiAssistantSuggestionCoolingPrompt),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentGate(L10nStrings strings) {
    // Same scrollable-card shape as _buildPremiumGate below -- see that
    // method's comment for why this can't just be Center-ed.
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    size: 40,
                    color: Color(0xFF12191B),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.aiAssistantConsentTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.aiAssistantConsentBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF607482),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _acknowledgeConsent,
                    child: Text(strings.aiAssistantConsentButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumGate(L10nStrings strings) {
    // A non-scrollable Expanded ancestor gives this a fixed height -- on a
    // short viewport (small phone, or a phone in landscape) the card's
    // natural content height can exceed that, so this needs to be
    // scrollable rather than just Center-ed to avoid a RenderFlex overflow.
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 40,
                    color: Color(0xFFFF6A35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.aiAssistantPremiumGateTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.aiAssistantPremiumGateBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF607482),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => showAiAssistantPaywall(
                      context,
                      entitlementService: widget.entitlementService,
                      onEntitlementChanged: (isPremium) {
                        if (!mounted) return;
                        setState(() => _isPremium = isPremium);
                      },
                    ),
                    child: Text(strings.aiAssistantPremiumGateButton),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF12191B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: const Color(0xFFDCE5EB)),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF12191B),
          ),
        ),
      ),
    );
  }
}

/// Opens a trimmed-down premium paywall for the AI assistant. Kept separate
/// from calculator_page.dart's private `_PaywallSheet` (that one stays
/// private/untouched) since this needs to be reachable both from
/// home_dashboard_screen.dart (gate before navigating) and from this
/// screen's own in-place gate above -- duplicating the small purchase/
/// restore flow here once is simpler than making the calculator page's
/// sheet cross-file-shared for a single other call site.
Future<void> showAiAssistantPaywall(
  BuildContext context, {
  required EntitlementService entitlementService,
  required ValueChanged<bool> onEntitlementChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _AiAssistantPaywallSheet(
      entitlementService: entitlementService,
      onEntitlementChanged: onEntitlementChanged,
    ),
  );
}

class _AiAssistantPaywallSheet extends StatefulWidget {
  const _AiAssistantPaywallSheet({
    required this.entitlementService,
    required this.onEntitlementChanged,
  });

  final EntitlementService entitlementService;
  final ValueChanged<bool> onEntitlementChanged;

  @override
  State<_AiAssistantPaywallSheet> createState() =>
      _AiAssistantPaywallSheetState();
}

class _AiAssistantPaywallSheetState extends State<_AiAssistantPaywallSheet> {
  Offering? _offering;
  bool _loadingOffering = true;
  String? _purchasingPackageId;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    Offering? offering;
    try {
      offering = await widget.entitlementService.currentOffering();
    } catch (error) {
      debugPrint('Failed to load RevenueCat offering: $error');
    }
    if (!mounted) return;
    setState(() {
      _offering = offering;
      _loadingOffering = false;
    });
  }

  Package? _resolveMonthly(Offering offering) =>
      offering.monthly ?? offering.getPackage(PurchasesConfig.monthlyPackageId);
  Package? _resolveYearly(Offering offering) =>
      offering.annual ?? offering.getPackage(PurchasesConfig.yearlyPackageId);

  Package? get _monthlyPackage {
    final offering = _offering;
    return offering == null ? null : _resolveMonthly(offering);
  }

  Package? get _yearlyPackage {
    final offering = _offering;
    return offering == null ? null : _resolveYearly(offering);
  }

  bool get _hasAnyPackage => _monthlyPackage != null || _yearlyPackage != null;

  bool _isEntitlementActive(CustomerInfo customerInfo) => customerInfo
      .entitlements
      .active
      .containsKey(PurchasesConfig.entitlementId);

  void _dismissSheetIfCurrent(NavigatorState navigator, ModalRoute? route) {
    if (route?.isCurrent ?? false) navigator.pop();
  }

  Future<void> _purchase(Package package) async {
    setState(() => _purchasingPackageId = package.identifier);
    final navigator = Navigator.of(context);
    final sheetRoute = ModalRoute.of(context);
    try {
      final customerInfo = await widget.entitlementService.purchasePackage(
        package,
      );
      final isActive = _isEntitlementActive(customerInfo);
      widget.onEntitlementChanged(isActive);
      if (!mounted) return;
      _dismissSheetIfCurrent(navigator, sheetRoute);
      return;
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError) {
        // User backed out of the store sheet -- not an error worth surfacing.
      } else if (mounted) {
        _dismissSheetIfCurrent(navigator, sheetRoute);
      }
    } catch (_) {
      if (mounted) _dismissSheetIfCurrent(navigator, sheetRoute);
    }
    if (mounted) setState(() => _purchasingPackageId = null);
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    final navigator = Navigator.of(context);
    final sheetRoute = ModalRoute.of(context);
    try {
      final customerInfo = await widget.entitlementService.restorePurchases();
      final isActive = _isEntitlementActive(customerInfo);
      widget.onEntitlementChanged(isActive);
      if (!mounted) return;
      _dismissSheetIfCurrent(navigator, sheetRoute);
    } catch (_) {
      if (mounted) _dismissSheetIfCurrent(navigator, sheetRoute);
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Widget _buildPurchaseButton({
    required String label,
    required Package package,
  }) {
    final busy = _purchasingPackageId == package.identifier;
    final disabled = _purchasingPackageId != null || _restoring;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: disabled ? null : () => _purchase(package),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF12191B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: busy
            ? const WeldingLoader(size: 18, bladeColor: Colors.white)
            : Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD2DCE3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFFFF6A35),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Varyos Weld Premium',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Unlimited AI assistant Q&A on your calculations'),
            const SizedBox(height: 10),
            const Text('Client-ready PDF export for every estimate'),
            const SizedBox(height: 10),
            const Text('Cancel anytime from Settings'),
            const SizedBox(height: 22),
            if (_loadingOffering)
              const Center(
                child: WeldingLoader(size: 36, bladeColor: Color(0xFF12191B)),
              )
            else if (_hasAnyPackage) ...[
              if (_monthlyPackage != null) ...[
                _buildPurchaseButton(
                  label: 'Monthly -- \$2.99/mo',
                  package: _monthlyPackage!,
                ),
                if (_yearlyPackage != null) const SizedBox(height: 10),
              ],
              if (_yearlyPackage != null)
                _buildPurchaseButton(
                  label: 'Yearly -- \$19.99/yr (save ~44%)',
                  package: _yearlyPackage!,
                ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Premium -- Coming Soon'),
                ),
              ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: (_restoring || _purchasingPackageId != null)
                    ? null
                    : _restore,
                child: _restoring
                    ? const WeldingLoader(
                        size: 18,
                        bladeColor: Color(0xFF12191B),
                      )
                    : const Text('Restore Purchases'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
