/// Role of a single turn in an AI assistant conversation. Mirrors the
/// `role` field the Worker's `/chat` endpoint expects (see
/// lib/services/ai_assistant_service.dart).
enum ChatRole { user, assistant }

extension ChatRoleX on ChatRole {
  String get apiValue => switch (this) {
    ChatRole.user => 'user',
    ChatRole.assistant => 'assistant',
  };
}

/// A single message in the in-memory conversation shown by
/// lib/ui/ai_assistant_screen.dart. Not persisted across sessions -- see
/// the plan's v1 non-goals.
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final ChatRole role;
  final String content;

  Map<String, dynamic> toJson() => {
    'role': role.apiValue,
    'content': content,
  };
}
