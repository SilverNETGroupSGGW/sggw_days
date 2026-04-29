import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/get.dart';
import 'package:material_symbols_icons/symbols.dart';

const materialSymbolsCatalogUrl =
    'https://fonts.google.com/icons?icon.set=Material+Symbols';

IconData materialSymbolForName(
  String? symbolName, {
  required IconData fallback,
}) {
  final normalized = normalizeMaterialSymbolName(symbolName);
  if (normalized == null) return fallback;
  return SymbolsGet.get(normalized, SymbolStyle.outlined);
}

String? normalizeMaterialSymbolName(String? value) {
  final normalized = materialSymbolNameCandidate(value);
  if (normalized == null) return null;
  return SymbolsGet.map.containsKey(normalized) ? normalized : null;
}

String? materialSymbolNameCandidate(String? value) {
  final text = value?.trim().toLowerCase();
  if (text == null || text.isEmpty) return null;

  var normalized = text
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  for (final suffix in const ['_rounded', '_outlined', '_sharp']) {
    if (normalized.endsWith(suffix)) {
      normalized = normalized.substring(0, normalized.length - suffix.length);
      break;
    }
  }

  return normalized.isEmpty ? null : normalized;
}

bool isKnownMaterialSymbolName(String? value) =>
    normalizeMaterialSymbolName(value) != null;

Uri materialSymbolsCatalogUri() => Uri.parse(materialSymbolsCatalogUrl);

// Keep at least one const reference so debug/profile builds still include the
// outlined font even before dynamic user-provided symbols are rendered.
const materialSymbolDefaultFallback = Symbols.question_mark;
