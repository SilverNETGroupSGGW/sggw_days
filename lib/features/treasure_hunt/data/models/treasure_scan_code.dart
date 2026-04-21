final RegExp _treasurePointIdPattern = RegExp(r'^[A-Za-z0-9_-]{1,128}$');

bool isValidTreasurePointId(String pointId) {
  return _treasurePointIdPattern.hasMatch(pointId);
}

String? tryExtractTreasurePointId(String rawValue) {
  final trimmedValue = rawValue.trim();
  if (trimmedValue.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmedValue);
  if (uri == null) {
    return null;
  }

  if (uri.hasScheme && uri.scheme != 'https') {
    return null;
  }

  final pathSegments = uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (pathSegments.length != 2 || pathSegments.first != 'scan') {
    return null;
  }

  final pointId = pathSegments[1];
  if (!isValidTreasurePointId(pointId)) {
    return null;
  }

  return pointId;
}
