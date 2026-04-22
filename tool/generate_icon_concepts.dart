// Experimental icon concept generator for SGGW Days.
//
// Single concept: SD monogram with a 5-dot vertical separator between the
// letters (the "Days" dot-trail motif doubling as a visual divider).
// Rendered in three Material 3 styled colour variants so we can compare.

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _outputDir = 'build/icon_concepts';

// M3 tonal palette seeded around SGGW primary green (#6EC850).
const _primary          = 0xFF356A1F; // tone 40
const _primaryContainer = 0xFFB5F098; // tone 90
const _onPrimaryCont    = 0xFF052100; // tone 10
const _surfaceHigh      = 0xFFE9ECE2;
const _brandGreen       = 0xFF6EC850;
const _brandDark        = 0xFF003228;

final _previewPalettes = <_Palette>[
  _Palette('SGGW', _rgb(_primaryContainer), _rgb(_onPrimaryCont)),
  _Palette('Mono', _rgb(_surfaceHigh),      _rgb(0xFF1C1C1A)),
  _Palette('Sky',  _rgb(0xFFD8E2FF),        _rgb(0xFF1D4E89)),
  _Palette('Sand', _rgb(0xFFF0E3BF),        _rgb(0xFF734C00)),
  _Palette('Rose', _rgb(0xFFF3D9E6),        _rgb(0xFF83325C)),
];

img.Color _rgb(int hex) =>
    img.ColorRgb8((hex >> 16) & 0xFF, (hex >> 8) & 0xFF, hex & 0xFF);

enum _Mode { master, foreground, monochrome }

/// Style variants for the SD monogram.
enum _Style { tonalCard, boldDark, brightPop }

class _Variant {
  _Variant({required this.name, required this.label, required this.tagline, required this.style});
  final String name;
  final String label;
  final String tagline;
  final _Style style;
}

class _Palette {
  _Palette(this.name, this.background, this.foreground);
  final String name;
  final img.Color background;
  final img.Color foreground;
}

void main() {
  Directory(_outputDir).createSync(recursive: true);

  final variants = <_Variant>[
    _Variant(
      name: 'sd-tonal',
      label: 'SD Tonal',
      tagline: 'Layered M3 card · primary on primary-container',
      style: _Style.tonalCard,
    ),
    _Variant(
      name: 'sd-bold',
      label: 'SD Bold',
      tagline: 'Dark squircle · light glyph · strong contrast',
      style: _Style.boldDark,
    ),
    _Variant(
      name: 'sd-pop',
      label: 'SD Pop',
      tagline: 'Brand green squircle · dark glyph',
      style: _Style.brightPop,
    ),
  ];

  const masterSize = 1024;

  for (final v in variants) {
    final master = img.Image(width: masterSize, height: masterSize);
    _renderMonogram(master, _Mode.master, masterSize, v.style);
    File('$_outputDir/${v.name}-master.png')
        .writeAsBytesSync(img.encodePng(master));

    final fg =
        img.Image(width: masterSize, height: masterSize, numChannels: 4);
    _renderMonogram(fg, _Mode.foreground, masterSize, v.style);
    File('$_outputDir/${v.name}-foreground.png')
        .writeAsBytesSync(img.encodePng(fg));

    final mono =
        img.Image(width: masterSize, height: masterSize, numChannels: 4);
    _renderMonogram(mono, _Mode.monochrome, masterSize, v.style);
    File('$_outputDir/${v.name}-monochrome.png')
        .writeAsBytesSync(img.encodePng(mono));
  }

  _renderOverviewSheet(variants, masterSize);
  stdout.writeln('Wrote concepts to $_outputDir');
}

