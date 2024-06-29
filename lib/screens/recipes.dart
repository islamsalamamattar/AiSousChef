import 'package:flutter/cupertino.dart';
import '../services/recipe_service.dart';
import 'recipe_details.dart';

class RecipePage extends StatefulWidget {
  final String accessToken;

  RecipePage({required this.accessToken});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<dynamic>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _fetchRecipes();
  }

  Future<List<dynamic>> _fetchRecipes() async {
    try {
      return await _recipeService.fetchRecipes(widget.accessToken);
    } catch (e) {
      throw Exception('Failed to load recipes');
    }
  }

  Future<void> _refreshRecipes() async {
    setState(() {
      _recipesFuture = _fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Recipes'),
      ),
      resizeToAvoidBottomInset: true,
      child: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<List<dynamic>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Saved recipes from our chat will be listed here',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.systemGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  final recipes = snapshot.data!;
                  return CupertinoScrollbar(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _buildRecipeItem(recipe);
                      },
                    ),
                  );
                }
              },
            ),
            Positioned(
              top: 10.0,
              left: MediaQuery.of(context).size.width - 60,
              child: GestureDetector(
                onTap: _refreshRecipes,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.refresh,
                    color: CupertinoColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeItem(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => RecipeDetailsPage(
              accessToken: widget.accessToken,
              recipeId: recipe['id'],
            ),
          ),
        );
      },
      child: CupertinoListTile(
        leading: Icon(CupertinoIcons.square_list, color: CupertinoColors.systemBlue),
        title: Text(
          recipe['recipeName'] ?? 'N/A',
          style: TextStyle(fontSize: 18, color: CupertinoColors.white),
        ),
        subtitle: Text(
          'Prep Time: ${recipe['prepTime'] ?? 'N/A'}',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
        backgroundColor: CupertinoColors.black,
      ),
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
