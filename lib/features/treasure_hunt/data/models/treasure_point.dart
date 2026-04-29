import 'package:freezed_annotation/freezed_annotation.dart';

part 'treasure_point.freezed.dart';
part 'treasure_point.g.dart';

enum PointType {
  @JsonValue('treasurePoint')
  treasurePoint,
  @JsonValue('pointOfInterest')
  pointOfInterest,
}

@freezed
abstract class TreasurePoint with _$TreasurePoint {
  const factory TreasurePoint({
    required String id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String qrCode,
    String? imageUrl,
    String? iconName,
    @Default(PointType.pointOfInterest)
    @JsonKey(unknownEnumValue: PointType.pointOfInterest)
    PointType type,
    @Default(0) int order,
  }) = _TreasurePoint;

  factory TreasurePoint.fromJson(Map<String, dynamic> json) =>
      _$TreasurePointFromJson(json);
}
