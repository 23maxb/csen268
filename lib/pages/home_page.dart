import 'package:flutter/cupertino.dart';

import '../widgets/meal_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome, Max',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            MealSection(
              label: 'Next Meal',
              title: 'Salmon Nigiri with Gyoza\nand Ika Geso',
              details: [
                '1 1/2 cups (320 g) Calrose rice (sushi rice)',
                '3/4 cups (430 ml) water',
                '1 tsp salt',
                '3 tbsp (45 ml) rice vinegar',
                '1 tbsp sugar',
                '1  sushi-grade skinless salmon steak (450 g) (see note)',
                '1 tsp (5 ml) wasabi',
                'Soy sauce for sushi and sashimi, to taste',
                'Pickled ginger, to taste',
              ],
            ),
            Divider(),
            MealSection(
              label: 'Dinner',
              title: 'Leftovers from\nChipotle',
              subtitle: 'No Prep Required!',
            ),
            Divider(),
            MealSection(
              label: 'Breakfast',
              title: 'Frozen Eggo waffles\nand fruit',
              details: [
                '1 Eggo waffle box',
                '1 Apple',
                '1 Pineapple',
              ],
            ),
          ],
        ),
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
