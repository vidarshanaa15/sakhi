import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/api_client.dart'; // for ApiException

class ChatbotBackend {
  final _client = Supabase.instance.client;

  Future<String> sendMessage(String message, {List<Map<String, String>>? history}) async {
    try {
      final response = await _client.functions.invoke(
        'chatbot',
        body: {
          'message': message,
          if (history != null) 'history': history,
        },
      );

      if (response.status != 200) {
        final error = (response.data is Map && response.data['error'] != null)
            ? response.data['error'].toString()
            : 'Request failed with status ${response.status}';
        throw ApiException(error, statusCode: response.status);
      }

      final data = response.data;
      if (data is Map && data['reply'] != null) {
        return data['reply'].toString();
      }

      return '';
    } on FunctionException catch (e) {
      throw ApiException(e.details?.toString() ?? 'Edge function error', statusCode: e.status);
    } catch (e) {
      throw ApiException('Failed to reach Sakhi: $e');
    }
  }
}