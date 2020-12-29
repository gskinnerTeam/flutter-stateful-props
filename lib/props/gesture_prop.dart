import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../stateful_props_manager.dart';

// Core GestureDetector Property
// Usage: initProperty((_, __) => GestureProp(onTapDown: _handleTap, onTapUp: ..., etc));
class GestureProp extends StatefulProp<GestureProp> {
  GestureProp(
      {this.behavior = HitTestBehavior.opaque,
      this.dragStartBehavior = DragStartBehavior.start,
      this.excludeFromSemantics = false,
      this.key,
      this.onTap,
      this.onLongPress});
  HitTestBehavior behavior;
  DragStartBehavior dragStartBehavior;
  bool excludeFromSemantics;
  Key key;

  // Callbacks
  void Function() onTap;
  void Function() onLongPress;

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return (c) => GestureDetector(
          key: key,
          behavior: behavior,
          dragStartBehavior: dragStartBehavior,
          excludeFromSemantics: excludeFromSemantics,
          // TODO: Implement all the other 20+ callbacks for gestureDetector
          onTap: () => onTap?.call(),
          onLongPress: () => onLongPress?.call(),
          child: childBuilder(c),
        );
  }

  @override
  void update(GestureProp newProp) {
    behavior = newProp.behavior;
    dragStartBehavior = newProp.dragStartBehavior;
    excludeFromSemantics = newProp.excludeFromSemantics;
    key = newProp.key;
    // Callbacks
    onTap = newProp.onTap;
    onLongPress = newProp.onLongPress;
  }
}

/// Demonstrates how we can extend an existing Prop, to focus it for a specific use case.
/// Tap is such a common use case, that having this accelerator is quite nice.
/// In this case, we're omitting the "onTap: " from GestureDetectorProp, and using a shorter name.
/// Usage: `addProp(TapProp(_handleTap))`
///         vs
///        `addProp(onTap: GestureDetectorProp(_handleTap))`
class TapProp extends GestureProp {
  TapProp(VoidCallback onTap) : super(onTap: onTap);

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return super.getBuilder(childBuilder);
  }
}
