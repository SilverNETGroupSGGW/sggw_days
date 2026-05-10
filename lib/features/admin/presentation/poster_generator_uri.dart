import 'package:flutter/foundation.dart' show kIsWeb;

const _productionPosterHost = 'sggw-days.web.app';

Uri posterGeneratorUri({
  String? checkpointUrl,
  String? pointName,
  String? eventCode,
  String? eventTitle,
  bool openCheckpointPoster = false,
  bool openEventPoster = false,
}) {
  final queryParameters = <String, String>{
    if (checkpointUrl != null && checkpointUrl.trim().isNotEmpty)
      'checkpoint': checkpointUrl.trim(),
    if (pointName != null && pointName.trim().isNotEmpty)
      'point': pointName.trim(),
    if (eventCode != null && eventCode.trim().isNotEmpty)
      'eventCode': eventCode.trim(),
    if (eventTitle != null && eventTitle.trim().isNotEmpty)
      'eventTitle': eventTitle.trim(),
  };

  return _posterGeneratorBaseUri().replace(
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
    fragment: openEventPoster
        ? 'wrapper-4'
        : openCheckpointPoster
        ? 'wrapper-3'
        : null,
  );
}

Uri _posterGeneratorBaseUri() {
  if (kIsWeb) {
    final base = Uri.base;
    final host = base.host;
    final isLocalhost =
        host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0';
    if (!isLocalhost && host.isNotEmpty) {
      return base.resolve('/posters/');
    }
  }

  return Uri.https(_productionPosterHost, '/posters/');
}
