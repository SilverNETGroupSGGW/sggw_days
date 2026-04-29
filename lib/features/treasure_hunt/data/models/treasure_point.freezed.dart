// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'treasure_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TreasurePoint {

 String get id; String get name; String get description; double get latitude; double get longitude; String get qrCode; String? get imageUrl; String? get iconName;@JsonKey(unknownEnumValue: PointType.pointOfInterest) PointType get type; int get order;
/// Create a copy of TreasurePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TreasurePointCopyWith<TreasurePoint> get copyWith => _$TreasurePointCopyWithImpl<TreasurePoint>(this as TreasurePoint, _$identity);

  /// Serializes this TreasurePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TreasurePoint&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.type, type) || other.type == type)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,latitude,longitude,qrCode,imageUrl,iconName,type,order);

@override
String toString() {
  return 'TreasurePoint(id: $id, name: $name, description: $description, latitude: $latitude, longitude: $longitude, qrCode: $qrCode, imageUrl: $imageUrl, iconName: $iconName, type: $type, order: $order)';
}


}

/// @nodoc
abstract mixin class $TreasurePointCopyWith<$Res>  {
  factory $TreasurePointCopyWith(TreasurePoint value, $Res Function(TreasurePoint) _then) = _$TreasurePointCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, double latitude, double longitude, String qrCode, String? imageUrl, String? iconName,@JsonKey(unknownEnumValue: PointType.pointOfInterest) PointType type, int order
});




}
/// @nodoc
class _$TreasurePointCopyWithImpl<$Res>
    implements $TreasurePointCopyWith<$Res> {
  _$TreasurePointCopyWithImpl(this._self, this._then);

  final TreasurePoint _self;
  final $Res Function(TreasurePoint) _then;

/// Create a copy of TreasurePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? latitude = null,Object? longitude = null,Object? qrCode = null,Object? imageUrl = freezed,Object? iconName = freezed,Object? type = null,Object? order = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PointType,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TreasurePoint].
extension TreasurePointPatterns on TreasurePoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TreasurePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TreasurePoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TreasurePoint value)  $default,){
final _that = this;
switch (_that) {
case _TreasurePoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TreasurePoint value)?  $default,){
final _that = this;
switch (_that) {
case _TreasurePoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double latitude,  double longitude,  String qrCode,  String? imageUrl,  String? iconName, @JsonKey(unknownEnumValue: PointType.pointOfInterest)  PointType type,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TreasurePoint() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.latitude,_that.longitude,_that.qrCode,_that.imageUrl,_that.iconName,_that.type,_that.order);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double latitude,  double longitude,  String qrCode,  String? imageUrl,  String? iconName, @JsonKey(unknownEnumValue: PointType.pointOfInterest)  PointType type,  int order)  $default,) {final _that = this;
switch (_that) {
case _TreasurePoint():
return $default(_that.id,_that.name,_that.description,_that.latitude,_that.longitude,_that.qrCode,_that.imageUrl,_that.iconName,_that.type,_that.order);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  double latitude,  double longitude,  String qrCode,  String? imageUrl,  String? iconName, @JsonKey(unknownEnumValue: PointType.pointOfInterest)  PointType type,  int order)?  $default,) {final _that = this;
switch (_that) {
case _TreasurePoint() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.latitude,_that.longitude,_that.qrCode,_that.imageUrl,_that.iconName,_that.type,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TreasurePoint implements TreasurePoint {
  const _TreasurePoint({required this.id, required this.name, required this.description, required this.latitude, required this.longitude, required this.qrCode, this.imageUrl, this.iconName, @JsonKey(unknownEnumValue: PointType.pointOfInterest) this.type = PointType.pointOfInterest, this.order = 0});
  factory _TreasurePoint.fromJson(Map<String, dynamic> json) => _$TreasurePointFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  double latitude;
@override final  double longitude;
@override final  String qrCode;
@override final  String? imageUrl;
@override final  String? iconName;
@override@JsonKey(unknownEnumValue: PointType.pointOfInterest) final  PointType type;
@override@JsonKey() final  int order;

/// Create a copy of TreasurePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TreasurePointCopyWith<_TreasurePoint> get copyWith => __$TreasurePointCopyWithImpl<_TreasurePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TreasurePointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TreasurePoint&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.type, type) || other.type == type)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,latitude,longitude,qrCode,imageUrl,iconName,type,order);

@override
String toString() {
  return 'TreasurePoint(id: $id, name: $name, description: $description, latitude: $latitude, longitude: $longitude, qrCode: $qrCode, imageUrl: $imageUrl, iconName: $iconName, type: $type, order: $order)';
}


}

/// @nodoc
abstract mixin class _$TreasurePointCopyWith<$Res> implements $TreasurePointCopyWith<$Res> {
  factory _$TreasurePointCopyWith(_TreasurePoint value, $Res Function(_TreasurePoint) _then) = __$TreasurePointCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, double latitude, double longitude, String qrCode, String? imageUrl, String? iconName,@JsonKey(unknownEnumValue: PointType.pointOfInterest) PointType type, int order
});




}
/// @nodoc
class __$TreasurePointCopyWithImpl<$Res>
    implements _$TreasurePointCopyWith<$Res> {
  __$TreasurePointCopyWithImpl(this._self, this._then);

  final _TreasurePoint _self;
  final $Res Function(_TreasurePoint) _then;

/// Create a copy of TreasurePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? latitude = null,Object? longitude = null,Object? qrCode = null,Object? imageUrl = freezed,Object? iconName = freezed,Object? type = null,Object? order = null,}) {
  return _then(_TreasurePoint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PointType,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
