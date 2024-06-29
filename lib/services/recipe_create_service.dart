// services/recipe_create_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeCreateService {
  final String baseUrl = 'https://homechef.project-moonshine.com/api';

  Future<Map<String, dynamic>> createRecipe(
      String accessToken, String interactionId) async {
    final url =
        '$baseUrl/recipes/create?token=$accessToken&interaction_id=$interactionId';
    final headers = {
      'accept': 'application/json',
    };

    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to create recipe');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
