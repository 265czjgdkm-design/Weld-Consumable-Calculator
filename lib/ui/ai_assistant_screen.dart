import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_language.dart';
import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../models/chat_message.dart';
import '../services/ai_assistant_config.dart';
import '../services/ai_assistant_service.dart';
import '../services/ai_consent_store.dart';
import '../services/entitlement_service.dart';
import '../services/legal_links.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'premium_paywall.dart';
import 'widgets/welding_loader.dart';

/// In-app AI chat that answers questions about this app's three calculators
/// only (see the Worker's systemPrompt.ts for the scope/copyright rules it
/// enforces server-side). Premium-gated the same way PDF export is gated in
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

  Future<void> _openPrivacyPolicy() async {
    try {
      await LegalLinks.open(LegalLinks.privacyPolicyUrl);
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocaleScope.stringsOf(context).legalLinkOpenError);
    }
  }

  // "Not now": leave the screen without storing any consent.
  void _declineConsent() => Navigator.of(context).maybePop();

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
        () => _messages.add(
          ChatMessage(role: ChatRole.assistant, content: reply),
        ),
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
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    AiAssistantConfig.maxMessageLength,
                  ),
                ],
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
          ActionChip(
            label: Text(strings.aiAssistantSuggestionResultLabel),
            onPressed: () => _send(strings.aiAssistantSuggestionResultPrompt),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentGate(L10nStrings strings) {
    // The disclosure text scrolls; the two decision buttons are pinned in a
    // bottom bar so they are always visible (long copy, small phones, and
    // longer locales like TR/RU would otherwise push them below the fold).
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.privacy_tip_outlined,
                          size: 36,
                          color: Color(0xFF12191B),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.aiAssistantConsentTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.aiAssistantConsentBody,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF607482)),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: _openPrivacyPolicy,
                          child: Text(strings.legalPrivacyPolicyLinkLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _acknowledgeConsent,
                        child: Text(strings.aiAssistantConsentButton),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _declineConsent,
                        child: Text(strings.aiAssistantConsentDecline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
                    onPressed: () => showPremiumPaywall(
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
