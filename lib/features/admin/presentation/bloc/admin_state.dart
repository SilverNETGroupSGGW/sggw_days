import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

enum AdminStatus { initial, loading, success, error }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<TreasurePoint> treasurePoints;
  final List<WikiArticle> wikiArticles;
  final List<TimetableEvent> timetableEvents;
  final String? errorMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.treasurePoints = const [],
    this.wikiArticles = const [],
    this.timetableEvents = const [],
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStatus? status,
    List<TreasurePoint>? treasurePoints,
    List<WikiArticle>? wikiArticles,
    List<TimetableEvent>? timetableEvents,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      treasurePoints: treasurePoints ?? this.treasurePoints,
      wikiArticles: wikiArticles ?? this.wikiArticles,
      timetableEvents: timetableEvents ?? this.timetableEvents,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    treasurePoints,
    wikiArticles,
    timetableEvents,
    errorMessage,
  ];
}
