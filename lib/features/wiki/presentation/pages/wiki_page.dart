import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/core/icons/material_symbol_catalog.dart';
import 'package:sggw_days/core/widgets/fullscreen_network_image.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/point_type_presentation.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/widgets/treasure_hunt_widgets.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_event.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class WikiPage extends StatefulWidget {
  const WikiPage({super.key, this.initialArticleId});

  final String? initialArticleId;

  @override
  State<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _pendingInitialArticleId;
  bool _isOpeningInitialArticle = false;

  @override
  void initState() {
    super.initState();
    _pendingInitialArticleId = widget.initialArticleId;
  }

  @override
  void didUpdateWidget(covariant WikiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialArticleId != widget.initialArticleId) {
      _pendingInitialArticleId = widget.initialArticleId;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wiki),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (query) {
                context.read<WikiBloc>().add(SearchArticles(query));
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<WikiBloc, WikiState>(
        listener: (context, state) {
          if (state.status == WikiStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == WikiStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          _maybeOpenInitialArticleFromRoute(context, state);

          // Extract unique categories
          final categories =
              state.articles.map((a) => a.category).toSet().toList()..sort();

          return Column(
            children: [
              if (categories.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _CategoryFilterChip(
                          label: Text(l10n.allCategories),
                          selected: state.selectedCategory == null,
                          onSelected: (_) {
                            context.read<WikiBloc>().add(
                              const FilterArticlesByCategory(null),
                            );
                          },
                        ),
                      ),
                      ...categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _CategoryFilterChip(
                            label: Text(category),
                            selected: state.selectedCategory == category,
                            onSelected: (_) {
                              context.read<WikiBloc>().add(
                                FilterArticlesByCategory(
                                  state.selectedCategory == category
                                      ? null
                                      : category,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              if (state.filteredArticles.isEmpty)
                Expanded(child: Center(child: Text(l10n.noArticlesFound)))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = state.filteredArticles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: _ArticleThumbnail(
                            imageUrl: article.imageUrl,
                            iconName: article.iconName,
                          ),
                          title: Text(article.title),
                          subtitle: Text(
                            article.category,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => GoRouter.of(
                            context,
                          ).go(_articleLocation(article.id)),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _maybeOpenInitialArticleFromRoute(
    BuildContext context,
    WikiState state,
  ) {
    final articleId = _pendingInitialArticleId;
    if (articleId == null ||
        _isOpeningInitialArticle ||
        state.status != WikiStatus.success) {
      return;
    }

    final article = state.articles
        .where((candidate) => candidate.id == articleId)
        .firstOrNull;
    _pendingInitialArticleId = null;
    _isOpeningInitialArticle = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      GoRouter.of(context).replace('/wiki');

      if (article == null) {
        _isOpeningInitialArticle = false;
        return;
      }

      unawaited(
        _showArticleDetails(context, article).whenComplete(() {
          if (mounted) {
            _isOpeningInitialArticle = false;
          }
        }),
      );
    });
  }

  String _articleLocation(String articleId) {
    return Uri(
      path: '/wiki',
      queryParameters: {'articleId': articleId},
    ).toString();
  }

  String _pointLocation(String pointId) {
    return Uri(path: '/', queryParameters: {'pointId': pointId}).toString();
  }

  Future<void> _showArticleDetails(BuildContext context, WikiArticle article) {
    final relatedPoints = context
        .read<TreasureHuntBloc>()
        .state
        .points
        .where((point) => article.treasurePointIds.contains(point.id))
        .toList();

    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (pageContext) => _ArticleDetailsPage(
          article: article,
          relatedPoints: relatedPoints,
          onOpenTreasureHunt: () => GoRouter.of(context).go('/'),
          onOpenPoint: (point) =>
              GoRouter.of(context).go(_pointLocation(point.id)),
        ),
      ),
    );
  }
}

class _ArticleDetailsPage extends StatelessWidget {
  final WikiArticle article;
  final List<TreasurePoint> relatedPoints;
  final VoidCallback onOpenTreasureHunt;
  final ValueChanged<TreasurePoint> onOpenPoint;

  const _ArticleDetailsPage({
    required this.article,
    required this.relatedPoints,
    required this.onOpenTreasureHunt,
    required this.onOpenPoint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    void closeThen(VoidCallback action) {
      Navigator.pop(context);
      unawaited(Future<void>.delayed(Duration.zero, action));
    }

    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArticleHero(
              imageUrl: article.imageUrl,
              iconName: article.iconName,
              semanticLabel: article.title,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(article.category),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ...article.tags.map(
                  (tag) => Chip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MarkdownBody(
              data: article.content,
              selectable: true,
              imageBuilder: (uri, title, alt) =>
                  _MarkdownArticleImage(imageUrl: uri.toString(), altText: alt),
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                h1: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
                h1Padding: const EdgeInsets.only(top: 18, bottom: 8),
                h2: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
                h2Padding: const EdgeInsets.only(top: 16, bottom: 6),
                h3: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                h3Padding: const EdgeInsets.only(top: 12, bottom: 4),
                blockSpacing: 12,
                blockquoteDecoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
            if (relatedPoints.isNotEmpty) ...[
              const SizedBox(height: 24),
              SectionHeader(
                title: l10n.relatedPoints,
                actionLabel: l10n.treasureHunt,
                onAction: () => closeThen(onOpenTreasureHunt),
              ),
              const SizedBox(height: 8),
              ...relatedPoints.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PointPreviewTile(
                    icon: iconForPoint(point),
                    accentColor: colorForPointType(
                      point.type,
                      theme.colorScheme,
                    ),
                    title: point.name,
                    subtitle: labelForPointType(point.type, l10n),
                    detail: point.type == PointType.treasurePoint
                        ? l10n.treasurePointNumber(point.order + 1)
                        : null,
                    onTap: () => closeThen(() => onOpenPoint(point)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArticleThumbnail extends StatelessWidget {
  final String? imageUrl;
  final String? iconName;

  const _ArticleThumbnail({required this.imageUrl, required this.iconName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 56,
        child: imageUrl == null
            ? _ArticlePlaceholderIcon(
                theme: theme,
                iconName: iconName,
                iconSize: 28,
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _ArticlePlaceholderIcon(
                      theme: theme,
                      iconName: iconName,
                      iconSize: 28,
                    ),
              ),
      ),
    );
  }
}

class _ArticleHero extends StatelessWidget {
  final String? imageUrl;
  final String? iconName;
  final String semanticLabel;

  const _ArticleHero({
    required this.imageUrl,
    required this.iconName,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: _ArticlePlaceholderIcon(
            theme: theme,
            iconName: iconName,
            iconSize: 48,
          ),
        ),
      );
    }

    return FullscreenImageTrigger(
      imageUrl: imageUrl!,
      semanticLabel: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _ArticlePlaceholderIcon(
                  theme: theme,
                  iconName: iconName,
                  iconSize: 48,
                ),
          ),
        ),
      ),
    );
  }
}

class _MarkdownArticleImage extends StatelessWidget {
  final String imageUrl;
  final String? altText;

  const _MarkdownArticleImage({required this.imageUrl, this.altText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: FullscreenImageTrigger(
            imageUrl: imageUrl,
            semanticLabel: altText,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: width,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: SizedBox(
                    width: width,
                    height: 160,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArticlePlaceholderIcon extends StatelessWidget {
  final ThemeData theme;
  final String? iconName;
  final double iconSize;

  const _ArticlePlaceholderIcon({
    required this.theme,
    required this.iconName,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        materialSymbolForName(iconName, fallback: Icons.article_outlined),
        size: iconSize,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilterChip(
        label: label,
        selected: selected,
        showCheckmark: false,
        visualDensity: VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onSelected: onSelected,
      ),
    );
  }
}
