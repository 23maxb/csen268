import 'dart:convert';

import 'package:http/http.dart' as http;

import 'inventory_service.dart';

const String _spoonacularApiKey = '';

class RecipeIngredient {
  final String name;
  final String original;

  RecipeIngredient({required this.name, required this.original});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: (json['name'] ?? '').toString(),
      original: (json['original'] ?? json['name'] ?? '').toString(),
    );
  }
}

class Recipe {
  final int id;
  final String title;
  final String image;
  final int usedIngredientCount;
  final int missedIngredientCount;
  final List<RecipeIngredient> usedIngredients;
  final List<RecipeIngredient> missedIngredients;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
    required this.usedIngredients,
    required this.missedIngredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<RecipeIngredient> parse(dynamic list) => (list as List? ?? [])
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
    return Recipe(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      usedIngredientCount: (json['usedIngredientCount'] as num?)?.toInt() ?? 0,
      missedIngredientCount:
          (json['missedIngredientCount'] as num?)?.toInt() ?? 0,
      usedIngredients: parse(json['usedIngredients']),
      missedIngredients: parse(json['missedIngredients']),
    );
  }
}

class RecipeDetails {
  final int id;
  final String title;
  final String image;
  final List<String> ingredients;
  final List<String> steps;
  final String? instructionsHtml;

  RecipeDetails({
    required this.id,
    required this.title,
    required this.image,
    required this.ingredients,
    required this.steps,
    this.instructionsHtml,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    final extended = (json['extendedIngredients'] as List? ?? [])
        .map((e) => (e as Map<String, dynamic>)['original']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final analyzed = (json['analyzedInstructions'] as List? ?? []);
    final steps = <String>[];
    for (final block in analyzed) {
      for (final s in (block as Map<String, dynamic>)['steps'] as List? ?? []) {
        final step = (s as Map<String, dynamic>)['step']?.toString();
        if (step != null && step.trim().isNotEmpty) steps.add(step.trim());
      }
    }
    return RecipeDetails(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      ingredients: extended,
      steps: steps,
      instructionsHtml: json['instructions']?.toString(),
    );
  }
}

class RecipeService {
  RecipeService._();
  static final RecipeService instance = RecipeService._();

  static final RegExp _parenStrip = RegExp(r'\s*\([^)]*\)');

  List<String> ingredientsFromInventory(Map<String, List<String>> sections) {
    final result = <String>[];
    for (final items in sections.values) {
      for (final item in items) {
        final cleaned = item.replaceAll(_parenStrip, '').trim();
        if (cleaned.isNotEmpty) result.add(cleaned);
      }
    }
    return result;
  }

  Future<List<Recipe>> findByIngredients({
    required List<String> ingredients,
    int number = 10,
    int ranking = 1,
    bool ignorePantry = true,
  }) async {
    if (ingredients.isEmpty) return [];
    final uri = Uri.https('api.spoonacular.com', '/recipes/findByIngredients', {
      'apiKey': _spoonacularApiKey,
      'ingredients': ingredients.join(','),
      'number': '$number',
      'ranking': '$ranking',
      'ignorePantry': '$ignorePantry',
    });
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception(
        'Spoonacular request failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final data = jsonDecode(resp.body) as List;
    return data
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RecipeDetails> getRecipeInformation(int id) async {
    final uri = Uri.https('api.spoonacular.com', '/recipes/$id/information', {
      'apiKey': _spoonacularApiKey,
      'includeNutrition': 'false',
    });
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception(
        'Spoonacular request failed (${resp.statusCode}): ${resp.body}',
      );
    }
    return RecipeDetails.fromJson(
      jsonDecode(resp.body) as Map<String, dynamic>,
    );
  }

  Future<List<Recipe>> findFromUserInventory({int number = 10}) async {
    final sections = await InventoryService.instance.fetchOrCreate();
    final ingredients = ingredientsFromInventory(sections);
    return findByIngredients(ingredients: ingredients, number: number);
  }
}
