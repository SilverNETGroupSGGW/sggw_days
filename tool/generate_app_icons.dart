import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _sourceSvgPath = 'assets/icon/source/app_icon.svg';
const _backgroundColor = 0xFFC8F0B4;
const _foregroundColor = 0xFF003228;
const _masterOutputPath = 'assets/icon/app_icon_master.png';
const _androidForegroundOutputPath =
    'assets/icon/android_dynamic_foreground.png';
const _androidMonochromeOutputPath =
    'assets/icon/android_dynamic_monochrome.png';
const _analysisOutputPath = 'doc/icon_generation.md';

const _analysisRasterSize = 4096;
const _outputSize = 1024;
const _androidForegroundLayerRatio = 56 / 108;
const _androidMonochromeLayerRatio = 70 / 108;
const _androidAdaptiveInsetPercent = 0;
const _androidForegroundEffectiveMinRatio = 55 / 108;
const _androidForegroundEffectiveMaxRatio = _androidForegroundLayerRatio;
const _androidMonochromeEffectiveMinRatio = 69 / 108;
const _androidMonochromeEffectiveMaxRatio = _androidMonochromeLayerRatio;
const _masterRatio = 0.56;
const _horizontalAlignmentGroupLabel = 'pinpoint';

void main() {
  final rendered = _renderSvg(_sourceSvgPath, _analysisRasterSize);
  final horizontalAlignmentRendered = _renderSvg(
    _sourceSvgPath,
    _analysisRasterSize,
    includeGroupLabel: _horizontalAlignmentGroupLabel,
  );
  final glyphBounds = _findOpaqueBounds(rendered);
  final horizontalAlignmentBounds = _findOpaqueBounds(
    horizontalAlignmentRendered,
  );
  final horizontalAnchorX = _relativeCenterX(
    contentBounds: glyphBounds,
    referenceBounds: horizontalAlignmentBounds,
  );
  final glyphCrop = img.copyCrop(
    rendered,
    x: glyphBounds.left,
    y: glyphBounds.top,
    width: glyphBounds.width,
    height: glyphBounds.height,
  );

  final masterIcon = _composeMasterIcon(
    glyphCrop,
    horizontalAnchorX: horizontalAnchorX,
  );
  final androidForeground = _composeTransparentLayer(
    glyphCrop,
    maxDimensionRatio: _androidForegroundLayerRatio,
    color: _color(_foregroundColor),
    horizontalAnchorX: horizontalAnchorX,
  );
  final androidMonochrome = _composeMonochromeLayer(
    glyphCrop,
    maxDimensionRatio: _androidMonochromeLayerRatio,
    color: _color(0xFF000000),
    horizontalAnchorX: horizontalAnchorX,
  );

  _writePng(_masterOutputPath, masterIcon);
  _writePng(_androidForegroundOutputPath, androidForeground);
  _writePng(_androidMonochromeOutputPath, androidMonochrome);

  _writeAnalysis(
    sourceBounds: glyphBounds,
    horizontalAlignmentBounds: horizontalAlignmentBounds,
    horizontalAnchorX: horizontalAnchorX,
    renderedSize: rendered.width,
    masterIcon: masterIcon,
    androidForeground: androidForeground,
    androidMonochrome: androidMonochrome,
  );

  stdout.writeln('Generated app icon assets from $_sourceSvgPath');
}

img.Image _renderSvg(String sourcePath, int size, {String? includeGroupLabel}) {
  final svgContent = File(sourcePath).readAsStringSync();
  final filteredContent = includeGroupLabel == null
      ? svgContent
      : _keepOnlySvgGroup(svgContent, includeGroupLabel);

  return _renderSvgContent(filteredContent, size);
}

