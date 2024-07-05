import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  final String baseUrl = 'https://project-moonshine.com/api';

  Future<List<dynamic>> fetchRecipes(String accessToken) async {
    final url = '$baseUrl/recipes?token=$accessToken';
    final headers = {
      'accept': 'application/json',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Ensure a list is returned, even if the response is empty or null
      if (jsonResponse is List) {
        return jsonResponse;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(String accessToken, int recipeId) async {
    final url = '$baseUrl/recipes/$recipeId?token=$accessToken';
    final headers = {
      'accept': 'application/json',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
