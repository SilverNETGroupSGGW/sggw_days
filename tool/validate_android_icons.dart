import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _sourceSvgPath = 'assets/icon/source/app_icon.svg';
const _masterIconPath = 'assets/icon/app_icon_master.png';
const _androidForegroundPath = 'assets/icon/android_dynamic_foreground.png';
const _androidMonochromePath = 'assets/icon/android_dynamic_monochrome.png';
const _adaptiveIconXmlPath =
    'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml';
const _launcherColorsPath = 'android/app/src/main/res/values/colors.xml';

const _outputSize = 1024;
const _androidSafeRatio = 66 / 108;
const _expectedBackgroundHex = '#c8f0b4';
const _expectedBackgroundColor = _Rgba(0xC8, 0xF0, 0xB4, 0xFF);
const _expectedForegroundColor = _Rgba(0x00, 0x32, 0x28, 0xFF);
const _expectedMonochromeColor = _Rgba(0x00, 0x00, 0x00, 0xFF);

const _launcherIconSizes = <String, int>{
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};

const _adaptiveLayerSizes = <String, int>{
  'mdpi': 108,
  'hdpi': 162,
  'xhdpi': 216,
  'xxhdpi': 324,
  'xxxhdpi': 432,
};

void main() {
  final checks = <String>[];

  _validateSourceSvg(checks);
  _validateGeneratedSourcePngs(checks);
  _validateAndroidXml(checks);
  _validateAndroidRasterResources(checks);

  stdout.writeln('Android icon validation passed:');
  for (final check in checks) {
    stdout.writeln('- $check');
  }
}

void _validateSourceSvg(List<String> checks) {
  final file = _requireFile(_sourceSvgPath);
  final content = file.readAsStringSync();
  if (!content.contains('<svg')) {
    throw StateError('$_sourceSvgPath is not an SVG document.');
  }
  if (!content.contains('inkscape:label="pinpoint"')) {
    throw StateError(
      '$_sourceSvgPath must contain the pinpoint alignment group used by the generator.',
    );
  }
  checks.add('source SVG exists and contains the pinpoint alignment group');
}

void _validateGeneratedSourcePngs(List<String> checks) {
  final master = _readPng(_masterIconPath);
  _expectDimensions(_masterIconPath, master, _outputSize, _outputSize);
  _expectOpaque(_masterIconPath, master);
  _expectCornerColor(_masterIconPath, master, _expectedBackgroundColor);

  final foreground = _readPng(_androidForegroundPath);
  _expectDimensions(
    _androidForegroundPath,
    foreground,
    _outputSize,
    _outputSize,
  );
  _expectTransparentCorners(_androidForegroundPath, foreground);
  _expectOpaquePixelColor(
    _androidForegroundPath,
    foreground,
    _expectedForegroundColor,
  );
  _expectAdaptiveSafeBounds(_androidForegroundPath, foreground);

  final monochrome = _readPng(_androidMonochromePath);
  _expectDimensions(
    _androidMonochromePath,
    monochrome,
    _outputSize,
    _outputSize,
  );
  _expectTransparentCorners(_androidMonochromePath, monochrome);
  _expectOpaquePixelColor(
    _androidMonochromePath,
    monochrome,
    _expectedMonochromeColor,
  );
  _expectAdaptiveSafeBounds(_androidMonochromePath, monochrome);

  checks.add(
    'generated 1024px PNG sources are valid and within adaptive safe bounds',
  );
}

void _validateAndroidXml(List<String> checks) {
  final colorXml = _requireFile(_launcherColorsPath).readAsStringSync();
  if (!RegExp(
    r'<color\s+name="ic_launcher_background">\s*#c8f0b4\s*</color>',
    caseSensitive: false,
  ).hasMatch(colorXml)) {
    throw StateError(
      '$_launcherColorsPath must define ic_launcher_background as $_expectedBackgroundHex.',
    );
  }

  final adaptiveXml = _requireFile(_adaptiveIconXmlPath).readAsStringSync();
  final requiredSnippets = <String>[
    '@color/ic_launcher_background',
    '@drawable/ic_launcher_foreground',
    '@drawable/ic_launcher_monochrome',
    'android:inset="0%"',
  ];

  for (final snippet in requiredSnippets) {
    if (!adaptiveXml.contains(snippet)) {
      throw StateError('$_adaptiveIconXmlPath is missing $snippet.');
    }
  }

  checks.add(
    'Android adaptive icon XML references background, foreground, and monochrome layers',
  );
}

void _validateAndroidRasterResources(List<String> checks) {
  for (final entry in _launcherIconSizes.entries) {
    final path = 'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png';
    final icon = _readPng(path);
    _expectDimensions(path, icon, entry.value, entry.value);
    _expectVisibleRatio(path, icon, minVisibleRatio: 0.2);
  }

  for (final entry in _adaptiveLayerSizes.entries) {
    for (final layerName in ['foreground', 'monochrome']) {
      final path =
          'android/app/src/main/res/drawable-${entry.key}/ic_launcher_$layerName.png';
      final layer = _readPng(path);
      _expectDimensions(path, layer, entry.value, entry.value);
      _expectTransparentCorners(path, layer);
      _expectNonEmptyAlpha(path, layer);
    }
  }

  checks.add(
    'Android mipmap and adaptive drawable resources exist at expected densities',
  );
}

