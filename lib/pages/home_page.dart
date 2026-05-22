import 'package:flutter/cupertino.dart';

import '../services/recipe_service.dart';
import '../widgets/meal_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = RecipeService.instance.findFromUserInventory(number: 3);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load recipes.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      onPressed: () => setState(() {
                        _recipesFuture = RecipeService.instance
                            .findFromUserInventory(number: 3);
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final recipes = snapshot.data ?? [];
          const labels = ['Next Meal', 'Dinner', 'Breakfast'];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Max',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                if (recipes.isEmpty)
                  const Text(
                    'No recipe suggestions yet. Add items to your inventory.',
                    style: TextStyle(fontSize: 13),
                  )
                else
                  for (var i = 0; i < recipes.length; i++) ...[
                    MealSection(
                      label: i < labels.length ? labels[i] : 'Meal ${i + 1}',
                      title: recipes[i].title,
                      recipeId: recipes[i].id,
                      imageUrl: recipes[i].image,
                      details: recipes[i]
                          .missedIngredients
                          .map((m) => m.original)
                          .toList(),
                    ),
                    if (i < recipes.length - 1) const Divider(),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class Divider extends StatelessWidget {
  const Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator,
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
