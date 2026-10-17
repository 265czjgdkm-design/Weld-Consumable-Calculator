/// Configuration for the in-app AI assistant chat feature.
class AiAssistantConfig {
  const AiAssistantConfig._();

  /// Cloudflare Worker `/chat` endpoint (see the sibling `worker/` project).
  /// Backed by Cloudflare Workers AI (free tier, no separate API key).
  static const String chatApiUrl =
      'https://varyos-weld-ai-assistant.9zsv992hv9.workers.dev/chat';

  /// Max visible characters the user can type. The Worker limits UTF-16
  /// code units (2000), which is larger so emoji/Hindi still fit.
  static const int maxMessageLength = 800;

  /// Odd so the trimmed history starts with a user turn; Worker uses the same.
  static const int maxHistoryMessages = 9;

  /// Worker truncates (never rejects) assistant history beyond this.
  static const int maxAssistantMessageLength = 2000;
}
