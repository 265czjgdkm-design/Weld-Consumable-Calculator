import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import 'ai_assistant_config.dart';

/// Thrown by [AiAssistantService.send] with the Worker's own error code
/// (`rate_limited` | `bad_request` | `upstream_error` | `timeout`, or
/// `network_error` for a local failure) so the UI can show a tailored
/// message -- see lib/ui/ai_assistant_screen.dart.
class AiAssistantException implements Exception {
  const AiAssistantException(this.code);

  final String code;
}

/// Talks to the Cloudflare Worker `/chat` endpoint (see the sibling
/// `worker/` project and lib/services/ai_assistant_config.dart). Stateless
/// on the server side -- every call resends the full conversation so far.
/// Same `http.post` + timeout + JSON decode/error style as
/// [PresetSyncService].
class AiAssistantService {
  const AiAssistantService();

  static const _clientIdKey = 'ai_assistant_client_id_v1';

  Future<String> send({
    required List<ChatMessage> messages,
    required String locale,
  }) async {
    final clientId = await _getOrCreateClientId();
    final response = await http
        .post(
          Uri.parse(AiAssistantConfig.chatApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Client-Id': clientId,
          },
          body: jsonEncode({
            'messages': messages.map((message) => message.toJson()).toList(),
            'locale': locale,
          }),
        )
        .timeout(const Duration(seconds: 30));
    final body = _decode(response.body);
    final reply = body['reply'];
    if (reply is String) return reply;
    throw AiAssistantException(
      body['error']?.toString() ?? 'upstream_error',
    );
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) throw const FormatException('Unexpected response.');
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw const AiAssistantException('upstream_error');
    }
  }

  Future<String> _getOrCreateClientId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_clientIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _generateClientId();
    await prefs.setString(_clientIdKey, generated);
    return generated;
  }

  /// A UUID-v4-shaped random id. There's no `uuid` package dependency in
  /// this project, so this builds the same hyphenated hex layout by hand
  /// from `Random.secure()` rather than adding one just for a rate-limiting
  /// header value.
  String _generateClientId() {
    final random = Random.secure();
    String hex(int byteCount) {
      final bytes = List<int>.generate(byteCount, (_) => random.nextInt(256));
      return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    }

    return '${hex(4)}-${hex(2)}-${hex(2)}-${hex(2)}-${hex(6)}';
  }
}
