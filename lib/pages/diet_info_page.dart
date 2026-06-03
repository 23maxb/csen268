import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class DietInfoPage extends StatelessWidget {
  const DietInfoPage({super.key});

  static const Map<String, String> _dietDescriptions = {
    'Gluten Free':
        'Eliminating gluten means avoiding wheat, barley, rye, and other gluten-containing grains and foods made from them (or that may have been cross contaminated).',
    'Ketogenic':
        'The keto diet is based more on the ratio of fat, protein, and carbs in the diet rather than specific ingredients. Generally speaking, high fat, protein-rich foods are acceptable and high carbohydrate foods are not. The formula we use is 55-80% fat content, 15-35% protein content, and under 10% of carbohydrates.',
    'Vegetarian':
        'No ingredients may contain meat or meat by-products, such as bones or gelatin.',
    'Lacto-Vegetarian':
        'All ingredients must be vegetarian and none of the ingredients can be or contain egg.',
    'Ovo-Vegetarian':
        'All ingredients must be vegetarian and none of the ingredients can be or contain dairy.',
    'Vegan':
        'No ingredients may contain meat or meat by-products, such as bones or gelatin, nor may they contain eggs, dairy, or honey.',
    'Pescetarian':
        'Everything is allowed except meat and meat by-products - some pescetarians eat eggs and dairy, some do not.',
    'Paleo':
        'Allowed ingredients include meat (especially grass fed), fish, eggs, vegetables, some oils (e.g. coconut and olive oil), and in smaller quantities, fruit, nuts, and sweet potatoes. We also allow honey and maple syrup. Ingredients not allowed include legumes (e.g. beans and lentils), grains, dairy, refined sugar, and processed foods.',
    'Primal':
        'Very similar to Paleo, except dairy is allowed - think raw and full fat milk, butter, ghee, etc.',
    'Low FODMAP':
        'FODMAP stands for "fermentable oligo-, di-, mono-saccharides and polyols". Our ontology knows which foods are considered high in these types of carbohydrates (e.g. legumes, wheat, and dairy products).',
    'Whole30':
        'Allowed ingredients include meat, fish/seafood, eggs, vegetables, fresh fruit, coconut oil, olive oil, small amounts of dried fruit and nuts/seeds. Ingredients not allowed include added sweeteners, dairy (except clarified butter or ghee), alcohol, grains, legumes (except green beans, sugar snap peas, and snow peas), and food additives.',
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('About Diets'),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(CupertinoIcons.back, size: 24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive/Viewable Infographic Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://spoonacular.com/application/frontend/images/academy/diet-infographic.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Could not load infographic.',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Diet Summaries',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Generate the list dynamically
              for (final entry in _dietDescriptions.entries) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: CupertinoColors.separator),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Divider extends StatelessWidget {
  final Color color;

  const Divider({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 0.5,
      color: color,
    );
  }
}
