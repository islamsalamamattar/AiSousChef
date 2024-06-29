import 'package:flutter/cupertino.dart';

class RecipeFormatter {
  static Widget formatRecipeDetails(
      BuildContext context, Map<String, dynamic> recipeDetails) {
    final servings = recipeDetails['servings'];
    final prepTime = recipeDetails['prepTime'];
    final cookingTime = recipeDetails['cookingTime'];
    final ingredients = recipeDetails['ingredients'];
    final instructions = recipeDetails['instructions'];
    final tipsVariations = recipeDetails['TipsVariations'];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(recipeDetails['recipeName']),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildInfoTile('Servings', servings, CupertinoIcons.person_2),
            _buildInfoTile('Prep Time', prepTime, CupertinoIcons.time),
            _buildInfoTile('Cooking Time', cookingTime, CupertinoIcons.flame),
            _buildSectionTile(
                'Ingredients', _buildIngredientsList(ingredients)),
            _buildSectionTile(
                'Instructions', _buildInstructionsList(instructions)),
            _buildSectionTile(
                'Tips & Variations', _buildTipsList(tipsVariations)),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoTile(String title, String info, IconData icon) {
    return CupertinoListTile(
      leading: Icon(icon, color: CupertinoColors.systemBlue),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: CupertinoColors.white),
      ),
      subtitle: Text(
        info,
        style: TextStyle(color: CupertinoColors.systemGrey),
      ),
      backgroundColor: CupertinoColors.black,
    );
  }

  static Widget _buildSectionTile(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.black,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 22,
                  // fontWeight: FontWeight.bold,
                  color: CupertinoColors.white),
            ),
            SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  static Widget _buildIngredientsList(List ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients.map<Widget>((ingredient) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            ingredient['ingredient'],
            style: TextStyle(fontSize: 16, color: CupertinoColors.white),
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildInstructionsList(List instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructions.map<Widget>((instruction) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '${instruction['number']}. ${instruction['description']}',
            style: TextStyle(fontSize: 16, color: CupertinoColors.white),
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildTipsList(List tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips.map<Widget>((tip) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '• ${tip['tip']}',
            style: TextStyle(fontSize: 16, color: CupertinoColors.white),
          ),
        );
      }).toList(),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Color backgroundColor;

  CupertinoListTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.backgroundColor = CupertinoColors.white,
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
            leading,
            SizedBox(width: 16),
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
