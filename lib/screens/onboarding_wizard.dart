import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import '../services/profile_service.dart';

class OnboardingWizard extends StatefulWidget {
  final String accessToken;

  OnboardingWizard({required this.accessToken});

  @override
  _OnboardingWizardState createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final ProfileService _profileService = ProfileService();

  final List<String> _questions = [
    "What is your cooking skill level?",
    "How many people do you usually cook for per meal?",
    "Which units do you prefer?",
    "Do you have any dietary restrictions?",
    "What are your health goals?",
    "What are your likes and dislikes?"
  ];

  final List<String> _skillLevels = ['Beginner', 'Intermediate', 'Expert'];
  int _selectedSkillLevel = 1;

  final List<int> _peopleCount =
      List<int>.generate(20, (int index) => index + 1);
  int _selectedPeopleCount = 3;

  bool _unitWeightGrams = true;
  bool _unitLengthMeters = true;
  bool _unitTemperatureCelsius = true;

  final List<String> _dietaryRestrictions = [
    "Halal",
    "Vegetarian",
    "Vegan",
    "Gluten-Free",
    "Dairy-Free",
    "Carnivor",
    "Mediterranean",
    "Nut-Free",
    "Soy-Free",
    "Egg-Free",
    "Shellfish-Free",
    "Low-Carb",
    "Low-Sugar",
    "Paleo",
    "Keto",
    "Diabetic-Friendly",
    "Lactose Intolerant",
    "Pescatarian",
    "No Red Meat"
  ];
  final List<bool> _selectedDietaryRestrictions = List.filled(19, false);

  final List<String> _healthGoals = [
    "Weight Loss",
    "Muscle Gain",
    "Balanced Diet",
    "Increased Energy",
    "Improved Digestion",
    "Heart Health",
    "Better Sleep",
    "Immune Support",
    "Anti-Inflammatory",
    "Bone Health",
    "Healthy Skin",
    "Blood Sugar Control",
    "Detoxification",
    "Athletic Performance",
    "Hormone Balance",
    "Pregnancy Health",
    "Postpartum Recovery"
  ];
  final List<bool> _selectedHealthGoals = List.filled(17, false);

  String _likes = "";
  String _dislikes = "";