File _requireFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw StateError('Missing file: $path');
  }
  if (file.lengthSync() == 0) {
    throw StateError('Empty file: $path');
  }
  return file;
}

img.Image _readPng(String path) {
  final file = _requireFile(path);
  final image = img.decodePng(file.readAsBytesSync());
  if (image == null) {
    throw StateError('Invalid PNG: $path');
  }
  return image;
}

void _expectDimensions(String path, img.Image image, int width, int height) {
  if (image.width != width || image.height != height) {
    throw StateError(
      '$path must be ${width}x$height, got ${image.width}x${image.height}.',
    );
  }
}

void _expectOpaque(String path, img.Image image) {
  for (final pixel in image) {
    if (_channel(pixel.a) != 0xFF) {
      throw StateError('$path must be fully opaque.');
    }
  }
}

void _expectVisibleRatio(
  String path,
  img.Image image, {
  required double minVisibleRatio,
}) {
  var visiblePixels = 0;
  final totalPixels = image.width * image.height;
  for (final pixel in image) {
    if (_channel(pixel.a) > 0) {
      visiblePixels++;
    }
  }

  final visibleRatio = visiblePixels / totalPixels;
  if (visibleRatio < minVisibleRatio) {
    throw StateError(
      '$path must be at least ${(minVisibleRatio * 100).toStringAsFixed(1)}% visible, got ${(visibleRatio * 100).toStringAsFixed(1)}%.',
    );
  }
}

void _expectCornerColor(String path, img.Image image, _Rgba expectedColor) {
  final corners = [
    image.getPixel(0, 0),
    image.getPixel(image.width - 1, 0),
    image.getPixel(0, image.height - 1),
    image.getPixel(image.width - 1, image.height - 1),
  ];
  for (final corner in corners) {
    if (_channel(corner.a) != 0xFF || !_matchesRgb(corner, expectedColor)) {
      throw StateError(
        '$path corners must use $_expectedBackgroundHex launcher background.',
      );
    }
  }
}

void _expectTransparentCorners(String path, img.Image image) {
  final corners = [
    image.getPixel(0, 0),
    image.getPixel(image.width - 1, 0),
    image.getPixel(0, image.height - 1),
    image.getPixel(image.width - 1, image.height - 1),
  ];
  for (final corner in corners) {
    if (_channel(corner.a) != 0) {
      throw StateError('$path must keep transparent corners.');
    }
  }
}

void _expectOpaquePixelColor(
  String path,
  img.Image image,
  _Rgba expectedColor,
) {
  var visiblePixels = 0;
  var solidPixels = 0;
  for (final pixel in image) {
    if (_channel(pixel.a) == 0) {
      continue;
    }
    visiblePixels++;
    if (_channel(pixel.a) < 0xFF) {
      continue;
    }
    solidPixels++;
    if (!_matchesRgb(pixel, expectedColor)) {
      throw StateError(
        '$path has a fully opaque pixel with an unexpected color.',
      );
    }
  }

  if (visiblePixels == 0) {
    throw StateError('$path contains no visible pixels.');
  }
  if (solidPixels == 0) {
    throw StateError('$path contains no fully opaque pixels to validate.');
  }
}

void _expectAdaptiveSafeBounds(String path, img.Image image) {
  final bounds = _findOpaqueBounds(image);
  final maxDimension = math.max(bounds.width, bounds.height);
  final allowedMaxDimension = (_outputSize * _androidSafeRatio).ceil();
  if (maxDimension > allowedMaxDimension) {
    throw StateError(
      '$path visible content is $maxDimension px, expected <= $allowedMaxDimension px.',
    );
  }
}

void _expectNonEmptyAlpha(String path, img.Image image) {
  _findOpaqueBounds(image);
}

_Bounds _findOpaqueBounds(img.Image image) {
  var left = image.width;
  var top = image.height;
  var right = -1;
  var bottom = -1;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (_channel(pixel.a) == 0) {
        continue;
      }
      left = math.min(left, x);
      top = math.min(top, y);
      right = math.max(right, x);
      bottom = math.max(bottom, y);
    }
  }

  if (right < left || bottom < top) {
    throw StateError('The image contains no visible content.');
  }

  return _Bounds(left, top, right - left + 1, bottom - top + 1);
}

bool _matchesRgb(img.Pixel pixel, _Rgba expectedColor) {
  return _channel(pixel.r) == expectedColor.r &&
      _channel(pixel.g) == expectedColor.g &&
      _channel(pixel.b) == expectedColor.b;
}

int _channel(num value) => value.round().clamp(0, 255).toInt();

final class _Rgba {
  const _Rgba(this.r, this.g, this.b, this.a);

  final int r;
  final int g;
  final int b;
  final int a;
}

final class _Bounds {
  const _Bounds(this.left, this.top, this.width, this.height);

  final int left;
  final int top;
  final int width;
  final int height;
}
