import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _markOutputPath = 'assets/icon/native_splash_mark.png';
const _brandingOutputPath = 'assets/icon/native_splash_branding.png';
const _sggwLogoPath = 'assets/icon/source/sggw_logo_white.png';
const _silverNetLogoPath = 'assets/icon/source/silvernet_logo.png';
const _markCanvasSize = 1024;
const _markMaxDimension = 690;

void main() {
  _generateCenterMark();
  _generateBranding();

  stdout.writeln('Generated native splash assets:');
  stdout.writeln('- $_markOutputPath');
  stdout.writeln('- $_brandingOutputPath');
}

void _generateCenterMark() {
  final logo = _readPng(_sggwLogoPath);
  final bounds = _visibleBounds(logo);
  final croppedLogo = img.copyCrop(
    logo,
    x: bounds.left,
    y: bounds.top,
    width: bounds.width,
    height: bounds.height,
  );
  final resizedLogo = _resizeToFit(croppedLogo, _markMaxDimension);
  final canvas = img.Image(
    width: _markCanvasSize,
    height: _markCanvasSize,
    numChannels: 4,
  );
  _fill(canvas, img.ColorRgba8(0, 0, 0, 0));

  img.compositeImage(
    canvas,
    resizedLogo,
    dstX: ((_markCanvasSize - resizedLogo.width) / 2).round(),
    dstY: ((_markCanvasSize - resizedLogo.height) / 2).round(),
  );

  _writePng(_markOutputPath, canvas);
}

void _generateBranding() {
  final tempDir = Directory.systemTemp.createTempSync('sggw-days-splash-');
  final svgPath = '${tempDir.path}/branding.svg';
  final outputPath = '${tempDir.path}/branding.png';
  final sggwLogo = _dataUri(_sggwLogoPath);
  final silverNetLogo = _dataUri(_silverNetLogoPath);
  final svg =
      '''
<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="720" viewBox="0 0 1600 720">
  <defs>
    <filter id="softShadow" x="-10%" y="-30%" width="120%" height="170%">
      <feDropShadow dx="0" dy="16" stdDeviation="16" flood-color="#001812" flood-opacity="0.28"/>
    </filter>
  </defs>
  <g fill="#F5FFF0" font-family="DejaVu Sans, Arial, sans-serif">
    <image href="$sggwLogo" x="88" y="72" width="238" height="238" preserveAspectRatio="xMidYMid meet"/>
    <rect x="376" y="72" width="2" height="292" rx="1" fill="#C8F0B4" opacity="0.58"/>
    <text x="416" y="116" font-size="32" font-weight="700" letter-spacing="4">SGGW DAYS</text>
    <text x="416" y="186" font-size="56" font-weight="800">Warsaw University</text>
    <text x="416" y="254" font-size="56" font-weight="800">of Life Sciences</text>
    <text x="416" y="312" font-size="26" font-weight="700" fill="#C8F0B4" letter-spacing="2">CREATED IN</text>
    <text x="416" y="354" font-size="34" font-weight="700" fill="#DFF9D4">Wydział Zastosowań Informatyki i Informatyki</text>
  </g>
  <g transform="translate(96 414)" filter="url(#softShadow)">
    <rect width="1408" height="236" rx="38" fill="#F8FFF4"/>
    <image href="$silverNetLogo" x="38" y="32" width="172" height="172" preserveAspectRatio="xMidYMid meet"/>
    <text x="250" y="84" font-family="DejaVu Sans, Arial, sans-serif" font-size="42" font-weight="700" fill="#456056">Created by</text>
    <text x="250" y="158" font-family="DejaVu Sans, Arial, sans-serif" font-size="74" font-weight="800" fill="#202928">Silver.NET</text>
    <text x="750" y="128" font-family="DejaVu Sans, Arial, sans-serif" font-size="38" font-weight="700" fill="#456056">Student creators</text>
    <text x="750" y="178" font-family="DejaVu Sans, Arial, sans-serif" font-size="38" font-weight="700" fill="#456056">of the app</text>
  </g>
</svg>
''';

  File(svgPath).writeAsStringSync(svg);
  final result = Process.runSync('rsvg-convert', [
    '-w',
    '1600',
    '-h',
    '720',
    svgPath,
    '-o',
    outputPath,
  ]);

  if (result.exitCode != 0) {
    tempDir.deleteSync(recursive: true);
    throw StateError('rsvg-convert failed: ${result.stderr}');
  }

  File(_brandingOutputPath)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(File(outputPath).readAsBytesSync());
  tempDir.deleteSync(recursive: true);
}

img.Image _readPng(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw StateError('Missing splash source asset: $path');
  }
  final image = img.decodePng(file.readAsBytesSync());
  if (image == null) {
    throw StateError('Invalid PNG source asset: $path');
  }
  return image;
}

_Bounds _visibleBounds(img.Image image) {
  var left = image.width;
  var top = image.height;
  var right = -1;
  var bottom = -1;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (pixel.a == 0) {
        continue;
      }
      left = math.min(left, x);
      top = math.min(top, y);
      right = math.max(right, x);
      bottom = math.max(bottom, y);
    }
  }

  if (right < left || bottom < top) {
    throw StateError('Splash source image contains no visible content.');
  }

  return _Bounds(left, top, right - left + 1, bottom - top + 1);
}

img.Image _resizeToFit(img.Image source, int maxDimension) {
  final scale = maxDimension / math.max(source.width, source.height);
  return img.copyResize(
    source,
    width: math.max(1, (source.width * scale).round()),
    height: math.max(1, (source.height * scale).round()),
    interpolation: img.Interpolation.linear,
  );
}

void _fill(img.Image image, img.Color color) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixel(x, y, color);
    }
  }
}

void _writePng(String path, img.Image image) {
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(image));
}

String _dataUri(String path) {
  final bytes = File(path).readAsBytesSync();
  return 'data:image/png;base64,${base64Encode(bytes)}';
}

final class _Bounds {
  const _Bounds(this.left, this.top, this.width, this.height);

  final int left;
  final int top;
  final int width;
  final int height;
}