// ---------------------------------------------------------------------------
// Core renderer: SD monogram with 5-dot vertical separator.
// ---------------------------------------------------------------------------
void _renderMonogram(img.Image canvas, _Mode mode, int size, _Style style) {
  // --- Background(s) (master only; foreground & mono stay transparent) ---
  if (mode == _Mode.master) {
    switch (style) {
      case _Style.tonalCard:
        _squircle(canvas, 0, 0, size - 1, size - 1,
            r: (size * 0.23).round(), color: _rgb(_primary));
        final inset = (size * 0.08).round();
        _squircle(canvas, inset, inset, size - 1 - inset, size - 1 - inset,
            r: (size * 0.17).round(), color: _rgb(_primaryContainer));
        break;
      case _Style.boldDark:
        _squircle(canvas, 0, 0, size - 1, size - 1,
            r: (size * 0.23).round(), color: _rgb(_brandDark));
        break;
      case _Style.brightPop:
        _squircle(canvas, 0, 0, size - 1, size - 1,
            r: (size * 0.23).round(), color: _rgb(_brandGreen));
        break;
    }
  }

  // --- Glyph colour by style and mode ---
  final glyph = mode == _Mode.monochrome
      ? _rgb(0xFF000000)
      : switch (style) {
          _Style.tonalCard => _rgb(_onPrimaryCont),
          _Style.boldDark => _rgb(_primaryContainer),
          _Style.brightPop => _rgb(_brandDark),
        };

  // Transparent "hole" colour for counters; on master falls back to the
  // visible background colour at that z-position.
  final hole = mode == _Mode.monochrome
      ? img.ColorRgba8(0, 0, 0, 0)
      : (mode == _Mode.foreground
          ? img.ColorRgba8(0, 0, 0, 0)
          : switch (style) {
              _Style.tonalCard => _rgb(_primaryContainer),
              _Style.boldDark => _rgb(_brandDark),
              _Style.brightPop => _rgb(_brandGreen),
            });

  // --- Geometry shared across variants ---
  final s = size.toDouble();

  // S: two stacked 3/4 rings.
  final sCenterX = s * 0.215;
  final sHalfR = s * 0.135; // outer radius
  final sStroke = s * 0.060; // stroke thickness
  final sInnerR = sHalfR - sStroke;
  final sTopCy = s * 0.365;
  final sBottomCy = s * 0.635;

  // Top lobe of S: remove bottom-right quadrant → keep θ ∈ [π/2, 2π].
  _fillRingArc(canvas,
      cx: sCenterX, cy: sTopCy,
      outerR: sHalfR, innerR: sInnerR,
      startAngle: math.pi / 2, endAngle: 2 * math.pi,
      color: glyph);
  // Bottom lobe: remove upper-left quadrant → keep θ ∈ [3π/2, 3π].
  _fillRingArc(canvas,
      cx: sCenterX, cy: sBottomCy,
      outerR: sHalfR, innerR: sInnerR,
      startAngle: 3 * math.pi / 2, endAngle: 3 * math.pi,
      color: glyph);
  // Small cap dots on the two tips of S, for crispness.
  _circleF(canvas, sCenterX + sHalfR - sStroke / 2, sTopCy, sStroke / 2, glyph);
  _circleF(canvas, sCenterX - sHalfR + sStroke / 2, sBottomCy, sStroke / 2, glyph);

  // D: rounded-right rectangle with punched counter.
  final dW = s * 0.26;
  final dH = s * 0.52;
  final dCx = s * 0.77;
  final dx1 = dCx - dW / 2;
  final dx2 = dCx + dW / 2;
  final dy1 = s * 0.50 - dH / 2;
  final dy2 = s * 0.50 + dH / 2;
  _fillDShape(canvas,
      x1: dx1, y1: dy1, x2: dx2, y2: dy2,
      stemW: s * 0.068,
      glyph: glyph, hole: hole);

  // 5-dot vertical separator between the letters.
  final dotX = s * 0.495;
  final dotTop = s * 0.27;
  final dotBottom = s * 0.73;
  final dotR = s * 0.024;
  const n = 5;
  for (var i = 0; i < n; i++) {
    final t = i / (n - 1);
    final y = dotTop + t * (dotBottom - dotTop);
    _circleF(canvas, dotX, y, dotR, glyph);
  }
}

// ---------------------------------------------------------------------------
// Shape primitives
// ---------------------------------------------------------------------------

void _squircle(img.Image canvas, int x1, int y1, int x2, int y2,
    {required int r, required img.Color color}) {
  img.fillRect(canvas, x1: x1, y1: y1, x2: x2, y2: y2,
      color: color, radius: r);
}

void _circleF(img.Image canvas, double cx, double cy, double r, img.Color c) {
  img.fillCircle(canvas,
      x: cx.round(), y: cy.round(), radius: r.round(),
      color: c, antialias: true);
}

/// Filled annular arc polygon from [startAngle] to [endAngle] (radians,
/// image coords: +x right, +y down). Sweep direction follows the sign of
/// (endAngle - startAngle).
void _fillRingArc(img.Image canvas,
    {required double cx,
    required double cy,
    required double outerR,
    required double innerR,
    required double startAngle,
    required double endAngle,
    required img.Color color}) {
  const steps = 96;
  final pts = <img.Point>[];
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final a = startAngle + (endAngle - startAngle) * t;
    pts.add(img.Point(cx + outerR * math.cos(a), cy + outerR * math.sin(a)));
  }
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final a = endAngle - (endAngle - startAngle) * t;
    pts.add(img.Point(cx + innerR * math.cos(a), cy + innerR * math.sin(a)));
  }
  img.fillPolygon(canvas, vertices: pts, color: color);
}

