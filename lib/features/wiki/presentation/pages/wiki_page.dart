import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_event.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class WikiPage extends StatefulWidget {
  const WikiPage({super.key});

  @override
  State<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<WikiBloc>().add(const LoadWikiArticles());
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
                        child: FilterChip(
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
                          child: FilterChip(
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
                          ),
                          title: Text(article.title),
                          subtitle: Text(
                            article.category,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _showArticleDetails(context, article),
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

  void _showArticleDetails(BuildContext context, WikiArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ArticleDetailsPage(article: article),
      ),
    );
  }
}

class _ArticleDetailsPage extends StatelessWidget {
  final WikiArticle article;

  const _ArticleDetailsPage({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArticleHero(imageUrl: article.imageUrl),
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
          ],
        ),
      ),
    );
  }
}

class _ArticleThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _ArticleThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 56,
        child: imageUrl == null
            ? _ArticlePlaceholderIcon(theme: theme, iconSize: 28)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _ArticlePlaceholderIcon(theme: theme, iconSize: 28),
              ),
      ),
    );
  }
}

class _ArticleHero extends StatelessWidget {
  final String? imageUrl;

  const _ArticleHero({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: _ArticlePlaceholderIcon(theme: theme, iconSize: 48),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _ArticlePlaceholderIcon(theme: theme, iconSize: 48),
        ),
      ),
    );
  }
}

class _ArticlePlaceholderIcon extends StatelessWidget {
  final ThemeData theme;
  final double iconSize;

  const _ArticlePlaceholderIcon({required this.theme, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.article_outlined,
        size: iconSize,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
