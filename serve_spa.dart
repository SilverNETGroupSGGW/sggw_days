// Dart SPA-aware HTTP server for testing Flutter web builds.
// Usage: dart run serve_spa.dart
// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  const port = 8080;
  final webDir = '${Directory.current.path}/build/web';

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Serving Flutter web build at http://localhost:$port');
  print('Directory: $webDir');

  await for (final request in server) {
    var path = request.uri.path;
    if (path == '/') path = '/index.html';

    var file = File('$webDir$path');
    if (await file.exists()) {
      final ext = path.split('.').last;
      final mime = _mimeType(ext);
      request.response.headers.contentType = ContentType.parse(mime);
      await request.response.addStream(file.openRead());
    } else {
      // SPA fallback: serve index.html for client-side routing
      file = File('$webDir/index.html');
      request.response.headers.contentType = ContentType.html;
      await request.response.addStream(file.openRead());
    }
    await request.response.close();
  }
}

String _mimeType(String ext) => switch (ext) {
  'html' => 'text/html',
  'js' => 'application/javascript',
  'css' => 'text/css',
  'json' => 'application/json',
  'png' => 'image/png',
  'jpg' || 'jpeg' => 'image/jpeg',
  'svg' => 'image/svg+xml',
  'woff' || 'woff2' => 'font/woff2',
  'ttf' => 'font/ttf',
  'wasm' => 'application/wasm',
  _ => 'application/octet-stream',
};
