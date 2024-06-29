// screens/home.dart

import 'package:flutter/cupertino.dart';
import 'chat.dart'; // Import the Chat page
import 'recipes.dart'; // Import the Recipes page
import 'profile.dart'; // Import the Profile page

class HomePage extends StatelessWidget {
  final String? accessToken;

  HomePage({required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
                builder: (context) => ChatPage(accessToken: accessToken!));
          case 1:
            return CupertinoTabView(
                builder: (context) => RecipePage(accessToken: accessToken!));
          case 2:
            return CupertinoTabView(
                builder: (context) =>
                    ProfilePage(accessToken: accessToken ?? ''));
          default:
            return CupertinoTabView(
                builder: (context) => ChatPage(accessToken: accessToken!));
        }
      },
    );
  }
}
