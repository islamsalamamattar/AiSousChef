import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:video_player/video_player.dart';
import 'home.dart';
import 'onboarding_wizard.dart';

class WelcomePage extends StatefulWidget {
  final String accessToken;

  WelcomePage({required this.accessToken});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late VideoPlayerController _controller;
  bool _isVideoComplete = false;
  List<String> _captions = [];
  String _displayedText = '';
  int _currentCaptionIndex = 0;
  int _currentWordIndex = 0;
  Timer? _timer;
  bool _termsAccepted = false; // Flag to track terms acceptance
  bool _isChecked = false; // Checkbox state
  String _termsText = ''; // To hold the terms text

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _showTermsDialog();
    });
  }

  Future<void> _initializeVideoAndCaptions() async {
    await _loadWelcomeCaptions();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller =
        VideoPlayerController.asset('lib/assets/videos/suewelcome.mov')
          ..initialize().then((_) {
            setState(() {
              _controller.play();
              _startTextAnimation();
            });
          });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isVideoComplete = true;
        });
      }
    });
  }

  Future<void> _loadWelcomeCaptions() async {
    final String response =
        await rootBundle.loadString('lib/assets/welcome.json');
    final data = json.decode(response);
    setState(() {
      _captions = List<String>.from(data['captions']);
    });
  }

  Future<void> _loadTermsText() async {
    final String response = await rootBundle.loadString('lib/assets/terms.txt');
    setState(() {
      _termsText = response;
    });
  }

  void _startTextAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 160), (timer) {
      if (_currentCaptionIndex < _captions.length) {
        List<String> words = _captions[_currentCaptionIndex].split(' ');
        if (_currentWordIndex < words.length) {
          setState(() {
            _displayedText += (words[_currentWordIndex] + ' ');
            _currentWordIndex++;
          });
        } else {
          _timer?.cancel();
          if (_currentCaptionIndex < _captions.length - 1) {
            // Wait for 1500 milliseconds, then clear and move to the next text
            Future.delayed(Duration(milliseconds: 1500), () {
              setState(() {
                _displayedText = '';
                _currentWordIndex = 0;
                _currentCaptionIndex++;
              });
              _startTextAnimation();
            });
          }
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleContinue() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => OnboardingWizard(accessToken: widget.accessToken),
      ),
    );
  }

  void _handleSkip() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => HomePage(accessToken: widget.accessToken),
      ),
    );
  }

void _showTermsDialog() {
  _loadTermsText().then((_) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return CupertinoActionSheet(
              title: Text('Terms and Conditions'),
              message: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8, // Adjust max height as needed
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _termsText,
                                style: TextStyle(
                                  color: CupertinoColors.white, // Change text color to white
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Expanded(child: Container()),
                                  CupertinoCheckbox(
                                    value: _isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isChecked = value ?? false;
                                      });
                                    },
                                  ),
                                  Text('     Read & Agreed', style: TextStyle(color: CupertinoColors.systemBlue)), // Adjust color of the text
                                ],
                              ),
                            ),
                            SizedBox(height: 16.0), // Adjust spacing as needed
                          ],
                        ),
                      ),
                    ),
                    CupertinoButton(
                      child: Text('I agree'),
                      onPressed: _isChecked
                          ? () {
                              setState(() {
                                _termsAccepted = true;
                                Navigator.pop(context);
                                _initializeVideoAndCaptions();
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [],
            );
          },
        );
      },
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Video Player and Text Animation
          _termsAccepted
              ? _buildVideoPlayer()
              : Container(), // Placeholder until terms are accepted

          // Terms and Conditions Modal (shown if terms are not accepted)
          if (!_termsAccepted)
            Container(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              alignment: Alignment.center,
              child: CupertinoButton.filled(
                child: Text('Show Terms'),
                onPressed: () {
                  _showTermsDialog();
                },
              ),
            ),
        ],
      ),
    );
  }
Widget _buildVideoPlayer() {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double boxHeight = screenHeight * 0.5; // 50% of screen height

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center the children vertically
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: boxHeight,
            width: boxHeight, // Ensuring the width matches the height for a square aspect ratio
            child: ClipOval(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'lib/assets/images/sous_chef_smile.png', // Replace with your asset path
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: 1, // Ensuring the video is square
                      child: _controller.value.isInitialized
                          ? VideoPlayer(_controller)
                          : Container(), // Display nothing if video is not initialized
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _displayedText,
            style: TextStyle(
              fontSize: 18,
            ),
            textAlign: TextAlign.center, // Center the text
          ),
        ),
        CupertinoButton.filled(
          child: Text('Continue'),
          onPressed: _isVideoComplete ? _handleContinue : null,
        ),
        CupertinoButton(
          child: Text('Skip'),
          onPressed: _handleSkip,
        ),
      ],
    ),
  );
}


}

class CupertinoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  CupertinoCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? CupertinoColors.activeBlue : CupertinoColors.white,
          border: Border.all(
            color: CupertinoColors.inactiveGray,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: value
              ? Icon(
                  CupertinoIcons.check_mark,
                  size: 20.0,
                  color: CupertinoColors.white,
                )
              : Icon(
                  CupertinoIcons.circle,
                  size: 20.0,
                  color: CupertinoColors.inactiveGray,
                ),
        ),
      ),
    );
  }
}
