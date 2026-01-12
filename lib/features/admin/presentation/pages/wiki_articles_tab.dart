import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class WikiArticlesTab extends StatelessWidget {
  const WikiArticlesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading && state.wikiArticles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Wiki Article'),
              ),
            ),
            Expanded(
              child: state.wikiArticles.isEmpty
                  ? const Center(child: Text('No wiki articles yet'))
                  : ListView.builder(
                      itemCount: state.wikiArticles.length,
                      itemBuilder: (context, index) {
                        final article = state.wikiArticles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.article),
                            title: Text(article.title),
                            subtitle: Text(
                              'Category: ${article.category} | Tags: ${article.tags.join(", ")}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showAddEditDialog(
                                    context,
                                    article: article,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _showDeleteDialog(context, article),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditDialog(BuildContext context, {WikiArticle? article}) {
    final titleController = TextEditingController(text: article?.title ?? '');
    final contentController = TextEditingController(
      text: article?.content ?? '',
    );
    final categoryController = TextEditingController(
      text: article?.category ?? '',
    );
    final imageUrlController = TextEditingController(
      text: article?.imageUrl ?? '',
    );
    final tagsController = TextEditingController(
      text: article?.tags.join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(article == null ? 'Add Wiki Article' : 'Edit Wiki Article'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                  ),
                ),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content (Markdown)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tags = tagsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              final newArticle = WikiArticle(
                id: article?.id ?? '',
                title: titleController.text,
                content: contentController.text,
                category: categoryController.text,
                imageUrl: imageUrlController.text.isEmpty
                    ? null
                    : imageUrlController.text,
                tags: tags,
              );

              if (article == null) {
                context.read<AdminBloc>().add(CreateWikiArticle(newArticle));
              } else {
                context.read<AdminBloc>().add(UpdateWikiArticle(newArticle));
              }

              Navigator.of(dialogContext).pop();
            },
            child: Text(article == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WikiArticle article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Wiki Article'),
        content: Text('Are you sure you want to delete "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteWikiArticle(article.id));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
