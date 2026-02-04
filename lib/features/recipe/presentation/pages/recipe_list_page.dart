import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/features/recipe/presentation/providers/recipe_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeListPage extends ConsumerWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('レシピがまだありません'));
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(
                  recipe.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(recipe.category),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final uri = Uri.parse(recipe.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              );
            },
          );
        },
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
