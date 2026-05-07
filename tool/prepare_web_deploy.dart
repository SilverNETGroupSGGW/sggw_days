import 'dart:convert';
import 'dart:io';

const _defaultIosBundleIdentifier = 'com.silver.sggw-days';
const _scanPathPattern = '/scan/*';

final _jsonEncoder = const JsonEncoder.withIndent('  ');

void main() {
  final buildWebDirectory = Directory('build/web');
  final wellKnownDirectory = Directory('${buildWebDirectory.path}/.well-known');

  _copyDirectory(Directory('web/.well-known'), wellKnownDirectory);
  _prepareAppleAppSiteAssociation(buildWebDirectory, wellKnownDirectory);
}

void _prepareAppleAppSiteAssociation(
  Directory buildWebDirectory,
  Directory wellKnownDirectory,
) {
  final appConfig = _readSimpleConfig(File('ios/Flutter/AppConfig.xcconfig'));
  final teamId = _firstNonEmpty([
    Platform.environment['APPLE_TEAM_ID'],
    appConfig['APPLE_TEAM_ID'],
  ]);
  final bundleIdentifier =
      _firstNonEmpty([
        Platform.environment['IOS_BUNDLE_IDENTIFIER'],
        Platform.environment['APP_BUNDLE_IDENTIFIER'],
        appConfig['APP_BUNDLE_IDENTIFIER'],
      ]) ??
      _defaultIosBundleIdentifier;
  final outputFiles = [
    File('${buildWebDirectory.path}/apple-app-site-association'),
    File('${wellKnownDirectory.path}/apple-app-site-association'),
  ];

  if (teamId == null) {
    for (final file in outputFiles) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    stderr.writeln(
      'Skipping apple-app-site-association generation because APPLE_TEAM_ID is not set.',
    );
    return;
  }

  final association = <String, Object?>{
    'applinks': <String, Object?>{
      'apps': const <Object>[],
      'details': [
        <String, Object?>{
          'appID': '$teamId.$bundleIdentifier',
          'paths': const [_scanPathPattern],
        },
      ],
    },
  };

  for (final file in outputFiles) {
    _writeJsonFile(file, association);
  }
}

Map<String, String> _readSimpleConfig(File file) {
  if (!file.existsSync()) {
    return const <String, String>{};
  }

  final values = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty ||
        trimmed.startsWith('#') ||
        trimmed.startsWith('//')) {
      continue;
    }

    final separatorIndex = trimmed.indexOf('=');
    if (separatorIndex == -1) {
      continue;
    }

    final key = trimmed.substring(0, separatorIndex).trim();
    final value = trimmed.substring(separatorIndex + 1).trim();
    values[key] = value;
  }

  return values;
}

String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }

  return null;
}

void _writeJsonFile(File file, Object data) {
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('${_jsonEncoder.convert(data)}\n');
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
