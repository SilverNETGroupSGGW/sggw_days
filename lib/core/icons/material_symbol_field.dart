import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sggw_days/core/icons/material_symbol_catalog.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialSymbolField extends StatelessWidget {
  const MaterialSymbolField({
    super.key,
    required this.controller,
    required this.fallbackIcon,
    required this.labelText,
    required this.emptyHelperText,
  });

  final TextEditingController controller;
  final IconData fallbackIcon;
  final String labelText;
  final String emptyHelperText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final rawName = value.text.trim();
        final normalizedName = normalizeMaterialSymbolName(rawName);
        final hasValue = rawName.isNotEmpty;
        final isKnown = normalizedName != null;

        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: 'Enter a Google Fonts Material Symbol name',
            prefixIcon: Icon(
              materialSymbolForName(rawName, fallback: fallbackIcon),
            ),
            suffixIcon: IconButton(
              tooltip: 'Browse all Material Symbols',
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _openCatalog(context),
            ),
            helperText: hasValue && isKnown
                ? 'Preview: $normalizedName'
                : emptyHelperText,
            errorText: hasValue && !isKnown
                ? 'Unknown Material Symbol name'
                : null,
          ),
        );
      },
    );
  }

  Future<void> _openCatalog(BuildContext context) async {
    final uri = materialSymbolsCatalogUri();
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) return;

    await Clipboard.setData(ClipboardData(text: uri.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material Symbols link copied.')),
    );
  }
}
