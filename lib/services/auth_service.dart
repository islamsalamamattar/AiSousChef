import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  String baseUrl = 'https://project-moonshine.com/api';

  Future<Map<String, String>> login({
    required String username,
    required String password,
  }) async {
    final url = '$baseUrl/auth/token';
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = {
      'username': username,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final token = jsonResponse['access']['token'] as String;
      final refreshToken = jsonResponse['refresh']['token'] as String;

      return {'access_token': token, 'refresh_token': refreshToken};
    } else {
      throw http.Response(response.body, response.statusCode);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final url = '$baseUrl/auth/register';
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      "imageUrl": "",
      'password': password,
      "confirm_password": password
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['detail'] ?? 'Failed to register');
    }
  }

  Future<String?> refreshToken(String refreshToken) async {
    final url =
        '$baseUrl/auth/token/refresh?refresh_token=$refreshToken'; // Include refreshToken in URL
    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final newAccessToken = jsonResponse['access_token']['token'];
      return newAccessToken;
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  Future<void> logout(String? accessToken) async {
    final url = '$baseUrl/auth/logout?token=$accessToken';
    final headers = {
      'Content-Type': 'application/json',
    };

    await http.post(
      Uri.parse(url),
      headers: headers,
    );
  }

  Future<String> forgotPassword(String email) async {
    final url = '$baseUrl/auth/forgot-password';
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['msg'];
    } else {
      throw Exception('Failed to send reset password email');
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword,
      String confirmPassword, String? accessToken) async {
    final url = Uri.parse('$baseUrl/auth/password-update?token=$accessToken');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['msg'];
    } else {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['detail'] ?? 'Failed to change password');
    }
  }

  Future<void> update({
    required String token,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    final url = Uri.parse('$baseUrl/auth/update?token=$token');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['detail'] ?? 'Failed to update user');
    }
  }
}
