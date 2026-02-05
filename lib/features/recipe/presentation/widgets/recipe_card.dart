import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';
import 'package:my_recipe_memo/features/recipe/models/recipe.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
      future: MetadataFetch.extract(recipe.url),
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
                  extra: {'url': recipe.url, 'title': recipe.title},
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(imageUrl: imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                recipe.title,
                                style: AppTextStyles.size16Bold(height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                              color: AppColors.primary,
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
            : const Icon(
                Icons.photo,
                color: AppColors.textSecondary,
                size: 32,
              ),
      ),
    );
  }
}
