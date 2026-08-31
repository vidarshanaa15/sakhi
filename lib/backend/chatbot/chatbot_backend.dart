import 'groq_backend.dart';

class ChatbotBackend {
  final GroqBackend _groqBackend = GroqBackend();

  Future<String> sendMessage(String message) {
    return _groqBackend.sendMessage(message);
  }
}