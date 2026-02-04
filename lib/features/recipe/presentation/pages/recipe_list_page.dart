import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('レシピ一覧')),
      body: const Center(child: Text('レシピがまだありません')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
