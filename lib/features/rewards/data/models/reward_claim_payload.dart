class RewardClaimPayload {
  final String deviceId;
  static const minDeviceIdLength = 16;
  static const maxDeviceIdLength = 80;

  const RewardClaimPayload({required this.deviceId});

  String toQrData() => deviceId;

  static RewardClaimPayload? tryParseQrData(String rawData) {
    final trimmed = rawData.trim();
    if (trimmed.length < minDeviceIdLength ||
        trimmed.length > maxDeviceIdLength) {
      return null;
    }
    return RewardClaimPayload(deviceId: trimmed);
  }
}
