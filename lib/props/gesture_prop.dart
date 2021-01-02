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
      this.onTapDown,
      this.onTapUp,
      this.onTap,
      this.onTapCancel,
      this.onSecondaryTap,
      this.onSecondaryTapDown,
      this.onSecondaryTapUp,
      this.onSecondaryTapCancel,
      this.onTertiaryTapDown,
      this.onTertiaryTapUp,
      this.onTertiaryTapCancel,
      this.onDoubleTapDown,
      this.onDoubleTap,
      this.onDoubleTapCancel,
      this.onLongPress,
      this.onLongPressStart,
      this.onLongPressMoveUpdate,
      this.onLongPressUp,
      this.onLongPressEnd,
      this.onSecondaryLongPress,
      this.onSecondaryLongPressStart,
      this.onSecondaryLongPressMoveUpdate,
      this.onSecondaryLongPressUp,
      this.onSecondaryLongPressEnd,
      this.onVerticalDragDown,
      this.onVerticalDragStart,
      this.onVerticalDragUpdate,
      this.onVerticalDragEnd,
      this.onVerticalDragCancel,
      this.onHorizontalDragDown,
      this.onHorizontalDragStart,
      this.onHorizontalDragUpdate,
      this.onHorizontalDragEnd,
      this.onHorizontalDragCancel,
      this.onForcePressStart,
      this.onForcePressPeak,
      this.onForcePressUpdate,
      this.onForcePressEnd,
      this.onPanDown,
      this.onPanStart,
      this.onPanUpdate,
      this.onPanEnd,
      this.onPanCancel,
      this.onScaleStart,
      this.onScaleUpdate,
      this.onScaleEnd});

  HitTestBehavior behavior;
  DragStartBehavior dragStartBehavior;
  bool excludeFromSemantics;
  Key key;

  // Callbacks
  GestureTapDownCallback onTapDown;
  GestureTapUpCallback onTapUp;
  GestureTapCallback onTap;
  GestureTapCancelCallback onTapCancel;
  GestureTapCallback onSecondaryTap;
  GestureTapDownCallback onSecondaryTapDown;
  GestureTapUpCallback onSecondaryTapUp;
  GestureTapCancelCallback onSecondaryTapCancel;
  GestureTapDownCallback onTertiaryTapDown;
  GestureTapUpCallback onTertiaryTapUp;
  GestureTapCancelCallback onTertiaryTapCancel;
  GestureTapDownCallback onDoubleTapDown;
  GestureTapCallback onDoubleTap;
  GestureTapCancelCallback onDoubleTapCancel;
  GestureLongPressCallback onLongPress;
  GestureLongPressStartCallback onLongPressStart;
  GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;
  GestureLongPressUpCallback onLongPressUp;
  GestureLongPressEndCallback onLongPressEnd;
  GestureLongPressCallback onSecondaryLongPress;
  GestureLongPressStartCallback onSecondaryLongPressStart;
  GestureLongPressMoveUpdateCallback onSecondaryLongPressMoveUpdate;
  GestureLongPressUpCallback onSecondaryLongPressUp;
  GestureLongPressEndCallback onSecondaryLongPressEnd;
  GestureDragDownCallback onVerticalDragDown;
  GestureDragStartCallback onVerticalDragStart;
  GestureDragUpdateCallback onVerticalDragUpdate;
  GestureDragEndCallback onVerticalDragEnd;
  GestureDragCancelCallback onVerticalDragCancel;
  GestureDragDownCallback onHorizontalDragDown;
  GestureDragStartCallback onHorizontalDragStart;
  GestureDragUpdateCallback onHorizontalDragUpdate;
  GestureDragEndCallback onHorizontalDragEnd;
  GestureDragCancelCallback onHorizontalDragCancel;
  GestureDragDownCallback onPanDown;
  GestureDragStartCallback onPanStart;
  GestureDragUpdateCallback onPanUpdate;
  GestureDragEndCallback onPanEnd;
  GestureDragCancelCallback onPanCancel;
  GestureScaleStartCallback onScaleStart;
  GestureScaleUpdateCallback onScaleUpdate;
  GestureScaleEndCallback onScaleEnd;
  GestureForcePressStartCallback onForcePressStart;
  GestureForcePressPeakCallback onForcePressPeak;
  GestureForcePressUpdateCallback onForcePressUpdate;
  GestureForcePressEndCallback onForcePressEnd;

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return (c) => GestureDetector(
          key: key,
          behavior: behavior,
          dragStartBehavior: dragStartBehavior,
          excludeFromSemantics: excludeFromSemantics,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          onTap: onTap,
          onTapCancel: onTapCancel,
          onSecondaryTap: onSecondaryTap,
          onSecondaryTapDown: onSecondaryTapDown,
          onSecondaryTapUp: onSecondaryTapUp,
          onSecondaryTapCancel: onSecondaryTapCancel,
          onTertiaryTapDown: onTertiaryTapDown,
          onTertiaryTapUp: onTertiaryTapUp,
          onTertiaryTapCancel: onTertiaryTapCancel,
          onDoubleTapDown: onDoubleTapDown,
          onDoubleTap: onDoubleTap,
          onDoubleTapCancel: onDoubleTapCancel,
          onLongPress: onLongPress,
          onLongPressStart: onLongPressStart,
          onLongPressMoveUpdate: onLongPressMoveUpdate,
          onLongPressUp: onLongPressUp,
          onLongPressEnd: onLongPressEnd,
          onSecondaryLongPress: onSecondaryLongPress,
          onSecondaryLongPressStart: onSecondaryLongPressStart,
          onSecondaryLongPressMoveUpdate: onSecondaryLongPressMoveUpdate,
          onSecondaryLongPressUp: onSecondaryLongPressUp,
          onSecondaryLongPressEnd: onSecondaryLongPressEnd,
          onVerticalDragDown: onVerticalDragDown,
          onVerticalDragStart: onVerticalDragStart,
          onVerticalDragUpdate: onVerticalDragUpdate,
          onVerticalDragEnd: onVerticalDragEnd,
          onVerticalDragCancel: onVerticalDragCancel,
          onHorizontalDragDown: onHorizontalDragDown,
          onHorizontalDragStart: onHorizontalDragStart,
          onHorizontalDragUpdate: onHorizontalDragUpdate,
          onHorizontalDragEnd: onHorizontalDragEnd,
          onHorizontalDragCancel: onHorizontalDragCancel,
          onPanDown: onPanDown,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          onPanCancel: onPanCancel,
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,
          onForcePressStart: onForcePressStart,
          onForcePressPeak: onForcePressPeak,
          onForcePressUpdate: onForcePressUpdate,
          onForcePressEnd: onForcePressEnd,
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
    onTapDown = newProp.onTapDown;
    onTapUp = newProp.onTapUp;
    onTap = newProp.onTap;
    onTapCancel = newProp.onTapCancel;
    onSecondaryTap = newProp.onSecondaryTap;
    onSecondaryTapDown = newProp.onSecondaryTapDown;
    onSecondaryTapUp = newProp.onSecondaryTapUp;
    onSecondaryTapCancel = newProp.onSecondaryTapCancel;
    onTertiaryTapDown = newProp.onTertiaryTapDown;
    onTertiaryTapUp = newProp.onTertiaryTapUp;
    onTertiaryTapCancel = newProp.onTertiaryTapCancel;
    onDoubleTapDown = newProp.onDoubleTapDown;
    onDoubleTap = newProp.onDoubleTap;
    onDoubleTapCancel = newProp.onDoubleTapCancel;
    onLongPress = newProp.onLongPress;
    onLongPressStart = newProp.onLongPressStart;
    onLongPressMoveUpdate = newProp.onLongPressMoveUpdate;
    onLongPressUp = newProp.onLongPressUp;
    onLongPressEnd = newProp.onLongPressEnd;
    onSecondaryLongPress = newProp.onSecondaryLongPress;
    onSecondaryLongPressStart = newProp.onSecondaryLongPressStart;
    onSecondaryLongPressMoveUpdate = newProp.onSecondaryLongPressMoveUpdate;
    onSecondaryLongPressUp = newProp.onSecondaryLongPressUp;
    onSecondaryLongPressEnd = newProp.onSecondaryLongPressEnd;
    onVerticalDragDown = newProp.onVerticalDragDown;
    onVerticalDragStart = newProp.onVerticalDragStart;
    onVerticalDragUpdate = newProp.onVerticalDragUpdate;
    onVerticalDragEnd = newProp.onVerticalDragEnd;
    onVerticalDragCancel = newProp.onVerticalDragCancel;
    onHorizontalDragDown = newProp.onHorizontalDragDown;
    onHorizontalDragStart = newProp.onHorizontalDragStart;
    onHorizontalDragUpdate = newProp.onHorizontalDragUpdate;
    onHorizontalDragEnd = newProp.onHorizontalDragEnd;
    onHorizontalDragCancel = newProp.onHorizontalDragCancel;
    onPanDown = newProp.onPanDown;
    onPanStart = newProp.onPanStart;
    onPanUpdate = newProp.onPanUpdate;
    onPanEnd = newProp.onPanEnd;
    onPanCancel = newProp.onPanCancel;
    onScaleStart = newProp.onScaleStart;
    onScaleUpdate = newProp.onScaleUpdate;
    onScaleEnd = newProp.onScaleEnd;
    onForcePressStart = newProp.onForcePressStart;
    onForcePressPeak = newProp.onForcePressPeak;
    onForcePressUpdate = newProp.onForcePressUpdate;
    onForcePressEnd = newProp.onForcePressEnd;
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
