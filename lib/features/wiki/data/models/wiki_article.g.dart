// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WikiArticle _$WikiArticleFromJson(Map<String, dynamic> json) => _WikiArticle(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  category: json['category'] as String,
  imageUrl: json['imageUrl'] as String?,
  iconName: json['iconName'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  treasurePointIds:
      (json['treasurePointIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$WikiArticleToJson(_WikiArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'iconName': instance.iconName,
      'tags': instance.tags,
      'treasurePointIds': instance.treasurePointIds,
    };
