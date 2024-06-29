// lib/screens/register.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import the AuthService
import '../screens/login.dart'; // Import the LoginPage

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  void _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Email validation
    final emailValid = _validateEmail(email);
    if (!emailValid) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Invalid email format'),
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

    // Password match validation
    if (password != confirmPassword) {
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
    
    // Password validation
    final passwordValid = _validatePassword(password);
    if (!passwordValid) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.'),
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
      await _authService.register(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
      );

      // Navigate to LoginPage after successful registration
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      // Handle registration error
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Registration Failed'),
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

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])[A-Za-z\d!@#\$%\^&\*]{8,}$');
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Register'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Welcome To AI Sous Chef!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please fill in the details below to register.',
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
              controller: _emailController,
              placeholder: 'Email',
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _firstNameController,
              placeholder: 'First Name',
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _lastNameController,
              placeholder: 'Last Name',
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: 'Password',
              obscureText: true,
              onChanged: (password) {
                setState(() {}); // Trigger a rebuild to update the password strength meter
              },
            ),
            SizedBox(height: 10),
            PasswordStrengthMeter(password: _passwordController.text),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _confirmPasswordController,
              placeholder: 'Confirm Password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text('Register'),
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    final double meterwidth = MediaQuery.of(context).size.width * 0.6; // 60% of the app width
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
        Text('Password Strength: $strengthText', style: TextStyle(color: strengthColor)),
        Container(
          width: meterwidth,
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
