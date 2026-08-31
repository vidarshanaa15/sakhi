import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/chat_message.dart';

class ChatHistoryRepository {
  final _client = Supabase.instance.client;

  /// Returns the most recent session's id, or null if the user has none yet.
  Future<String?> getLatestSessionId(String userId) async {
    final row = await _client
        .from('chat_sessions')
        .select('id')
        .eq('userid', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return row?['id'] as String?;
  }

  Future<String> createSession(String userId) async {
    final row = await _client
        .from('chat_sessions')
        .insert({'userid': userId})
        .select('id')
        .single();

    return row['id'] as String;
  }

  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    final rows = await _client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (rows as List)
        .map((row) => ChatMessage(
              text: row['text'] as String,
              isUser: row['is_user'] as bool,
            ))
        .toList();
  }

  Future<void> saveMessage({
    required String sessionId,
    required String userId,
    required String text,
    required bool isUser,
  }) async {
    await _client.from('chat_messages').insert({
      'session_id': sessionId,
      'userid': userId,
      'text': text,
      'is_user': isUser,
    });
  }
}