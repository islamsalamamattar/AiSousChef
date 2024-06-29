// screens/login.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'home.dart';
import 'welcome.dart';
import 'forgot_password.dart'; // Add this import

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _accessToken; // State variable to hold access token
  final ProfileService _profileService = ProfileService();

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final tokens =
          await _authService.login(username: username, password: password);
      final accessToken = tokens['access_token'];
      final refreshToken = tokens['refresh_token'];

      if (accessToken == null || refreshToken == null) {
        throw Exception('Access or Refresh token is null');
      }

      // Save refresh token to secure storage
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);

      // Save access token to state
      setState(() {
        _accessToken = accessToken;
      });

      // Fetch user profile
      final profile = await _profileService.fetchProfile(accessToken);
      final hasCompletedOnboarding = profile['Onboraded'] == true;

      if (hasCompletedOnboarding) {
        // Navigate to HomeScreen if onboarding is complete
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => HomePage(accessToken: _accessToken!),
          ),
        );
      } else {
        // Navigate to OnboardingScreen if onboarding is not complete
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => WelcomePage(accessToken: _accessToken!),
          ),
        );
      }
    } catch (e) {
      // Handle login error
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Login Failed'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ForgotPasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please log in to continue.',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
            SizedBox(height: 30),
            CupertinoTextField(
              controller: _usernameController,
              placeholder: 'Username',
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text('Login'),
              onPressed: _handleLogin,
            ),
            SizedBox(height: 10),
            CupertinoButton(
              child: Text('Forgot Password?'),
              onPressed: _navigateToForgotPassword,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
