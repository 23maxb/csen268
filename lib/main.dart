import 'package:flutter/cupertino.dart';

import 'app.dart';

void main() {
  runApp(const MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Meal Planner',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.black,
        scaffoldBackgroundColor: CupertinoColors.white,
      ),
      routerConfig: appRouter,
    );
  }
}
