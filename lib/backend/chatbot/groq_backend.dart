import '../../core/network/api_client.dart';

class GroqBackend {
  Future<String> sendMessage(String message) async {
    final response = await ApiClient.instance.post(
      '/chat',
      body: {
        'message': message,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException('Invalid response from chatbot server.');
    }

    final reply = response['reply'];

    if (reply == null || reply.toString().trim().isEmpty) {
      throw ApiException('Chatbot returned an empty response.');
    }

    return reply.toString();
  }
}