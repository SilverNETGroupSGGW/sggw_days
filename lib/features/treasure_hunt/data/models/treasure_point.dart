import 'package:freezed_annotation/freezed_annotation.dart';

part 'treasure_point.freezed.dart';
part 'treasure_point.g.dart';

@freezed
abstract class TreasurePoint with _$TreasurePoint {
  const factory TreasurePoint({
    required String id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String qrCode,
    @Default(false) bool isFound,
    @Default(0) int points,
  }) = _TreasurePoint;

  factory TreasurePoint.fromJson(Map<String, dynamic> json) =>
      _$TreasurePointFromJson(json);
}