  void _nextStep() {
    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveProfile() async {
    try {
      List<String> selectedDietaryRestrictions = [];
      for (int i = 0; i < _dietaryRestrictions.length; i++) {
        if (_selectedDietaryRestrictions[i]) {
          selectedDietaryRestrictions.add(_dietaryRestrictions[i]);
        }
      }

      List<String> selectedHealthGoals = [];
      for (int i = 0; i < _healthGoals.length; i++) {
        if (_selectedHealthGoals[i]) {
          selectedHealthGoals.add(_healthGoals[i]);
        }
      }

      await _profileService.upsertProfile(
        accessToken: widget.accessToken,
        cookingSkillLevel: _skillLevels[_selectedSkillLevel],
        numPeoplePerMeal: _peopleCount[_selectedPeopleCount],
        dietaryRestrictions: selectedDietaryRestrictions
            .join(', '), // Join list with comma separator
        healthGoals:
            selectedHealthGoals.join(', '), // Join list with comma separator
        likes: _likes,
        dislikes: _dislikes,
        unitWeight: _unitWeightGrams ? 'Grams' : 'Pounds',
        unitLength: _unitLengthMeters ? 'Meters' : 'Feet',
        unitTemperature: _unitTemperatureCelsius ? 'Celsius' : 'Fahrenheit',
      );

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Thank You"),
            content: Text("I will keep all that in mind"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          HomePage(accessToken: widget.accessToken),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Error"),
            content:
                Text("Hmm, something didn't work. But let's do that next time"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          HomePage(accessToken: widget.accessToken),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildSkillLevelPicker() {
    return CupertinoPicker(
      itemExtent: 32.0,
      scrollController:
          FixedExtentScrollController(initialItem: _selectedSkillLevel),
      onSelectedItemChanged: (int index) {
        setState(() {
          _selectedSkillLevel = index;
        });
      },
      children: _skillLevels
          .map((String skill) => Center(child: Text(skill)))
          .toList(),
    );
  }

  Widget _buildPeopleCountPicker() {
    return CupertinoPicker(
      itemExtent: 32.0,
      scrollController:
          FixedExtentScrollController(initialItem: _selectedPeopleCount),
      onSelectedItemChanged: (int index) {
        setState(() {
          _selectedPeopleCount = index;
        });
      },
      children: _peopleCount
          .map((int count) => Center(child: Text(count.toString())))
          .toList(),
    );
  }

  Widget _buildUnitsPreference() {
    return Column(
      children: [
        Row(
          children: [
            //Text("Weight"),
            CupertinoSwitch(
              value: _unitWeightGrams,
              onChanged: (bool value) {
                setState(() {
                  _unitWeightGrams = value;
                });
              },
            ),
            Text(_unitWeightGrams ? "Grams" : "Pounds"),
          ],
        ),
        Row(
          children: [
            //Text("Length"),
            CupertinoSwitch(
              value: _unitLengthMeters,
              onChanged: (bool value) {
                setState(() {
                  _unitLengthMeters = value;
                });
              },
            ),
            Text(_unitLengthMeters ? "Meters" : "Feet"),
          ],
        ),
        Row(
          children: [
            //Text("Temp"),
            CupertinoSwitch(
              value: _unitTemperatureCelsius,
              onChanged: (bool value) {
                setState(() {
                  _unitTemperatureCelsius = value;
                });
              },
            ),
            Text(_unitTemperatureCelsius ? "°C" : "°F"),
          ],
        ),
      ],
    );
  }

  Widget _buildDietaryRestrictionsList() {
    return Column(
      children: _dietaryRestrictions.asMap().entries.map((entry) {
        int idx = entry.key;
        String restriction = entry.value;
        return Row(
          children: [
            CupertinoSwitch(
              value: _selectedDietaryRestrictions[idx],
              onChanged: (bool value) {
                setState(() {
                  _selectedDietaryRestrictions[idx] = value;
                });
              },
            ),
            Text(restriction),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHealthGoalsList() {
    return Column(
      children: _healthGoals.asMap().entries.map((entry) {
        int idx = entry.key;
        String goal = entry.value;
        return Row(
          children: [
            CupertinoSwitch(
              value: _selectedHealthGoals[idx],
              onChanged: (bool value) {
                setState(() {
                  _selectedHealthGoals[idx] = value;
                });
              },
            ),
            Text(goal),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLikesDislikes() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CupertinoTextField(
            placeholder: 'Enter your likes',
            maxLines: 2,
            onChanged: (value) {
              _likes = value;
            },
          ),
          SizedBox(height: 10),
          CupertinoTextField(
            placeholder: 'Enter your dislikes',
            maxLines: 2,
            onChanged: (value) {
              _dislikes = value;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double radius =
        screenWidth < screenHeight ? screenWidth * 0.2 : screenHeight * 0.2;

    return CupertinoPageScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage:
                AssetImage('lib/assets/images/sous_chef_smile.png'),
          ),
          SizedBox(height: 20),
          Text(
            _questions[_currentStep],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildSkillLevelPicker();
                  case 1:
                    return _buildPeopleCountPicker();
                  case 2:
                    return _buildUnitsPreference();
                  case 3:
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildDietaryRestrictionsList(),
                      ),
                    );
                  case 4:
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildHealthGoalsList(),
                      ),
                    );
                  case 5:
                    return _buildLikesDislikes();
                  default:
                    return SizedBox.shrink();
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: Text(_currentStep > 0 ? 'Previous' : 'Skip'),
                onPressed: _currentStep > 0
                    ? _previousStep
                    : () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                HomePage(accessToken: widget.accessToken),
                          ),
                        );
                      },
              ),
              CupertinoButton.filled(
                child: Text(
                    _currentStep == _questions.length - 1 ? 'Finish' : 'Next'),
                onPressed: _nextStep,
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
