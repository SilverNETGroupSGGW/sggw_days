import 'package:flutter/material.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

IconData iconForPointType(PointType type) {
  return switch (type) {
    PointType.treasurePoint => Icons.emoji_events,
    PointType.pointOfInterest => Icons.place,
  };
}

String labelForPointType(PointType type, AppLocalizations l10n) {
  return switch (type) {
    PointType.treasurePoint => l10n.typeTreasurePoint,
    PointType.pointOfInterest => l10n.typePointOfInterest,
  };
}

Color colorForPointType(PointType type, ColorScheme colorScheme) {
  return switch (type) {
    PointType.treasurePoint => colorScheme.primary,
    PointType.pointOfInterest => colorScheme.secondary,
  };
}