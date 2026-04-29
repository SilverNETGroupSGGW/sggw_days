import 'package:flutter/widgets.dart';

class DynamicColorAvailability extends InheritedWidget {
  const DynamicColorAvailability({
    super.key,
    required this.isSupported,
    required super.child,
  });

  final bool isSupported;

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<DynamicColorAvailability>()
            ?.isSupported ??
        false;
  }

  @override
  bool updateShouldNotify(DynamicColorAvailability oldWidget) {
    return isSupported != oldWidget.isSupported;
  }
}
