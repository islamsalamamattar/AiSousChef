// lib/screens/change_info.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import the AuthService
import '../screens/home.dart'; // Import the HomePage

class InfoPage extends StatefulWidget {
  final String accessToken;
  final String username;
  final String email;
  final String firstName;
  final String lastName;

  InfoPage({
    required this.accessToken,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
  }

  void _handleInfo() async {
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

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

    try {
      await _authService.update(
        token: widget.accessToken,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      // Show success message and navigate to HomePage
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Success'),
          content: Text('Information updated successfully'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        HomePage(accessToken: widget.accessToken)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle update error
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Failed To Update Info'),
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
        middle: Text('Update Info'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CupertinoTextField(
              controller: TextEditingController(text: widget.username),
              placeholder: 'Username',
              readOnly: true,
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
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text('Update Info'),
              onPressed: _handleInfo,
            ),
          ],
        ),
      ),
    );
  }

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
