import 'package:flutter/cupertino.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Back',
        backgroundColor: CupertinoColors.white,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frozen Eggo waffles\nand fruit',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 60,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ingredients',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1 Eggo waffle box', style: TextStyle(fontSize: 13)),
              const Text('1 Apple', style: TextStyle(fontSize: 13)),
              const Text('1 Pineapple', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 24),
              const Text(
                'Instructions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. Toast the Eggo waffles per box instructions.',
                  style: TextStyle(fontSize: 13)),
              const Text('2. Slice apple and pineapple.',
                  style: TextStyle(fontSize: 13)),
              const Text('3. Plate together and serve.',
                  style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
