import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  final Widget? icon;
  final EdgeInsetsGeometry? iconPadding;
  final Color? iconColor;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final TextStyle? titleTextStyle;
  final Widget? content;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? contentTextStyle;
  final List<Widget> actions;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsetsGeometry? buttonPadding;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final String? semanticLabel;
  final EdgeInsets? insetPadding;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final bool scrollable;

  const AppAlertDialog({
    super.key,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.title,
    this.titlePadding,
    this.titleTextStyle,
    this.content,
    this.contentPadding,
    this.contentTextStyle,
    this.actions = const [],
    this.actionsPadding,
    this.buttonPadding,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.semanticLabel,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.constraints,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = actions.isNotEmpty;

    return AlertDialog(
      icon: icon,
      iconPadding: iconPadding,
      iconColor: iconColor,
      title: title,
      titlePadding: titlePadding,
      titleTextStyle: titleTextStyle,
      content: content,
      contentPadding: contentPadding,
      contentTextStyle: contentTextStyle,
      actions: hasActions ? actions : null,
      actionsPadding: hasActions
          ? actionsPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 20)
          : actionsPadding,
      actionsAlignment: actions.length > 1
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      actionsOverflowAlignment: OverflowBarAlignment.start,
      buttonPadding: buttonPadding ?? EdgeInsets.zero,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      semanticLabel: semanticLabel,
      insetPadding: insetPadding,
      clipBehavior: clipBehavior,
      shape: shape,
      alignment: alignment,
      constraints: constraints,
      scrollable: scrollable,
    );
  }
}

class AppDialogActionBar extends StatelessWidget {
  final List<Widget> leading;
  final List<Widget> trailing;
  final double spacing;

  const AppDialogActionBar({
    super.key,
    this.leading = const [],
    this.trailing = const [],
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [...leading, ...trailing];
    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leading.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: leading,
            ),
          ),
        if (leading.isNotEmpty && trailing.isNotEmpty)
          SizedBox(height: spacing),
        if (trailing.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: trailing,
            ),
          ),
        if (leading.isEmpty && trailing.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: actions,
            ),
          ),
      ],
    );
  }
}
