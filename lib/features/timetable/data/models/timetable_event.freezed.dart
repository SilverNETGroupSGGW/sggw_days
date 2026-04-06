// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimetableEvent {

 String get id; String get title; String get description; DateTime get startTime; DateTime get endTime; String get location; String? get imageUrl; List<String> get tags; List<String> get treasurePointIds;
/// Create a copy of TimetableEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimetableEventCopyWith<TimetableEvent> get copyWith => _$TimetableEventCopyWithImpl<TimetableEvent>(this as TimetableEvent, _$identity);

  /// Serializes this TimetableEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.treasurePointIds, treasurePointIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,startTime,endTime,location,imageUrl,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(treasurePointIds));

@override
String toString() {
  return 'TimetableEvent(id: $id, title: $title, description: $description, startTime: $startTime, endTime: $endTime, location: $location, imageUrl: $imageUrl, tags: $tags, treasurePointIds: $treasurePointIds)';
}


}

/// @nodoc
abstract mixin class $TimetableEventCopyWith<$Res>  {
  factory $TimetableEventCopyWith(TimetableEvent value, $Res Function(TimetableEvent) _then) = _$TimetableEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, DateTime startTime, DateTime endTime, String location, String? imageUrl, List<String> tags, List<String> treasurePointIds
});




}
/// @nodoc
class _$TimetableEventCopyWithImpl<$Res>
    implements $TimetableEventCopyWith<$Res> {
  _$TimetableEventCopyWithImpl(this._self, this._then);

  final TimetableEvent _self;
  final $Res Function(TimetableEvent) _then;

/// Create a copy of TimetableEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? startTime = null,Object? endTime = null,Object? location = null,Object? imageUrl = freezed,Object? tags = null,Object? treasurePointIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,treasurePointIds: null == treasurePointIds ? _self.treasurePointIds : treasurePointIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimetableEvent].
extension TimetableEventPatterns on TimetableEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimetableEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimetableEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimetableEvent value)  $default,){
final _that = this;
switch (_that) {
case _TimetableEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimetableEvent value)?  $default,){
final _that = this;
switch (_that) {
case _TimetableEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime startTime,  DateTime endTime,  String location,  String? imageUrl,  List<String> tags,  List<String> treasurePointIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimetableEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.startTime,_that.endTime,_that.location,_that.imageUrl,_that.tags,_that.treasurePointIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime startTime,  DateTime endTime,  String location,  String? imageUrl,  List<String> tags,  List<String> treasurePointIds)  $default,) {final _that = this;
switch (_that) {
case _TimetableEvent():
return $default(_that.id,_that.title,_that.description,_that.startTime,_that.endTime,_that.location,_that.imageUrl,_that.tags,_that.treasurePointIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  DateTime startTime,  DateTime endTime,  String location,  String? imageUrl,  List<String> tags,  List<String> treasurePointIds)?  $default,) {final _that = this;
switch (_that) {
case _TimetableEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.startTime,_that.endTime,_that.location,_that.imageUrl,_that.tags,_that.treasurePointIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimetableEvent implements TimetableEvent {
  const _TimetableEvent({required this.id, required this.title, required this.description, required this.startTime, required this.endTime, required this.location, this.imageUrl, final  List<String> tags = const [], final  List<String> treasurePointIds = const []}): _tags = tags,_treasurePointIds = treasurePointIds;
  factory _TimetableEvent.fromJson(Map<String, dynamic> json) => _$TimetableEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  DateTime startTime;
@override final  DateTime endTime;
@override final  String location;
@override final  String? imageUrl;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<String> _treasurePointIds;
@override@JsonKey() List<String> get treasurePointIds {
  if (_treasurePointIds is EqualUnmodifiableListView) return _treasurePointIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_treasurePointIds);
}


/// Create a copy of TimetableEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimetableEventCopyWith<_TimetableEvent> get copyWith => __$TimetableEventCopyWithImpl<_TimetableEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimetableEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimetableEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._treasurePointIds, _treasurePointIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,startTime,endTime,location,imageUrl,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_treasurePointIds));

@override
String toString() {
  return 'TimetableEvent(id: $id, title: $title, description: $description, startTime: $startTime, endTime: $endTime, location: $location, imageUrl: $imageUrl, tags: $tags, treasurePointIds: $treasurePointIds)';
}


}

/// @nodoc
abstract mixin class _$TimetableEventCopyWith<$Res> implements $TimetableEventCopyWith<$Res> {
  factory _$TimetableEventCopyWith(_TimetableEvent value, $Res Function(_TimetableEvent) _then) = __$TimetableEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, DateTime startTime, DateTime endTime, String location, String? imageUrl, List<String> tags, List<String> treasurePointIds
});




}
/// @nodoc
class __$TimetableEventCopyWithImpl<$Res>
    implements _$TimetableEventCopyWith<$Res> {
  __$TimetableEventCopyWithImpl(this._self, this._then);

  final _TimetableEvent _self;
  final $Res Function(_TimetableEvent) _then;

/// Create a copy of TimetableEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? startTime = null,Object? endTime = null,Object? location = null,Object? imageUrl = freezed,Object? tags = null,Object? treasurePointIds = null,}) {
  return _then(_TimetableEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,treasurePointIds: null == treasurePointIds ? _self._treasurePointIds : treasurePointIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