img.Image _renderSvgContent(String svgContent, int size) {
  final tempDir = Directory.systemTemp.createTempSync('sggw-days-icon-');
  final svgPath = '${tempDir.path}/source.svg';
  final outputPath = '${tempDir.path}/render.png';
  File(svgPath).writeAsStringSync(svgContent);
  final result = Process.runSync('rsvg-convert', [
    '-w',
    '$size',
    '-h',
    '$size',
    svgPath,
    '-o',
    outputPath,
  ]);

  if (result.exitCode != 0) {
    throw StateError('rsvg-convert failed: ${result.stderr}');
  }

  final image = img.decodePng(File(outputPath).readAsBytesSync());
  tempDir.deleteSync(recursive: true);

  if (image == null) {
    throw StateError('Failed to decode rasterized SVG output.');
  }

  return image;
}

String _keepOnlySvgGroup(String svgContent, String includeGroupLabel) {
  final groupPattern = RegExp(
    r'<g\b[^>]*inkscape:label="([^"]+)"[^>]*>[\s\S]*?<\/g>',
    multiLine: true,
  );
  var matchedGroup = false;
  final filteredContent = svgContent.replaceAllMapped(groupPattern, (match) {
    final label = match.group(1);
    if (label == includeGroupLabel) {
      matchedGroup = true;
      return match.group(0)!;
    }
    return '';
  });

  if (!matchedGroup) {
    throw StateError('Could not find SVG group "$includeGroupLabel".');
  }

  return filteredContent;
}

_Bounds _findOpaqueBounds(img.Image image) {
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
    throw StateError('The SVG rendered empty content.');
  }

  return _Bounds(left, top, right - left + 1, bottom - top + 1);
}

_Bounds _findNonBackgroundBounds(img.Image image, img.Color backgroundColor) {
  var left = image.width;
  var top = image.height;
  var right = -1;
  var bottom = -1;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (_sameRgb(pixel, backgroundColor)) {
        continue;
      }
      left = math.min(left, x);
      top = math.min(top, y);
      right = math.max(right, x);
      bottom = math.max(bottom, y);
    }
  }

  if (right < left || bottom < top) {
    throw StateError('The icon contains no foreground content.');
  }

  return _Bounds(left, top, right - left + 1, bottom - top + 1);
}

bool _sameRgb(img.Pixel pixel, img.Color color) {
  return _channel(pixel.r) == _channel(color.r) &&
      _channel(pixel.g) == _channel(color.g) &&
      _channel(pixel.b) == _channel(color.b);
}

img.Image _composeMasterIcon(
  img.Image glyphCrop, {
  required double horizontalAnchorX,
}) {
  final canvas = img.Image(
    width: _outputSize,
    height: _outputSize,
    numChannels: 4,
  );
  _fillSolid(canvas, _color(_backgroundColor));

  final glyph = _resizeToFit(glyphCrop, _outputSize * _masterRatio);
  final x = ((_outputSize / 2) - (glyph.width * horizontalAnchorX)).round();
  final y = ((_outputSize - glyph.height) / 2).round();
  img.compositeImage(canvas, glyph, dstX: x, dstY: y);
  return canvas;
}

img.Image _composeTransparentLayer(
  img.Image glyphCrop, {
  required double maxDimensionRatio,
  required img.Color color,
  required double horizontalAnchorX,
}) {
  final canvas = img.Image(
    width: _outputSize,
    height: _outputSize,
    numChannels: 4,
  );
  final glyph = _resizeToFit(glyphCrop, _outputSize * maxDimensionRatio);
  final monochromeGlyph = _recolorOpaquePixels(glyph, color);
  final x = ((_outputSize / 2) - (monochromeGlyph.width * horizontalAnchorX))
      .round();
  final y = ((_outputSize - monochromeGlyph.height) / 2).round();
  img.compositeImage(canvas, monochromeGlyph, dstX: x, dstY: y);
  return canvas;
}

img.Image _composeMonochromeLayer(
  img.Image glyphCrop, {
  required double maxDimensionRatio,
  required img.Color color,
  required double horizontalAnchorX,
}) {
  return _composeTransparentLayer(
    glyphCrop,
    maxDimensionRatio: maxDimensionRatio,
    color: color,
    horizontalAnchorX: horizontalAnchorX,
  );
}

