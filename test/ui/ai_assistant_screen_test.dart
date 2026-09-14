import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/chat_message.dart';
import 'package:weld_consumable_calculator/services/ai_assistant_service.dart';
import 'package:weld_consumable_calculator/services/entitlement_service.dart';
import 'package:weld_consumable_calculator/ui/ai_assistant_screen.dart';

/// Fake [EntitlementService] so the screen's premium/non-premium branches
/// (and the `_AiAssistantPaywallSheet`'s offering fetch) never touch the
/// real RevenueCat SDK -- same pattern as widget_test.dart's
/// `_FakeEntitlementService`.
class _FakeEntitlementService extends EntitlementService {
  _FakeEntitlementService({required this.isPremium});

  final bool isPremium;

  @override
  Future<bool> isPremiumActive() async => isPremium;

  @override
  Stream<bool> premiumStatusStream() => const Stream<bool>.empty();

  @override
  Future<Offering?> currentOffering() async => null;
}

/// Fake [AiAssistantService] so the screen's send flow never makes a real
/// network call -- see lib/services/ai_assistant_service.dart.
class _FakeAiAssistantService extends AiAssistantService {
  const _FakeAiAssistantService({this.reply, this.errorCode});

  final String? reply;
  final String? errorCode;

  @override
  Future<String> send({
    required List<ChatMessage> messages,
    required String locale,
  }) async {
    final code = errorCode;
    if (code != null) throw AiAssistantException(code);
    return reply ?? 'This is a fake assistant reply.';
  }
}

void main() {
  final strings = stringsFor(AppLanguage.en);

  // All tests below exercise the chat itself, not the AI-consent
  // disclosure (covered separately below), so they pre-seed the
  // "already acknowledged" flag -- same key AiConsentStore reads/writes.
  Future<void> pumpScreen(
    WidgetTester tester, {
    required bool isPremium,
    AiAssistantService? assistantService,
    bool consentAcknowledged = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'ai_consent_acknowledged_v1': consentAcknowledged,
    });
    final locale = AppLocale();
    await tester.pumpWidget(
      AppLocaleScope(
        locale: locale,
        child: MaterialApp(
          home: AiAssistantScreen(
            entitlementService: _FakeEntitlementService(isPremium: isPremium),
            assistantService: assistantService,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'non-premium user sees the premium gate, not the chat input',
    (tester) async {
      await pumpScreen(tester, isPremium: false);

      expect(find.text(strings.aiAssistantPremiumGateTitle), findsOneWidget);
      expect(find.text(strings.aiAssistantPremiumGateButton), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(
        find.text(strings.aiAssistantSuggestionFillerLabel),
        findsNothing,
      );
    },
  );

  testWidgets(
    'premium user sees the chat input and the 3 quick-suggestion chips',
    (tester) async {
      await pumpScreen(tester, isPremium: true);

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.text(strings.aiAssistantSuggestionFillerLabel),
        findsOneWidget,
      );
      expect(
        find.text(strings.aiAssistantSuggestionPreheatLabel),
        findsOneWidget,
      );
      expect(
        find.text(strings.aiAssistantSuggestionCoolingLabel),
        findsOneWidget,
      );
      expect(find.text(strings.aiAssistantPremiumGateTitle), findsNothing);
    },
  );

  testWidgets(
    'premium user tapping a suggestion chip sends the prompt and shows the '
    'fake reply',
    (tester) async {
      await pumpScreen(
        tester,
        isPremium: true,
        assistantService: const _FakeAiAssistantService(
          reply: 'Fake filler calculator explanation.',
        ),
      );

      await tester.tap(find.text(strings.aiAssistantSuggestionFillerLabel));
      await tester.pumpAndSettle();

      expect(
        find.text(strings.aiAssistantSuggestionFillerPrompt),
        findsOneWidget,
      );
      expect(find.text('Fake filler calculator explanation.'), findsOneWidget);
    },
  );

  testWidgets(
    'a rate-limited error from the assistant service shows the localized '
    'rate-limit message instead of the reply',
    (tester) async {
      await pumpScreen(
        tester,
        isPremium: true,
        assistantService: const _FakeAiAssistantService(
          errorCode: 'rate_limited',
        ),
      );

      await tester.tap(find.text(strings.aiAssistantSuggestionPreheatLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.aiAssistantErrorRateLimited), findsOneWidget);
    },
  );

  testWidgets(
    'typing into the input field and submitting sends the typed message',
    (tester) async {
      await pumpScreen(
        tester,
        isPremium: true,
        assistantService: const _FakeAiAssistantService(
          reply: 'Reply to a typed question.',
        ),
      );

      await tester.enterText(find.byType(TextField), 'What is CET?');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('What is CET?'), findsOneWidget);
      expect(find.text('Reply to a typed question.'), findsOneWidget);
    },
  );

  testWidgets(
    'a premium user on first entry sees the AI-consent disclosure instead '
    'of the chat input (Apple 5.1.2(i) / Google Play AI-disclosure policy)',
    (tester) async {
      await pumpScreen(tester, isPremium: true, consentAcknowledged: false);

      expect(find.text(strings.aiAssistantConsentTitle), findsOneWidget);
      expect(find.text(strings.aiAssistantConsentButton), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets(
    'acknowledging the AI-consent disclosure reveals the normal chat input, '
    'and a fresh screen instance with the flag already set skips the '
    'disclosure entirely',
    (tester) async {
      await pumpScreen(tester, isPremium: true, consentAcknowledged: false);

      await tester.tap(find.text(strings.aiAssistantConsentButton));
      await tester.pumpAndSettle();

      expect(find.text(strings.aiAssistantConsentTitle), findsNothing);
      expect(find.byType(TextField), findsOneWidget);

      // Simulate relaunching the screen now that markAcknowledged() has
      // persisted the flag -- a fresh instance should go straight to the
      // normal chat input without re-showing the disclosure.
      await pumpScreen(tester, isPremium: true, consentAcknowledged: true);

      expect(find.text(strings.aiAssistantConsentTitle), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    },
  );
}
