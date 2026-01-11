import 'package:equatable/equatable.dart';

abstract class WikiEvent extends Equatable {
  const WikiEvent();

  @override
  List<Object?> get props => [];
}

class LoadWikiArticles extends WikiEvent {
  const LoadWikiArticles();
}

class FilterArticlesByCategory extends WikiEvent {
  final String? category;

  const FilterArticlesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchArticles extends WikiEvent {
  final String query;

  const SearchArticles(this.query);

  @override
  List<Object?> get props => [query];
}