double _relativeCenterX({
  required _Bounds contentBounds,
  required _Bounds referenceBounds,
}) {
  final referenceCenterX = referenceBounds.left + (referenceBounds.width / 2);
  final relativeCenterX =
      (referenceCenterX - contentBounds.left) / contentBounds.width;
  return relativeCenterX.clamp(0.0, 1.0);
}

img.Image _resizeToFit(img.Image source, double maxDimension) {
  final scale = maxDimension / math.max(source.width, source.height);
  final width = math.max(1, (source.width * scale).round());
  final height = math.max(1, (source.height * scale).round());
  return img.copyResize(
    source,
    width: width,
    height: height,
    interpolation: img.Interpolation.linear,
  );
}

img.Image _recolorOpaquePixels(img.Image source, img.Color color) {
  final recolored = img.Image.from(source);
  for (var y = 0; y < recolored.height; y++) {
    for (var x = 0; x < recolored.width; x++) {
      final pixel = recolored.getPixel(x, y);
      if (pixel.a == 0) {
        continue;
      }
      recolored.setPixel(
        x,
        y,
        img.ColorRgba8(
          _channel(color.r),
          _channel(color.g),
          _channel(color.b),
          _channel(pixel.a),
        ),
      );
    }
  }
  return recolored;
}

void _fillSolid(img.Image image, img.Color color) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixel(x, y, color);
    }
  }
}

void _writePng(String path, img.Image image) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
}

