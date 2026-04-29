import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sggw_days/core/icons/material_symbol_catalog.dart';
import 'package:sggw_days/core/icons/material_symbol_field.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/admin/presentation/widgets/invalid_entries_banner.dart';
import 'package:sggw_days/features/admin/presentation/widgets/treasure_point_selector.dart';
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
            InvalidEntriesBanner(
              entries: state.invalidWikiArticles,
              collection: 'wiki_articles',
            ),
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
                            leading: Icon(
                              materialSymbolForName(
                                article.iconName,
                                fallback: Icons.article,
                              ),
                            ),
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
    final iconNameController = TextEditingController(
      text: normalizeMaterialSymbolName(article?.iconName) ?? '',
    );

    List<String> selectedPointIds = List<String>.from(
      article?.treasurePointIds ?? [],
    );

    bool useImageUpload = false;
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            article == null ? 'Add Wiki Article' : 'Edit Wiki Article',
          ),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Image URL'),
                      const Spacer(),
                      Switch(
                        value: useImageUpload,
                        onChanged: (value) {
                          setState(() => useImageUpload = value);
                        },
                      ),
                      const Text('Upload Image'),
                    ],
                  ),
                  if (!useImageUpload)
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (optional)',
                      ),
                    )
                  else
                    Column(
                      children: [
                        if (selectedImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                selectedImageBytes!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedImageName ?? 'No image selected',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (picked != null) {
                                  final bytes = await picked.readAsBytes();
                                  setState(() {
                                    selectedImageBytes = bytes;
                                    selectedImageName = picked.name;
                                  });
                                }
                              },
                              icon: const Icon(Icons.upload),
                              label: const Text('Choose Image'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  MaterialSymbolField(
                    controller: iconNameController,
                    fallbackIcon: Icons.article,
                    labelText: 'Fallback Material Symbol',
                    emptyHelperText:
                        'Leave empty to use the default article icon.',
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 16),
                  TreasurePointSelector(
                    availablePoints: dialogContext
                        .read<AdminBloc>()
                        .state
                        .treasurePoints,
                    selectedIds: selectedPointIds,
                    onChanged: (ids) {
                      setState(() => selectedPointIds = ids);
                    },
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
              onPressed: isUploading
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      final category = categoryController.text.trim();

                      if (title.isEmpty ||
                          content.isEmpty ||
                          category.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Title, category, and content are required.',
                            ),
                          ),
                        );
                        return;
                      }

                      String? imageUrl = imageUrlController.text.trim().isEmpty
                          ? null
                          : imageUrlController.text.trim();

                      if (imageUrl != null) {
                        final imageUri = Uri.tryParse(imageUrl);
                        final isValidHttpsImage =
                            imageUri != null &&
                            imageUri.scheme == 'https' &&
                            imageUri.host.isNotEmpty;
                        if (!isValidHttpsImage) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Image URL must use HTTPS.'),
                            ),
                          );
                          return;
                        }
                      }

                      if (useImageUpload &&
                          selectedImageBytes != null &&
                          selectedImageName != null) {
                        setState(() => isUploading = true);
                        try {
                          final repo = dialogContext.read<AdminRepository>();
                          imageUrl = await repo.uploadImage(
                            imageBytes: selectedImageBytes!,
                            fileName:
                                '${DateTime.now().millisecondsSinceEpoch}_$selectedImageName',
                            folder: 'wiki_images',
                          );
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Image upload failed: $e'),
                                backgroundColor: Theme.of(
                                  dialogContext,
                                ).colorScheme.error,
                              ),
                            );
                          }
                          setState(() => isUploading = false);
                          return;
                        }
                        setState(() => isUploading = false);
                      }

                      if (!dialogContext.mounted) return;

                      final tags = tagsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      final requestedIconName = iconNameController.text.trim();
                      final iconName = normalizeMaterialSymbolName(
                        requestedIconName,
                      );
                      if (requestedIconName.isNotEmpty && iconName == null) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Choose a valid Material Symbol name or leave it empty.',
                            ),
                          ),
                        );
                        return;
                      }

                      final newArticle = WikiArticle(
                        id: article?.id ?? '',
                        title: title,
                        content: content,
                        category: category,
                        imageUrl: imageUrl,
                        iconName: iconName,
                        tags: tags,
                        treasurePointIds: selectedPointIds,
                      );

                      if (!dialogContext.mounted) return;

                      if (article == null) {
                        dialogContext.read<AdminBloc>().add(
                          CreateWikiArticle(newArticle),
                        );
                      } else {
                        dialogContext.read<AdminBloc>().add(
                          UpdateWikiArticle(newArticle),
                        );
                      }

                      Navigator.of(dialogContext).pop();
                    },
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(article == null ? 'Add' : 'Update'),
            ),
          ],
        ),
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
