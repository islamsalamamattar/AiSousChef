import 'package:flutter/cupertino.dart';
import '../services/recipe_service.dart';
import '../services/recipe_details_formatter.dart'; // Import the RecipeFormatter

class RecipeDetailsPage extends StatelessWidget {
  final String accessToken;
  final int recipeId;

  RecipeDetailsPage({required this.accessToken, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _fetchRecipeDetails(),
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
            final recipeDetails = snapshot.data!;

            // Use RecipeFormatter to format recipe details
            return RecipeFormatter.formatRecipeDetails(context, recipeDetails);
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchRecipeDetails() async {
    try {
      return await RecipeService().fetchRecipeDetails(accessToken, recipeId);
    } catch (e) {
      throw Exception('Failed to load recipe details');
    }
  }
}
