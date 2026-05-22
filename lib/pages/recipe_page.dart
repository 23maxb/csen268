import 'package:flutter/cupertino.dart';

import '../services/recipe_service.dart';

class RecipePage extends StatefulWidget {
  final int id;
  final String? initialTitle;
  final String? initialImage;

  const RecipePage({
    super.key,
    required this.id,
    this.initialTitle,
    this.initialImage,
  });

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late Future<RecipeDetails> _future;

  @override
  void initState() {
    super.initState();
    _future = RecipeService.instance.getRecipeInformation(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Back',
        backgroundColor: CupertinoColors.white,
        border: null,
      ),
      child: SafeArea(
        child: FutureBuilder<RecipeDetails>(
          future: _future,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState == ConnectionState.waiting;
            final data = snapshot.data;
            final title = data?.title ?? widget.initialTitle ?? '';
            final image = data?.image ?? widget.initialImage ?? '';
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: image.isNotEmpty
                          ? Image.network(
                              image,
                              width: 240,
                              height: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (snapshot.hasError)
                    Text(
                      'Failed to load recipe.\n${snapshot.error}',
                      style: const TextStyle(fontSize: 13),
                    )
                  else if (loading)
                    const Center(child: CupertinoActivityIndicator())
                  else if (data != null) ...[
                    const Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final ing in data.ingredients)
                      Text(ing, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 24),
                    const Text(
                      'Instructions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (data.steps.isNotEmpty)
                      for (var i = 0; i < data.steps.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('${i + 1}. ${data.steps[i]}',
                              style: const TextStyle(fontSize: 13)),
                        )
                    else if (data.instructionsHtml != null &&
                        data.instructionsHtml!.trim().isNotEmpty)
                      Text(
                        _stripHtml(data.instructionsHtml!),
                        style: const TextStyle(fontSize: 13),
                      )
                    else
                      const Text('No instructions available.',
                          style: TextStyle(fontSize: 13)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 240,
        height: 240,
        color: CupertinoColors.systemGrey6,
        child: const Center(
          child: Icon(CupertinoIcons.photo,
              size: 60, color: CupertinoColors.systemGrey),
        ),
      );

  String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}
