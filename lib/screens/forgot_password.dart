// screens/forgot_password.dart
import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import 'login.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    try {
      final message = await _authService.forgotPassword(email);
      // Show success dialog and navigate to login
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Status'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle error
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Failed'),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Forgot Password'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoTextField(
              controller: _emailController,
              placeholder: 'Email',
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text('Reset Password'),
              onPressed: _handleForgotPassword,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
