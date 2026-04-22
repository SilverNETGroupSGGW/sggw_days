import 'dart:io';

import 'package:image/image.dart' as img;

const sourcePath = 'sggw.png';
const outputPath = 'assets/icon/android_dynamic_foreground.png';

void main() {
  final sourceBytes = File(sourcePath).readAsBytesSync();
  final sourceImage = img.decodeImage(sourceBytes);

  if (sourceImage == null) {
    throw StateError('Failed to decode $sourcePath');
  }

  final background = sourceImage.getPixel(0, 0);
  final backgroundRed = background.r.toDouble();
  final backgroundGreen = background.g.toDouble();
  final backgroundBlue = background.b.toDouble();

  final outputImage = img.Image(
    width: sourceImage.width,
    height: sourceImage.height,
    numChannels: 4,
  );

  const transparentThreshold = 12.0;
  const opaqueThreshold = 92.0;

  for (var y = 0; y < sourceImage.height; y++) {
    for (var x = 0; x < sourceImage.width; x++) {
      final pixel = sourceImage.getPixel(x, y);
      final difference = [
        (pixel.r - backgroundRed).abs(),
        (pixel.g - backgroundGreen).abs(),
        (pixel.b - backgroundBlue).abs(),
      ].reduce((current, next) => current > next ? current : next);

      final alpha = difference <= transparentThreshold
          ? 0
          : difference >= opaqueThreshold
          ? 255
          : (((difference - transparentThreshold) /
                        (opaqueThreshold - transparentThreshold)) *
                    255)
                .round()
                .clamp(0, 255);

      outputImage.setPixelRgba(x, y, 0, 0, 0, alpha);
    }
  }

  final outputFile = File(outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsBytesSync(img.encodePng(outputImage));
}
