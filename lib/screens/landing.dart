import 'package:flutter/cupertino.dart';
import 'login.dart';
import 'register.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double boxHeight = (screenHeight < screenWidth) ? screenHeight * 0.7 : screenWidth;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Ai Sous Chef'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: boxHeight,
              child: Image.asset('lib/assets/images/moonshine_logo_black.png'),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              child: const Text('Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            CupertinoButton(
              child: const Text('Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => RegisterPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
