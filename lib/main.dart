// main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/home.dart';
import 'screens/landing.dart';
import 'screens/login.dart';
import 'screens/change_password.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = const FlutterSecureStorage();
  final authService = AuthService();

  final refreshToken = await storage.read(key: 'refresh_token');

  runApp(AiSousChefApp(refreshToken: refreshToken, authService: authService));
}

class AiSousChefApp extends StatefulWidget {
  final String? refreshToken;
  final AuthService authService;

  AiSousChefApp({required this.refreshToken, required this.authService});

  @override
  _AiSousChefAppState createState() => _AiSousChefAppState();
}

class _AiSousChefAppState extends State<AiSousChefApp> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _refreshAccessToken();
  }

  Future<void> _refreshAccessToken() async {
    if (widget.refreshToken != null) {
      try {
        final newAccessToken =
            await widget.authService.refreshToken(widget.refreshToken!);
        setState(() {
          _accessToken = newAccessToken;
        });
      } catch (e) {
        print('RefreshToken error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'AI Sous',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemGrey,
        brightness: Brightness.dark, // Force dark mode
      ),
      home: CupertinoPageScaffold(
        child: _accessToken != null
            ? HomePage(accessToken: _accessToken!)
            : LandingPage(),
      ),
      routes: {
        '/home': (context) => HomePage(accessToken: _accessToken),
        '/login': (context) => LoginPage(),
        '/landing': (context) => LandingPage(),
        '/change-password': (context) => ChangePasswordPage(),
      },
    );
  }
}
