import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/widgets/app_primary_button.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe_category.dart';
import 'package:my_recipe_memo/features/recipe/presentation/providers/recipe_providers.dart';

void showRecipeFilterSheet(
  BuildContext context,
  WidgetRef ref,
  RecipeFilter currentFilter,
  List<SavedFilter> presets,
) {
  final initialCategories = currentFilter.categories.isEmpty
      ? RecipeCategory.values
      : currentFilter.categories;
  final selectedCategory = ValueNotifier<List<RecipeCategory>>(
    List.of(initialCategories),
  );
  final sortOrder = ValueNotifier<SortOrder>(currentFilter.sortOrder);

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(
              ref: ref,
              selectedCategory: selectedCategory,
              sortOrder: sortOrder,
            ),
            const SizedBox(height: 12),
            _CategorySection(selectedCategory: selectedCategory),
            const SizedBox(height: 12),
            _SortOrderSection(sortOrder: sortOrder),
            _PresetSection(
              presets: presets,
              selectedCategory: selectedCategory,
              sortOrder: sortOrder,
            ),
            const SizedBox(height: 20),
            _ApplyButton(
              selectedCategory: selectedCategory,
              sortOrder: sortOrder,
              ref: ref,
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.ref,
    required this.selectedCategory,
    required this.sortOrder,
  });

  final WidgetRef ref;
  final ValueNotifier<List<RecipeCategory>> selectedCategory;
  final ValueNotifier<SortOrder> sortOrder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('フィルター', style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          onPressed: () {
            selectedCategory.value = List.of(RecipeCategory.values);
            sortOrder.value = SortOrder.newestFirst;
          },
          child: const Text('リセット'),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.selectedCategory});

  final ValueNotifier<List<RecipeCategory>> selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('カテゴリ', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<RecipeCategory>>(
          valueListenable: selectedCategory,
          builder: (context, categories, _) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in RecipeCategory.values)
                    _FilterChipTile(
                      label: c.title,
                      selected: categories.contains(c),
                      onSelected: (selected) {
                        final current = [...categories];
                        if (selected) {
                          current.add(c);
                        } else {
                          current.remove(c);
                        }
                        selectedCategory.value = current;
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SortOrderSection extends StatelessWidget {
  const _SortOrderSection({required this.sortOrder});

  final ValueNotifier<SortOrder> sortOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('追加日', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ValueListenableBuilder<SortOrder>(
          valueListenable: sortOrder,
          builder: (context, order, _) {
            return SegmentedButton<SortOrder>(
              segments: const [
                ButtonSegment(
                  value: SortOrder.newestFirst,
                  icon: Icon(Icons.south),
                  label: Text('新しい順'),
                ),
                ButtonSegment(
                  value: SortOrder.oldestFirst,
                  icon: Icon(Icons.north),
                  label: Text('古い順'),
                ),
              ],
              selected: {order},
              onSelectionChanged: (value) => sortOrder.value = value.first,
              showSelectedIcon: false,
            );
          },
        ),
      ],
    );
  }
}

class _PresetSection extends StatelessWidget {
  const _PresetSection({
    required this.presets,
    required this.selectedCategory,
    required this.sortOrder,
  });

  final List<SavedFilter> presets;
  final ValueNotifier<List<RecipeCategory>> selectedCategory;
  final ValueNotifier<SortOrder> sortOrder;

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('検索履歴', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2; // 2列固定
            return Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: spacing,
                children: [
                  for (final p in presets)
                    SizedBox(
                      width: itemWidth,
                      child: _FilterChipTile(
                        label: p.name,
                        selected: false,
                        onSelected: (_) {
                          final presetCategories = p.filter.categories.isEmpty
                              ? RecipeCategory.values
                              : p.filter.categories;
                          selectedCategory.value = List.of(presetCategories);
                          sortOrder.value = p.filter.sortOrder;
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ApplyButton extends StatefulWidget {
  const _ApplyButton({
    required this.selectedCategory,
    required this.sortOrder,
    required this.ref,
  });

  final ValueNotifier<List<RecipeCategory>> selectedCategory;
  final ValueNotifier<SortOrder> sortOrder;
  final WidgetRef ref;

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RecipeCategory>>(
      valueListenable: widget.selectedCategory,
      builder: (context, categories, _) {
        final canApply = categories.isNotEmpty && !_isApplying;
        return SizedBox(
          width: double.infinity,
          child: AppPrimaryButton(
            text: '適用',
            isLoading: _isApplying,
            onPressed: canApply
                ? () async {
                    setState(() => _isApplying = true);
                    widget.ref
                        .read(recipeFilterStateProvider.notifier)
                        .setFilter(
                          RecipeFilter(
                            categories: categories,
                            sortOrder: widget.sortOrder.value,
                          ),
                        );
                    widget.ref
                        .read(recipeFilterStateProvider.notifier)
                        .saveCurrentWithGeneratedName();
                    await Future<void>.delayed(
                      const Duration(milliseconds: 200),
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  }
                : null,
          ),
        );
      },
    );
  }
}

class _FilterChipTile extends StatelessWidget {
  const _FilterChipTile({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, textAlign: TextAlign.center),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: AppColors.primary.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
