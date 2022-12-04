import 'package:flutter/material.dart';
import 'package:reactives/src/stateful_props_manager.dart';
import 'package:reactives/src/stateful_prop.dart';

/// Listens to a notifier, rebuilding when it changes, or calling a callback.
class NotifierListenerProp<T extends ChangeNotifier> extends StatefulProp {
  final T notifier;
  final bool autoBuild;
  final VoidCallback? onChange;

  NotifierListenerProp(
    StatefulPropsManager manager,
    this.notifier, {
    this.autoBuild = false,
    this.onChange,
  }) : super(manager) {
    if (autoBuild) {
      notifier.addListener(manager.scheduleBuild);
    }
    if (onChange != null) {
      notifier.addListener(onChange!);
    }
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }
}
