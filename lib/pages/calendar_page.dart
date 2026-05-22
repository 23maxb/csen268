import 'package:flutter/cupertino.dart';

import '../services/recipe_service.dart';
import '../widgets/meal_section.dart';
import 'home_page.dart' show Divider;

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedDay = 18;
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = RecipeService.instance.findFromUserInventory(number: 3);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(),
            const SizedBox(height: 24),
            FutureBuilder<List<Recipe>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (snapshot.hasError) {
                  return Column(
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
                  );
                }
                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return const Text(
                    'No recipe suggestions yet.',
                    style: TextStyle(fontSize: 13),
                  );
                }
                const labels = ['Breakfast', 'Lunch', 'Dinner'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    const daysHeader = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final weeks = <List<int?>>[
      [1, 2, 3, 4, 5, 6, 7],
      [8, 9, 10, 11, 12, 13, 14],
      [15, 16, 17, 18, 19, 20, 21],
      [22, 23, 24, 25, 26, 27, 28],
      [29, 30, 31, null, null, null, null],
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.separator),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'May 2023',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(CupertinoIcons.chevron_left, size: 18),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {},
                child: const Icon(CupertinoIcons.chevron_right, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: daysHeader
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          for (final week in weeks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: week.map((day) {
                  if (day == null) return const Expanded(child: SizedBox());
                  final isSelected = day == _selectedDay;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        height: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CupertinoColors.activeBlue
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
