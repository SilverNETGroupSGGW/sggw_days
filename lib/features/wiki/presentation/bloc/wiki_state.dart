import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

enum WikiStatus { initial, loading, success, error }

class WikiState extends Equatable {
  final WikiStatus status;
  final List<WikiArticle> articles;
  final List<WikiArticle> filteredArticles;
  final String? selectedCategory;
  final String? searchQuery;
  final String? errorMessage;

  const WikiState({
    this.status = WikiStatus.initial,
    this.articles = const [],
    this.filteredArticles = const [],
    this.selectedCategory,
    this.searchQuery,
    this.errorMessage,
  });

  WikiState copyWith({
    WikiStatus? status,
    List<WikiArticle>? articles,
    List<WikiArticle>? filteredArticles,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return WikiState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      selectedCategory: selectedCategory,
      searchQuery: searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    articles,
    filteredArticles,
    selectedCategory,
    searchQuery,
    errorMessage,
  ];
}