void _writeAnalysis({
  required _Bounds sourceBounds,
  required _Bounds horizontalAlignmentBounds,
  required double horizontalAnchorX,
  required int renderedSize,
  required img.Image masterIcon,
  required img.Image androidForeground,
  required img.Image androidMonochrome,
}) {
  final sourceWidthRatio = sourceBounds.width / renderedSize;
  final sourceHeightRatio = sourceBounds.height / renderedSize;
  final masterBounds = _findNonBackgroundBounds(
    masterIcon,
    _color(_backgroundColor),
  );
  final androidBounds = _findOpaqueBounds(androidForeground);
  final androidSourceMaxDimension = math.max(
    androidBounds.width,
    androidBounds.height,
  );
  final effectiveAndroidMaxDimension =
      androidSourceMaxDimension * (1 - (_androidAdaptiveInsetPercent / 50));
  final monochromeBounds = _findOpaqueBounds(androidMonochrome);
  final monochromeSourceMaxDimension = math.max(
    monochromeBounds.width,
    monochromeBounds.height,
  );
  final effectiveMonochromeMaxDimension =
      monochromeSourceMaxDimension * (1 - (_androidAdaptiveInsetPercent / 50));
  final analysis = StringBuffer()
    ..writeln('# App Icon Generation')
    ..writeln()
    ..writeln('Source of truth: `$_sourceSvgPath`')
    ..writeln()
    ..writeln('## Source analysis')
    ..writeln()
    ..writeln('- Rendered analysis size: ${renderedSize}x$renderedSize')
    ..writeln(
      '- Opaque bounds: left ${sourceBounds.left}, top ${sourceBounds.top}, width ${sourceBounds.width}, height ${sourceBounds.height}',
    )
    ..writeln(
      '- Horizontal alignment group: `$_horizontalAlignmentGroupLabel` → left ${horizontalAlignmentBounds.left}, top ${horizontalAlignmentBounds.top}, width ${horizontalAlignmentBounds.width}, height ${horizontalAlignmentBounds.height}',
    )
    ..writeln(
      '- Horizontal anchor within full artwork: ${(horizontalAnchorX * 100).toStringAsFixed(1)}% of the artwork width',
    )
    ..writeln(
      '- Occupancy ratio: width ${(sourceWidthRatio * 100).toStringAsFixed(1)}%, height ${(sourceHeightRatio * 100).toStringAsFixed(1)}%',
    )
    ..writeln(
      '- Background used for flattened icons: `#${_backgroundColor.toRadixString(16).substring(2).toUpperCase()}`',
    )
    ..writeln()
    ..writeln('## Generated outputs')
    ..writeln()
    ..writeln('- Master icon: `$_masterOutputPath`')
    ..writeln('- Android adaptive foreground: `$_androidForegroundOutputPath`')
    ..writeln('- Android adaptive monochrome: `$_androidMonochromeOutputPath`')
    ..writeln('- Browser favicon SVG: `web/favicon.svg`')
    ..writeln('- Safari pinned-tab mask: `web/safari-pinned-tab.svg`')
    ..writeln()
    ..writeln('## Validation')
    ..writeln()
    ..writeln(
      '- Native flat icon visible max dimension: ${math.max(masterBounds.width, masterBounds.height)} px (${(math.max(masterBounds.width, masterBounds.height) / _outputSize * 100).toStringAsFixed(1)}% of canvas)',
    )
    ..writeln(
      '- Android foreground source max dimension: $androidSourceMaxDimension px (${(androidSourceMaxDimension / _outputSize * 100).toStringAsFixed(1)}% of canvas, target <= ${(_androidForegroundLayerRatio * 100).toStringAsFixed(1)}%)',
    )
    ..writeln(
      '- Android foreground after $_androidAdaptiveInsetPercent% launcher inset: ${effectiveAndroidMaxDimension.round()} px (${(effectiveAndroidMaxDimension / _outputSize * 100).toStringAsFixed(1)}% of canvas, target ${(_androidForegroundEffectiveMinRatio * 100).toStringAsFixed(1)}%-${(_androidForegroundEffectiveMaxRatio * 100).toStringAsFixed(1)}%)',
    )
    ..writeln(
      '- Android themed monochrome source max dimension: $monochromeSourceMaxDimension px (${(monochromeSourceMaxDimension / _outputSize * 100).toStringAsFixed(1)}% of canvas, target <= ${(_androidMonochromeLayerRatio * 100).toStringAsFixed(1)}%)',
    )
    ..writeln(
      '- Android themed monochrome after $_androidAdaptiveInsetPercent% launcher inset: ${effectiveMonochromeMaxDimension.round()} px (${(effectiveMonochromeMaxDimension / _outputSize * 100).toStringAsFixed(1)}% of canvas, target ${(_androidMonochromeEffectiveMinRatio * 100).toStringAsFixed(1)}%-${(_androidMonochromeEffectiveMaxRatio * 100).toStringAsFixed(1)}%)',
    )
    ..writeln('- Master icon canvas: ${masterIcon.width}x${masterIcon.height}')
    ..writeln()
    ..writeln('## Regenerate')
    ..writeln()
    ..writeln('```bash')
    ..writeln('dart run tool/generate_app_icons.dart')
    ..writeln(
      'dart run flutter_launcher_icons -f flutter_launcher_icons.native.yaml',
    )
    ..writeln('dart run tool/validate_android_icons.dart')
    ..writeln('```')
    ..writeln()
    ..writeln(
      'Preview-only assets are intentionally excluded. The generator emits only production icon sources used by the native app launcher pipeline.',
    );

  File(_analysisOutputPath)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(analysis.toString());
}

img.Color _color(int rgba) => img.ColorRgba8(
  (rgba >> 16) & 0xFF,
  (rgba >> 8) & 0xFF,
  rgba & 0xFF,
  (rgba >> 24) & 0xFF,
);

int _channel(num value) {
  final rounded = value.round();
  if (rounded < 0) {
    return 0;
  }
  if (rounded > 255) {
    return 255;
  }
  return rounded;
}

final class _Bounds {
  const _Bounds(this.left, this.top, this.width, this.height);

  final int left;
  final int top;
  final int width;
  final int height;
}
