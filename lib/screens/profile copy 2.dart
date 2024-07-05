// lib/screens/profile.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'change_password.dart'; // Import the new screen
import '../services/profile_service.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final String accessToken;
  final authService = AuthService();

  ProfilePage({required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Error'),
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              child: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            final profile = snapshot.data!;

            return _buildProfilePage(context, profile);
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      return await ProfileService().fetchProfile(accessToken);
    } catch (e) {
      throw Exception('Failed to load profile');
    }
  }

  Widget _buildProfilePage(BuildContext context, Map<String, dynamic> profile) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Profile'),
      ),
      child: SafeArea(
          child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildProfileInfo(profile),
          _buildDietaryProfile(profile),
          _buildChangePasswordButton(context),
          SizedBox(height: 16),
          _buildLogoutButton(context),
        ],
      )),
    );
  }

  Widget _buildProfileInfo(Map<String, dynamic> profile) {
    return Stack(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildInfoTile('User Info',
            'Username:  ${profile['username']}\n\nName:  ${profile['firstName']} ${profile['lastName']}\n\nEmail: ${profile['email']}'),
      ]),
      Positioned(
        top: 8,
        right: 8,
        child: CupertinoButton(
          padding: EdgeInsets.all(8),
          child: Icon(
            CupertinoIcons.pencil,
            color: CupertinoColors.activeBlue,
          ),
          onPressed: () {
            // Navigate to the edit profile page
          },
        ),
      )
    ]);
  }

  Widget _buildDietaryProfile(Map<String, dynamic> profile) {
    return Stack(children: [
      _buildInfoTile(
          'Dietry Profile', profile['dietary_profile'] ?? 'Not provided'),
      Positioned(
        top: 4,
        right: 4,
        child: CupertinoButton(
          padding: EdgeInsets.all(8),
          child: Icon(
            CupertinoIcons.home,
            color: CupertinoColors.systemGrey,
          ),
          onPressed: () {
            // Navigate to the edit profile page
          },
        ),
      )
    ]
    );
  }

  Widget _buildInfoTile(String title, String info) {
    return CupertinoListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: CupertinoColors.systemGrey),
      ),
      subtitle: Text(
        info,
        style: TextStyle(color: CupertinoColors.white),
      ),
      backgroundColor: CupertinoColors.black,
    );
  }

  Widget _buildChangePasswordButton(BuildContext context) {
    return CupertinoButton.filled(
      child: Text('Change Password'),
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ChangePasswordPage(),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CupertinoButton(
      color: CupertinoColors.destructiveRed,
      child: Text('Logout'),
      onPressed: () async {
        await _showLogoutConfirmationDialog(context);
      },
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Logout'),
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await authService.logout(accessToken);
                await FlutterSecureStorage().delete(key: 'refresh_token');
                Navigator.of(context, rootNavigator: true)
                    .pushReplacementNamed('/landing');
              },
            ),
          ],
        );
      },
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Color backgroundColor;

  CupertinoListTile({
    required this.title,
    this.subtitle,
    this.backgroundColor = CupertinoColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4,
              offset: Offset(0.0, 2.0),
              blurRadius: 4.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    subtitle!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
