// lib/services/chat_message_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessageService {
  final String baseUrl = 'https://project-moonshine.com/api';

  Future<Map<String, dynamic>> sendMessage(String accessToken, String message) async {
    final url = '$baseUrl/chat?token=$accessToken&message=$message';
    final headers = {
      'accept': 'application/json',
    };

    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      // Decode the response body as UTF-8
      final decodedResponse = utf8.decode(response.bodyBytes);
      // Parse the JSON
      return jsonDecode(decodedResponse);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
