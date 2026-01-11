// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimetableEvent _$TimetableEventFromJson(Map<String, dynamic> json) =>
    _TimetableEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$TimetableEventToJson(_TimetableEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'location': instance.location,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
    };
