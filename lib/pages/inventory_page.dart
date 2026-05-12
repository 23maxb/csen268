import 'package:flutter/cupertino.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  static const _sections = {
    'Vegetables': [
      'Carrots (3)',
      'Broccoli (1 head)',
      'Spinach (1 bag)',
      'Bell Peppers (2 red, 1 yellow)',
      'Zucchini (2)',
      'Mushrooms (1 box)',
      'Green Onions (1 bunch)',
      'Lettuce (1 head)',
    ],
    'Fruit': [
      'Apples (4)',
      'Bananas (5)',
      'Oranges (3)',
      'Grapes (1 small bunch)',
      'Strawberries (1 container)',
      'Blueberries (1 container)',
      'Lemon (2)',
    ],
    'Meat & Fish': [
      'Chicken Breast (2 pieces)',
      'Ground Beef (500g)',
      'Bacon (1 pack)',
      'Salmon Fillet (1)',
      'Deli Turkey Slices (1 pack)',
    ],
    'Dairy & Eggs': [
      'Milk (1L)',
      'Yogurt (2 small tubs)',
      'Butter (1 stick)',
      'Cheddar Cheese (1 block)',
      'Eggs (12)',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Inventory',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ToolButton(
                  icon: CupertinoIcons.doc_text,
                  label: 'Scan Receipt',
                  onPressed: () {},
                ),
                const SizedBox(width: 12),
                _ToolButton(
                  icon: CupertinoIcons.pencil,
                  label: 'Edit Mode',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (final entry in _sections.entries) ...[
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              for (final item in entry.value)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.separator),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: CupertinoColors.black),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
