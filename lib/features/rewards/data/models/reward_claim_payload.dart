import 'dart:convert';

import 'package:crypto/crypto.dart';

class RewardScanRecord {
  final String id;
  final DateTime scannedAt;

  const RewardScanRecord({required this.id, required this.scannedAt});

  Map<String, dynamic> toJson() => {
    'id': id,
    'scannedAt': scannedAt.toIso8601String(),
  };

  static RewardScanRecord? tryFromJson(Object? value) {
    if (value is! Map) return null;
    final id = value['id'];
    final scannedAt = value['scannedAt'];
    if (id is! String || scannedAt is! String) return null;
    final parsedDate = DateTime.tryParse(scannedAt);
    if (parsedDate == null) return null;
    return RewardScanRecord(id: id, scannedAt: parsedDate);
  }
}

class RewardClaimPayload {
  static const schemaVersion = 1;
  static const qrPrefix = 'sggw-reward:';

  final int version;
  final String deviceId;
  final DateTime generatedAt;
  final List<RewardScanRecord> treasureScans;
  final List<RewardScanRecord> eventCheckIns;

  const RewardClaimPayload({
    this.version = schemaVersion,
    required this.deviceId,
    required this.generatedAt,
    required this.treasureScans,
    required this.eventCheckIns,
  });

  bool get hasEventCheckIn => eventCheckIns.isNotEmpty;

  DateTime? get completedAt {
    final dates = [
      ...treasureScans.map((record) => record.scannedAt),
      ...eventCheckIns.map((record) => record.scannedAt),
    ];
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.last;
  }

  String get payloadHash {
    final digest = sha256.convert(utf8.encode(_canonicalJson())).toString();
    return digest.substring(0, 12).toUpperCase();
  }

  String toQrData() {
    final encoded = base64UrlEncode(utf8.encode(jsonEncode(toJson())));
    return '$qrPrefix$encoded';
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'deviceId': deviceId,
    'generatedAt': generatedAt.toIso8601String(),
    'treasureScans': treasureScans.map((record) => record.toJson()).toList(),
    'eventCheckIns': eventCheckIns.map((record) => record.toJson()).toList(),
    'completedAt': completedAt?.toIso8601String(),
    'payloadHash': payloadHash,
  };

  String _canonicalJson() => jsonEncode({
    'version': version,
    'deviceId': deviceId,
    'generatedAt': generatedAt.toIso8601String(),
    'treasureScans': treasureScans.map((record) => record.toJson()).toList(),
    'eventCheckIns': eventCheckIns.map((record) => record.toJson()).toList(),
  });

  static RewardClaimPayload? tryParseQrData(String rawData) {
    final trimmed = rawData.trim();
    if (!trimmed.startsWith(qrPrefix)) return null;
    try {
      final encoded = trimmed.substring(qrPrefix.length);
      final jsonText = utf8.decode(base64Url.decode(encoded));
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) return null;
      return tryFromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static RewardClaimPayload? tryFromJson(Map<String, dynamic> json) {
    final version = json['version'];
    final deviceId = json['deviceId'];
    final generatedAt = json['generatedAt'];
    final treasureScans = json['treasureScans'];
    final eventCheckIns = json['eventCheckIns'];
    if (version is! int ||
        deviceId is! String ||
        generatedAt is! String ||
        treasureScans is! List ||
        eventCheckIns is! List) {
      return null;
    }
    final parsedGeneratedAt = DateTime.tryParse(generatedAt);
    if (parsedGeneratedAt == null) return null;

    final parsedTreasureScans = treasureScans
        .map(RewardScanRecord.tryFromJson)
        .whereType<RewardScanRecord>()
        .toList();
    final parsedEventCheckIns = eventCheckIns
        .map(RewardScanRecord.tryFromJson)
        .whereType<RewardScanRecord>()
        .toList();

    if (parsedTreasureScans.length != treasureScans.length ||
        parsedEventCheckIns.length != eventCheckIns.length) {
      return null;
    }

    return RewardClaimPayload(
      version: version,
      deviceId: deviceId,
      generatedAt: parsedGeneratedAt,
      treasureScans: parsedTreasureScans,
      eventCheckIns: parsedEventCheckIns,
    );
  }
}
