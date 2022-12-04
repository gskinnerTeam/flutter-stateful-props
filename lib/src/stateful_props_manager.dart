import 'package:flutter/material.dart';

import '../stateful_props.dart';

/// The basic contract for a StatefulPropsManager. Allows any object to become a props manager.
/// See [StatefulPropsMixin] for a mixin that implements this interface for any State<T> class.
abstract class StatefulPropsManager {
  addProp(StatefulProp ctrl);
  removeProp(StatefulProp ctrl);
  scheduleBuild();

  bool get mounted;
  BuildContext get context;
}

/// Turns any state class to a [StatefulPropsManager]
mixin StatefulPropsMixin<T extends StatefulWidget> on State<T> implements StatefulPropsManager {
  @protected
  final List<StatefulProp> props = [];

  @override
  void addProp(StatefulProp value) => props.add(value);

  @override
  void removeProp(StatefulProp value) => props.remove(value);

  @override
  void scheduleBuild() => setState(() {});

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final p in props) {
      p.didUpdateWidget(oldWidget);
    }
  }

  // Callbacks
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final p in props) {
      p.didChangeDependencies();
    }
  }

  @override
  void activate() {
    super.activate();
    for (final p in props) {
      p.activate();
    }
  }

  @override
  void deactivate() {
    for (final p in props) {
      p.deactivate();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    for (final p in props) {
      p.dispose();
    }
    props.clear();
    super.dispose();
  }
}
