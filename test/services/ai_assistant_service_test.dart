import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/models/chat_message.dart';
import 'package:weld_consumable_calculator/services/ai_assistant_config.dart';
import 'package:weld_consumable_calculator/services/ai_assistant_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  List<ChatMessage> history(int count) => List.generate(
    count,
    (i) => ChatMessage(
      role: i.isEven ? ChatRole.user : ChatRole.assistant,
      content: 'm$i',
    ),
  );

  test('sends at most 9 messages, starting with a user turn', () async {
    Map<String, dynamic>? sent;
    final service = AiAssistantService(
      client: MockClient((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'reply': 'ok'}), 200);
      }),
    );

    await service.send(messages: history(14), locale: 'en');

    final messages = (sent!['messages'] as List).cast<Map<String, dynamic>>();
    expect(messages.length, lessThanOrEqualTo(9));
    expect(messages.first['role'], 'user');
    expect(messages.last['content'], 'm13');
  });

  test('drops a leading assistant message after trimming', () {
    final trimmed = AiAssistantService.prepareMessages(history(10));
    expect(trimmed.first.role, ChatRole.user);
    expect(trimmed.length, lessThanOrEqualTo(9));
  });

  test('truncates long assistant content but not user content', () {
    final long = 'x' * 3000;
    final prepared = AiAssistantService.prepareMessages([
      ChatMessage(role: ChatRole.user, content: long),
      ChatMessage(role: ChatRole.assistant, content: long),
    ]);
    expect(prepared[0].content.length, 3000);
    expect(
      prepared[1].content.length,
      AiAssistantConfig.maxAssistantMessageLength,
    );
  });
}
