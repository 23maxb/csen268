import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../services/recipe_service.dart';
import '../services/settings_service.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  Future<MealPlan>? _future;

  // The generator always returns three meals for a single day.
  static const _labels = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _future = _generate();
  }

  Future<MealPlan> _generate() async {
    final settings = await SettingsService.instance.fetchOrCreate();
    // Build the diet param from the enabled dietary restrictions, keeping only
    // the ones Spoonacular's meal planner actually supports as a diet.
    final diet = settings.restrictions.entries
        .where((e) => e.value && RecipeService.supportedDiets.contains(e.key))
        .map((e) => e.key.toLowerCase())
        .join(',');
    return RecipeService.instance.generateMealPlan(
      targetCalories: settings.calories,
      diet: diet,
    );
  }

  void _openRecipe(MealPlanMeal meal) {
    final params = <String, String>{
      'title': meal.title,
      if (meal.image.isNotEmpty) 'image': meal.image,
    };
    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
    context.push('/recipe/${meal.id}${query.isEmpty ? '' : '?$query'}');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<MealPlan>(
        future: _future,
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
                      'Failed to generate meal plan.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      onPressed: () => setState(() => _future = _generate()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final plan = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Daily Meal Plan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _future = _generate()),
                      child: const Icon(CupertinoIcons.refresh, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Target ${plan.nutrients.calories.round()} kcal · '
                  'P ${plan.nutrients.protein.round()}g · '
                  'C ${plan.nutrients.carbohydrates.round()}g · '
                  'F ${plan.nutrients.fat.round()}g',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 20),
                if (plan.meals.isEmpty)
                  const Text(
                    'No meals could be generated. Try adjusting your settings.',
                    style: TextStyle(fontSize: 13),
                  )
                else
                  for (var i = 0; i < plan.meals.length; i++)
                    _MealCard(
                      label: i < _labels.length ? _labels[i] : 'Meal ${i + 1}',
                      meal: plan.meals[i],
                      onTap: () => _openRecipe(plan.meals[i]),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String label;
  final MealPlanMeal meal;
  final VoidCallback onTap;

  const _MealCard({
    required this.label,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.separator),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: meal.image.isNotEmpty
                  ? Image.network(
                      meal.image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ready in ${meal.readyInMinutes} min · '
                    '${meal.servings} serving${meal.servings == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 160,
    width: double.infinity,
    color: CupertinoColors.systemGrey6,
    child: const Center(
      child: Icon(
        CupertinoIcons.photo,
        size: 48,
        color: CupertinoColors.systemGrey,
      ),
    ),
  );
}
