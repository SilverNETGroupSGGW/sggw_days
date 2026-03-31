import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
          final categories = state.articles
              .map((a) => a.category)
              .toSet()
              .toList()
            ..sort();

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
                Expanded(
                  child: Center(
                    child: Text(l10n.noArticlesFound),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = state.filteredArticles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: article.imageUrl != null
                      ? Image.network(
                          article.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.article, size: 60),
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

  void _showArticleDetails(BuildContext context, dynamic article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ArticleDetailsPage(article: article),
      ),
    );
  }
}

class _ArticleDetailsPage extends StatelessWidget {
  final dynamic article;

  const _ArticleDetailsPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title as String)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Image.network(
                article.imageUrl as String,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Chip(
              label: Text(article.category as String),
              backgroundColor: Theme.of(context).colorScheme.primary,
              labelStyle: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            MarkdownBody(data: article.content as String, selectable: true),
          ],
        ),
      ),
    );
  }
}
