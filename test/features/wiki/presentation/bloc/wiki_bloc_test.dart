import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';
import 'package:sggw_days/features/wiki/data/repositories/wiki_repository.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_event.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_state.dart';

class _StreamingWikiRepository extends WikiRepository {
  final StreamController<List<WikiArticle>> controller =
      StreamController<List<WikiArticle>>();

  @override
  Future<List<WikiArticle>> getArticles() async => const [];

  @override
  Stream<List<WikiArticle>> watchArticles() => controller.stream;
}

void main() {
  test('keeps category and search filters when articles change', () async {
    const historyArticle = WikiArticle(
      id: 'history-1',
      title: 'Old Library',
      content: 'Campus history',
      category: 'history',
      tags: ['library'],
    );
    const foodArticle = WikiArticle(
      id: 'food-1',
      title: 'Lunch Spots',
      content: 'Places to eat',
      category: 'food',
      tags: ['food'],
    );
    const updatedHistoryArticle = WikiArticle(
      id: 'history-2',
      title: 'Library Stories',
      content: 'Updated campus history',
      category: 'history',
      tags: ['library'],
    );

    final repository = _StreamingWikiRepository();
    final bloc = WikiBloc(repository: repository);

    final firstSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<WikiState>().having(
          (state) => state.articles.length,
          'article count',
          2,
        ),
      ),
    );
    bloc.add(const LoadWikiArticles());
    repository.controller.add(const [historyArticle, foodArticle]);
    await firstSnapshot;

    bloc.add(const FilterArticlesByCategory('history'));
    bloc.add(const SearchArticles('library'));
    await Future<void>.delayed(Duration.zero);

    final updatedSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<WikiState>()
            .having(
              (state) => state.filteredArticles.map((article) => article.id),
              'filtered article ids',
              ['history-2'],
            )
            .having(
              (state) => state.selectedCategory,
              'selected category',
              'history',
            )
            .having((state) => state.searchQuery, 'search query', 'library'),
      ),
    );
    repository.controller.add(const [updatedHistoryArticle, foodArticle]);
    await updatedSnapshot;

    await bloc.close();
    await repository.controller.close();
  });
}
