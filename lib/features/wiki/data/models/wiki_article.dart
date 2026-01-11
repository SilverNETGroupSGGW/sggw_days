import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_article.freezed.dart';
part 'wiki_article.g.dart';

@freezed
abstract class WikiArticle with _$WikiArticle {
  const factory WikiArticle({
    required String id,
    required String title,
    required String content,
    required String category,
    String? imageUrl,
    @Default([]) List<String> tags,
  }) = _WikiArticle;

  factory WikiArticle.fromJson(Map<String, dynamic> json) =>
      _$WikiArticleFromJson(json);
}
