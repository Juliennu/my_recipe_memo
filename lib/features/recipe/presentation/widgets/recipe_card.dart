import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:my_recipe_memo/features/recipe/presentation/providers/recipe_providers.dart';

class RecipeCard extends ConsumerStatefulWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  ConsumerState<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends ConsumerState<RecipeCard>
    with AutomaticKeepAliveClientMixin {
  late Future<Metadata?> _metadataFuture;

  @override
  void initState() {
    super.initState();
    _metadataFuture = MetadataFetch.extract(widget.recipe.url);
  }

  @override
  void didUpdateWidget(covariant RecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipe.url != widget.recipe.url) {
      _metadataFuture = MetadataFetch.extract(widget.recipe.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final overrides = ref.watch(favoriteOverridesProvider);
    final recipeId = widget.recipe.id;
    final isFavorite = recipeId == null
        ? widget.recipe.isFavorite
        : overrides[recipeId] ?? widget.recipe.isFavorite;

    return FutureBuilder<Metadata?>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        final meta = snapshot.data;
        final imageUrl = meta?.image;
        final metaTitle = meta?.title;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.push(
                  '/webview',
                  extra: {
                    'url': widget.recipe.url,
                    'title': widget.recipe.title,
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(imageUrl: imageUrl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.recipe.title,
                                style: AppTextStyles.size16Bold(height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              iconSize: 28,
                              splashRadius: 28,
                              onPressed: widget.recipe.id == null
                                  ? null
                                  : () {
                                      ref
                                          .read(
                                            favoriteControllerProvider.notifier,
                                          )
                                          .toggleFavorite(widget.recipe);
                                    },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (metaTitle != null && metaTitle.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            metaTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.size12Regular(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(isLoading: true),
        errorWidget: (context, url, error) => _placeholder(),
      ),
    );
  }

  Widget _placeholder({bool isLoading = false}) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        height: 120,
        width: double.infinity,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              )
            : const Icon(Icons.photo, color: AppColors.textSecondary, size: 32),
      ),
    );
  }
}
