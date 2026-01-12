import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

// Events
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// Treasure Point Events
class LoadTreasurePoints extends AdminEvent {}

class CreateTreasurePoint extends AdminEvent {
  final TreasurePoint point;

  const CreateTreasurePoint(this.point);

  @override
  List<Object?> get props => [point];
}

class UpdateTreasurePoint extends AdminEvent {
  final TreasurePoint point;

  const UpdateTreasurePoint(this.point);

  @override
  List<Object?> get props => [point];
}

class DeleteTreasurePoint extends AdminEvent {
  final String id;

  const DeleteTreasurePoint(this.id);

  @override
  List<Object?> get props => [id];
}

// Wiki Article Events
class LoadWikiArticles extends AdminEvent {}

class CreateWikiArticle extends AdminEvent {
  final WikiArticle article;

  const CreateWikiArticle(this.article);

  @override
  List<Object?> get props => [article];
}

class UpdateWikiArticle extends AdminEvent {
  final WikiArticle article;

  const UpdateWikiArticle(this.article);

  @override
  List<Object?> get props => [article];
}

class DeleteWikiArticle extends AdminEvent {
  final String id;

  const DeleteWikiArticle(this.id);

  @override
  List<Object?> get props => [id];
}

// Timetable Event Events
class LoadTimetableEvents extends AdminEvent {}

class CreateTimetableEvent extends AdminEvent {
  final TimetableEvent event;

  const CreateTimetableEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateTimetableEvent extends AdminEvent {
  final TimetableEvent event;

  const UpdateTimetableEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteTimetableEvent extends AdminEvent {
  final String id;

  const DeleteTimetableEvent(this.id);

  @override
  List<Object?> get props => [id];
}
