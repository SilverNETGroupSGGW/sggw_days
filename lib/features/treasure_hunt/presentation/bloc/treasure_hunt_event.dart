import 'package:equatable/equatable.dart';

abstract class TreasureHuntEvent extends Equatable {
  const TreasureHuntEvent();

  @override
  List<Object?> get props => [];
}

class LoadTreasurePoints extends TreasureHuntEvent {
  const LoadTreasurePoints();
}

class MarkPointAsFound extends TreasureHuntEvent {
  final String pointId;

  const MarkPointAsFound(this.pointId);

  @override
  List<Object?> get props => [pointId];
}

class ScanQRCode extends TreasureHuntEvent {
  final String qrCode;

  const ScanQRCode(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

class TrackPoint extends TreasureHuntEvent {
  final String? pointId;

  const TrackPoint(this.pointId);

  @override
  List<Object?> get props => [pointId];
}
