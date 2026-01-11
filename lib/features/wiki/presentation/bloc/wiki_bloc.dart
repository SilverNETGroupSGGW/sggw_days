import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/wiki/data/repositories/wiki_repository.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_event.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_state.dart';

class WikiBloc extends Bloc<WikiEvent, WikiState> {
  final WikiRepository _repository;

  WikiBloc({required WikiRepository repository})
    : _repository = repository,
      super(const WikiState()) {
    on<LoadWikiArticles>(_onLoadWikiArticles);
    on<FilterArticlesByCategory>(_onFilterArticlesByCategory);
    on<SearchArticles>(_onSearchArticles);
  }

  Future<void> _onLoadWikiArticles(
    LoadWikiArticles event,
    Emitter<WikiState> emit,
  ) async {
    emit(state.copyWith(status: WikiStatus.loading));
    try {
      final articles = await _repository.getArticles();
      emit(
        state.copyWith(
          status: WikiStatus.success,
          articles: articles,
          filteredArticles: articles,
        ),
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
    if (event.category == null) {
      emit(
        state.copyWith(
          filteredArticles: state.articles,
          selectedCategory: null,
        ),
      );
    } else {
      final filtered = state.articles
          .where((article) => article.category == event.category)
          .toList();
      emit(
        state.copyWith(
          filteredArticles: filtered,
          selectedCategory: event.category,
        ),
      );
    }
  }

  void _onSearchArticles(SearchArticles event, Emitter<WikiState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredArticles: state.articles, searchQuery: null));
    } else {
      final query = event.query.toLowerCase();
      final filtered = state.articles.where((article) {
        return article.title.toLowerCase().contains(query) ||
            article.content.toLowerCase().contains(query) ||
            article.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
      emit(
        state.copyWith(filteredArticles: filtered, searchQuery: event.query),
      );
    }
  }
}
