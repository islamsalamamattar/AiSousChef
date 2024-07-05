// lib/screens/change_password.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String? accessToken;

  ChangePasswordPage({required this.accessToken});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  void _handleChangePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (widget.accessToken == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Access token not found. Please log in again.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    if (newPassword != confirmNewPassword) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Passwords do not match'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    if (!_validatePassword(newPassword)) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(
              'Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final message = await _authService.changePassword(
        oldPassword,
        newPassword,
        confirmNewPassword,
        widget.accessToken,
      );

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to ProfilePage
              },
            ),
          ],
        ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Change Password Failed'),
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

  bool _validatePassword(String password) {
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])[A-Za-z\d!@#\$%\^&\*]{8,}$');
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Change Password'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CupertinoTextField(
              controller: _oldPasswordController,
              placeholder: 'Old Password',
              obscureText: true,
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _newPasswordController,
              placeholder: 'New Password',
              obscureText: true,
              onChanged: (password) {
                setState(
                    () {}); // Trigger a rebuild to update the password strength meter
              },
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _confirmNewPasswordController,
              placeholder: 'Confirm New Password',
              obscureText: true,
            ),
            SizedBox(height: 10),
            PasswordStrengthMeter(password: _newPasswordController.text),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                child: Text('Change Password'),
                onPressed: _handleChangePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  PasswordStrengthMeter({required this.password});

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 10) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$%\^&\*]').hasMatch(password)) strength++;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    final double meterWidth =
        MediaQuery.of(context).size.width * 0.6; // 60% of the app width
    int strength = _calculatePasswordStrength(password);

    String strengthText;
    Color strengthColor;
    switch (strength) {
      case 0:
      case 1:
        strengthText = 'Very Weak';
        strengthColor = Colors.red;
        break;
      case 2:
        strengthText = 'Weak';
        strengthColor = Colors.orange;
        break;
      case 3:
        strengthText = 'Fair';
        strengthColor = Colors.yellow;
        break;
      case 4:
        strengthText = 'Good';
        strengthColor = Colors.lightGreen;
        break;
      case 5:
        strengthText = 'Strong';
        strengthColor = Colors.green;
        break;
      default:
        strengthText = '';
        strengthColor = Colors.transparent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password Strength: $strengthText',
            style: TextStyle(color: strengthColor)),
        Container(
          width: meterWidth,
          child: LinearProgressIndicator(
            value: strength / 5,
            backgroundColor: Colors.grey[300],
            color: strengthColor,
          ),
        ),
      ],
    );
  }
}
