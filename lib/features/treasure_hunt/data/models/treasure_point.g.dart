// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treasure_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TreasurePoint _$TreasurePointFromJson(Map<String, dynamic> json) =>
    _TreasurePoint(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      qrCode: json['qrCode'] as String,
      isFound: json['isFound'] as bool? ?? false,
      type:
          $enumDecodeNullable(
            _$PointTypeEnumMap,
            json['type'],
            unknownValue: PointType.pointOfInterest,
          ) ??
          PointType.pointOfInterest,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TreasurePointToJson(_TreasurePoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'qrCode': instance.qrCode,
      'isFound': instance.isFound,
      'type': _$PointTypeEnumMap[instance.type]!,
      'order': instance.order,
    };

const _$PointTypeEnumMap = {
  PointType.treasurePoint: 'treasurePoint',
  PointType.pointOfInterest: 'pointOfInterest',
};
