/// Configuration for the in-app AI assistant chat feature.
class AiAssistantConfig {
  const AiAssistantConfig._();

  /// Cloudflare Worker `/chat` endpoint (see the sibling `worker/` project).
  /// Backed by Cloudflare Workers AI (free tier, no separate API key).
  static const String chatApiUrl =
      'https://varyos-weld-ai-assistant.9zsv992hv9.workers.dev/chat';

  /// Must match the Worker's MAX_MESSAGE_LENGTH / MAX_HISTORY_MESSAGES.
  static const int maxMessageLength = 800;
  static const int maxHistoryMessages = 8;
}
