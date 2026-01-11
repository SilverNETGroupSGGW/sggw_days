import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sggw_days/l10n/app_localizations.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_event.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_state.dart';

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
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
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

          if (state.filteredArticles.isEmpty) {
            return const Center(child: Text('No articles found'));
          }

          return ListView.builder(
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
      appBar: AppBar(
        title: Text(article.title as String),
      ),
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
            MarkdownBody(
              data: article.content as String,
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }
}
