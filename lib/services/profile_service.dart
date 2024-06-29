import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl = 'https://homechef.project-moonshine.com/api';

  Future<Map<String, dynamic>> fetchProfile(String accessToken) async {
    final url = '$baseUrl/profile?token=$accessToken';
    final headers = {
      'accept': 'application/json',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> upsertProfile({
    required String accessToken,
    required String cookingSkillLevel,
    required int numPeoplePerMeal,
    required String dietaryRestrictions,
    required String healthGoals,
    required String likes,
    required String dislikes,
    required String unitWeight,
    required String unitLength,
    required String unitTemperature,
  }) async {
    final url = '$baseUrl/profile/upsert?token=$accessToken';
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'cooking_skill_level': cookingSkillLevel,
      'num_people_per_meal': numPeoplePerMeal,
      'dietary_restrictions': dietaryRestrictions,
      'health_goals': healthGoals,
      'likes': likes,
      'dislikes': dislikes,
      'unit_weight': unitWeight,
      'unit_length': unitLength,
      'unit_temperature': unitTemperature,
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upsert profile');
    }
  }
}
