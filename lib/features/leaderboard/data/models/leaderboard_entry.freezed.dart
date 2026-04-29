// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaderboardEntry {

 String get participantId; String get displayName; int get totalScore; int get foundPointScore; int get treasureScore; int get checkInScore; DateTime? get updatedAt;
/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith => _$LeaderboardEntryCopyWithImpl<LeaderboardEntry>(this as LeaderboardEntry, _$identity);

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardEntry&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.foundPointScore, foundPointScore) || other.foundPointScore == foundPointScore)&&(identical(other.treasureScore, treasureScore) || other.treasureScore == treasureScore)&&(identical(other.checkInScore, checkInScore) || other.checkInScore == checkInScore)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,participantId,displayName,totalScore,foundPointScore,treasureScore,checkInScore,updatedAt);

@override
String toString() {
  return 'LeaderboardEntry(participantId: $participantId, displayName: $displayName, totalScore: $totalScore, foundPointScore: $foundPointScore, treasureScore: $treasureScore, checkInScore: $checkInScore, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LeaderboardEntryCopyWith<$Res>  {
  factory $LeaderboardEntryCopyWith(LeaderboardEntry value, $Res Function(LeaderboardEntry) _then) = _$LeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 String participantId, String displayName, int totalScore, int foundPointScore, int treasureScore, int checkInScore, DateTime? updatedAt
});




}
/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final LeaderboardEntry _self;
  final $Res Function(LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participantId = null,Object? displayName = null,Object? totalScore = null,Object? foundPointScore = null,Object? treasureScore = null,Object? checkInScore = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,foundPointScore: null == foundPointScore ? _self.foundPointScore : foundPointScore // ignore: cast_nullable_to_non_nullable
as int,treasureScore: null == treasureScore ? _self.treasureScore : treasureScore // ignore: cast_nullable_to_non_nullable
as int,checkInScore: null == checkInScore ? _self.checkInScore : checkInScore // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardEntry].
extension LeaderboardEntryPatterns on LeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String participantId,  String displayName,  int totalScore,  int foundPointScore,  int treasureScore,  int checkInScore,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.participantId,_that.displayName,_that.totalScore,_that.foundPointScore,_that.treasureScore,_that.checkInScore,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String participantId,  String displayName,  int totalScore,  int foundPointScore,  int treasureScore,  int checkInScore,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that.participantId,_that.displayName,_that.totalScore,_that.foundPointScore,_that.treasureScore,_that.checkInScore,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String participantId,  String displayName,  int totalScore,  int foundPointScore,  int treasureScore,  int checkInScore,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.participantId,_that.displayName,_that.totalScore,_that.foundPointScore,_that.treasureScore,_that.checkInScore,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardEntry implements LeaderboardEntry {
  const _LeaderboardEntry({required this.participantId, required this.displayName, this.totalScore = 0, this.foundPointScore = 0, this.treasureScore = 0, this.checkInScore = 0, this.updatedAt});
  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);

@override final  String participantId;
@override final  String displayName;
@override@JsonKey() final  int totalScore;
@override@JsonKey() final  int foundPointScore;
@override@JsonKey() final  int treasureScore;
@override@JsonKey() final  int checkInScore;
@override final  DateTime? updatedAt;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardEntryCopyWith<_LeaderboardEntry> get copyWith => __$LeaderboardEntryCopyWithImpl<_LeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardEntry&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.foundPointScore, foundPointScore) || other.foundPointScore == foundPointScore)&&(identical(other.treasureScore, treasureScore) || other.treasureScore == treasureScore)&&(identical(other.checkInScore, checkInScore) || other.checkInScore == checkInScore)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,participantId,displayName,totalScore,foundPointScore,treasureScore,checkInScore,updatedAt);

@override
String toString() {
  return 'LeaderboardEntry(participantId: $participantId, displayName: $displayName, totalScore: $totalScore, foundPointScore: $foundPointScore, treasureScore: $treasureScore, checkInScore: $checkInScore, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardEntryCopyWith<$Res> implements $LeaderboardEntryCopyWith<$Res> {
  factory _$LeaderboardEntryCopyWith(_LeaderboardEntry value, $Res Function(_LeaderboardEntry) _then) = __$LeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 String participantId, String displayName, int totalScore, int foundPointScore, int treasureScore, int checkInScore, DateTime? updatedAt
});




}
/// @nodoc
class __$LeaderboardEntryCopyWithImpl<$Res>
    implements _$LeaderboardEntryCopyWith<$Res> {
  __$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LeaderboardEntry _self;
  final $Res Function(_LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participantId = null,Object? displayName = null,Object? totalScore = null,Object? foundPointScore = null,Object? treasureScore = null,Object? checkInScore = null,Object? updatedAt = freezed,}) {
  return _then(_LeaderboardEntry(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,foundPointScore: null == foundPointScore ? _self.foundPointScore : foundPointScore // ignore: cast_nullable_to_non_nullable
as int,treasureScore: null == treasureScore ? _self.treasureScore : treasureScore // ignore: cast_nullable_to_non_nullable
as int,checkInScore: null == checkInScore ? _self.checkInScore : checkInScore // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