/// Fills a capital D: rounded-right, flat-left, with a punched counter.
void _fillDShape(img.Image canvas,
    {required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double stemW,
    required img.Color glyph,
    required img.Color hole}) {
  final h = y2 - y1;
  final cornerR = (h / 2).round();

  // Outer rounded rectangle.
  _squircle(canvas, x1.round(), y1.round(), x2.round(), y2.round(),
      r: cornerR, color: glyph);
  // Overdraw the left portion as a square rectangle in the same colour to
  // flatten the two left corners — makes the shape read as D, not pill.
  _squircle(canvas,
      x1.round(), y1.round(),
      (x1 + cornerR).round(), y2.round(),
      r: 0, color: glyph);

  // Counter.
  final cx1 = x1 + stemW;
  final cy1 = y1 + h * 0.16;
  final cx2 = x2 - h * 0.16;
  final cy2 = y2 - h * 0.16;
  final ch = cy2 - cy1;
  _squircle(canvas,
      cx1.round(), cy1.round(), cx2.round(), cy2.round(),
      r: (ch / 2).round(), color: hole);
  // Flatten the left side of the counter too.
  _squircle(canvas,
      cx1.round(), cy1.round(),
      (cx1 + ch / 2).round(), cy2.round(),
      r: 0, color: hole);
}

// ---------------------------------------------------------------------------
// Overview sheet
// ---------------------------------------------------------------------------
void _renderOverviewSheet(List<_Variant> variants, int masterSize) {
  const cellSize = 220;
  const cellGap = 20;
  const labelGap = 52;
  const margin = 56;
  const headerH = 120;
  final columns = 1 + _previewPalettes.length;
  final rowHeight = cellSize + labelGap;
  final width = margin * 2 + columns * cellSize + (columns - 1) * cellGap;
  final height = margin * 2 +
      headerH +
      variants.length * rowHeight +
      (variants.length - 1) * labelGap;

  final sheet = img.Image(width: width, height: height);
  img.fillRect(sheet,
      x1: 0, y1: 0, x2: width - 1, y2: height - 1,
      color: _rgb(0xFFF6F8F1));

  img.drawString(sheet, 'SGGW Days — SD monogram with 5-dot separator',
      font: img.arial48, x: margin, y: margin - 12, color: _rgb(0xFF24291E));
  img.drawString(sheet,
      'Left: full-colour master.  Right: Android themed-icon tint previews.',
      font: img.arial24,
      x: margin, y: margin + 48, color: _rgb(0xFF5C6355));

  for (var row = 0; row < variants.length; row++) {
    final v = variants[row];
    final y = margin + headerH + row * (rowHeight + labelGap);

    img.drawString(sheet, v.label,
        font: img.arial48, x: margin, y: y - 46, color: _rgb(0xFF24291E));
    img.drawString(sheet, v.tagline,
        font: img.arial24, x: margin + 220, y: y - 30, color: _rgb(0xFF5C6355));

    final master = img.decodePng(
        File('$_outputDir/${v.name}-master.png').readAsBytesSync())!;
    final masterScaled = img.copyResize(master,
        width: cellSize, height: cellSize,
        interpolation: img.Interpolation.average);
    img.compositeImage(sheet, masterScaled, dstX: margin, dstY: y);

    final mono = img.decodePng(
        File('$_outputDir/${v.name}-monochrome.png').readAsBytesSync())!;
    for (var i = 0; i < _previewPalettes.length; i++) {
      final palette = _previewPalettes[i];
      final tileX = margin + (i + 1) * (cellSize + cellGap);
      _drawThemedTile(sheet, tileX, y, cellSize, palette, mono);
      img.drawString(sheet, palette.name,
          font: img.arial24,
          x: tileX + cellSize ~/ 2 - 24,
          y: y + cellSize + 6,
          color: _rgb(0xFF5C6355));
    }
  }

  File('$_outputDir/concepts-overview.png')
      .writeAsBytesSync(img.encodePng(sheet));
}

void _drawThemedTile(img.Image sheet, int x, int y, int size,
    _Palette palette, img.Image monoFull) {
  img.fillRect(sheet,
      x1: x, y1: y, x2: x + size - 1, y2: y + size - 1,
      color: palette.background, radius: (size * 0.23).round());

  final colourised = img.Image(
      width: monoFull.width, height: monoFull.height, numChannels: 4);
  for (var py = 0; py < monoFull.height; py++) {
    for (var px = 0; px < monoFull.width; px++) {
      final a = monoFull.getPixel(px, py).a.toInt();
      colourised.setPixelRgba(px, py,
          palette.foreground.r.toInt(),
          palette.foreground.g.toInt(),
          palette.foreground.b.toInt(),
          a);
    }
  }

  final inner = (size * 0.70).round();
  final scaled = img.copyResize(colourised,
      width: inner, height: inner,
      backgroundColor: img.ColorRgba8(0, 0, 0, 0),
      interpolation: img.Interpolation.average);
  img.compositeImage(sheet, scaled,
      dstX: x + (size - inner) ~/ 2,
      dstY: y + (size - inner) ~/ 2);
}
