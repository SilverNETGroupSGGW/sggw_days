import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';
import 'package:sggw_days/features/wiki/data/repositories/wiki_repository.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_event.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_state.dart';

class WikiBloc extends Bloc<WikiEvent, WikiState> {
  final WikiRepository _repository;
  StreamSubscription<List<WikiArticle>>? _articlesSubscription;

  WikiBloc({required WikiRepository repository})
    : _repository = repository,
      super(const WikiState()) {
    on<LoadWikiArticles>(_onLoadWikiArticles);
    on<FilterArticlesByCategory>(_onFilterArticlesByCategory);
    on<SearchArticles>(_onSearchArticles);
    on<_WikiArticlesUpdated>(_onWikiArticlesUpdated);
    on<_WikiArticlesFailed>(_onWikiArticlesFailed);
  }

  Future<void> _onLoadWikiArticles(
    LoadWikiArticles event,
    Emitter<WikiState> emit,
  ) async {
    emit(state.copyWith(status: WikiStatus.loading));
    try {
      await _articlesSubscription?.cancel();
      _articlesSubscription = _repository.watchArticles().listen(
        (articles) => add(_WikiArticlesUpdated(articles)),
        onError: (Object error) => add(_WikiArticlesFailed(error.toString())),
      );
    } catch (e) {
      emit(
        state.copyWith(status: WikiStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onFilterArticlesByCategory(
    FilterArticlesByCategory event,
    Emitter<WikiState> emit,
  ) {
    final filtered = _filterArticles(
      state.articles,
      category: event.category,
      query: state.searchQuery,
    );
    emit(
      state.copyWith(
        filteredArticles: filtered,
        selectedCategory: event.category,
      ),
    );
  }

  void _onSearchArticles(SearchArticles event, Emitter<WikiState> emit) {
    final normalizedQuery = event.query.trim().isEmpty ? null : event.query;
    final filtered = _filterArticles(
      state.articles,
      category: state.selectedCategory,
      query: normalizedQuery,
    );
    emit(
      state.copyWith(filteredArticles: filtered, searchQuery: normalizedQuery),
    );
  }

  void _onWikiArticlesUpdated(
    _WikiArticlesUpdated event,
    Emitter<WikiState> emit,
  ) {
    final filtered = _filterArticles(
      event.articles,
      category: state.selectedCategory,
      query: state.searchQuery,
    );
    emit(
      state.copyWith(
        status: WikiStatus.success,
        articles: event.articles,
        filteredArticles: filtered,
        errorMessage: null,
      ),
    );
  }

  void _onWikiArticlesFailed(
    _WikiArticlesFailed event,
    Emitter<WikiState> emit,
  ) {
    emit(
      state.copyWith(
        status: state.articles.isEmpty ? WikiStatus.error : WikiStatus.success,
        errorMessage: event.message,
      ),
    );
  }

  List<WikiArticle> _filterArticles(
    List<WikiArticle> articles, {
    required String? category,
    required String? query,
  }) {
    var filtered = articles;

    if (category != null) {
      filtered = filtered
          .where((article) => article.category == category)
          .toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final normalizedQuery = query.toLowerCase();
      filtered = filtered.where((article) {
        return article.title.toLowerCase().contains(normalizedQuery) ||
            article.content.toLowerCase().contains(normalizedQuery) ||
            article.tags.any(
              (tag) => tag.toLowerCase().contains(normalizedQuery),
            );
      }).toList();
    }

    return filtered;
  }

  @override
  Future<void> close() async {
    await _articlesSubscription?.cancel();
    return super.close();
  }
}

class _WikiArticlesUpdated extends WikiEvent {
  final List<WikiArticle> articles;

  const _WikiArticlesUpdated(this.articles);

  @override
  List<Object?> get props => [articles];
}

class _WikiArticlesFailed extends WikiEvent {
  final String message;

  const _WikiArticlesFailed(this.message);

  @override
  List<Object?> get props => [message];
}
