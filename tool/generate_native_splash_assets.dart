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
const _brandingWidth = 800;
const _brandingHeight = 320;

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
  final silverNetLogo = _dataUri(_silverNetLogoPath);
  final svg =
      '''
<svg xmlns="http://www.w3.org/2000/svg" width="$_brandingWidth" height="$_brandingHeight" viewBox="0 0 $_brandingWidth $_brandingHeight">
  <defs>
    <filter id="softShadow" x="-8%" y="-18%" width="116%" height="140%">
      <feDropShadow dx="0" dy="10" stdDeviation="12" flood-color="#001812" flood-opacity="0.30"/>
    </filter>
  </defs>
  <g transform="translate(28 34)" filter="url(#softShadow)">
    <rect width="744" height="252" rx="42" fill="#F6FFF1"/>
    <rect x="422" y="44" width="2" height="164" rx="1" fill="#B6DDA4"/>
    <image href="$silverNetLogo" x="52" y="78" width="96" height="96" preserveAspectRatio="xMidYMid meet"/>
    <text x="174" y="104" font-family="DejaVu Sans, Arial, sans-serif" font-size="27" font-weight="700" fill="#486158">Koło naukowe</text>
    <text x="174" y="160" font-family="DejaVu Sans, Arial, sans-serif" font-size="38" font-weight="800" fill="#202928">Silver.NET</text>
    <text x="462" y="96" font-family="DejaVu Sans, Arial, sans-serif" font-size="54" font-weight="800" fill="#003228">WZIM</text>
    <text x="462" y="142" font-family="DejaVu Sans, Arial, sans-serif" font-size="22" font-weight="700" fill="#40574E">Wydział Zastosowań</text>
    <text x="462" y="176" font-family="DejaVu Sans, Arial, sans-serif" font-size="22" font-weight="700" fill="#40574E">Informatyki i</text>
    <text x="462" y="210" font-family="DejaVu Sans, Arial, sans-serif" font-size="22" font-weight="700" fill="#40574E">Matematyki</text>
  </g>
</svg>
''';

  File(svgPath).writeAsStringSync(svg);
  final result = Process.runSync('rsvg-convert', [
    '-w',
    '$_brandingWidth',
    '-h',
    '$_brandingHeight',
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
