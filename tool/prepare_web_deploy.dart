import 'dart:io';

void main() {
  _copyDirectory(
    Directory('web/.well-known'),
    Directory('build/web/.well-known'),
  );
}

void _copyDirectory(Directory source, Directory destination) {
  if (!source.existsSync()) {
    return;
  }

  destination.createSync(recursive: true);
  for (final entity in source.listSync(recursive: true)) {
    final relativePath = entity.path.substring(source.path.length + 1);
    final outputPath = '${destination.path}/$relativePath';
    if (entity is Directory) {
      Directory(outputPath).createSync(recursive: true);
      continue;
    }
    if (entity is File) {
      File(outputPath).parent.createSync(recursive: true);
      entity.copySync(outputPath);
    }
  }
}
