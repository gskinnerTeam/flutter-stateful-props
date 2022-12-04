import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'stateful_props_manager.dart';

/// The base class for a StatefulProp. Provides lifecycle hooks.
/// New props should extend this class, overriding methods as needed.
abstract class StatefulProp with Diagnosticable {
  StatefulProp(this.manager) {
    manager.addProp(this);
  }

  @protected
  final StatefulPropsManager manager;

  /// Convenience methods for subclasses
  BuildContext get context => manager.context;
  bool get isMounted => manager.mounted;

  /// Optional lifecycle overrides
  void didChangeDependencies() {}
  void didUpdateWidget(covariant StatefulWidget oldWidget) {}
  void dispose() {}
  void activate() {}
  void deactivate() {}
}
