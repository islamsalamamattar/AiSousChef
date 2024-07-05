// lib/services/chat_history_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  final String baseUrl = 'https://project-moonshine.com/api';

  Future<List<Map<String, dynamic>>> fetchHistory(String accessToken) async {
    final url = '$baseUrl/chat/history?token=$accessToken';
    final headers = {
      'accept': 'application/json',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      // Decode the response body as UTF-8
      final decodedResponse = utf8.decode(response.bodyBytes);
      // Parse the JSON
      final jsonResponse = jsonDecode(decodedResponse);
      return List<Map<String, dynamic>>.from(jsonResponse['messages']);
    } else {
      throw Exception('Failed to load history');
    }
  }
}
