import 'package:flutter/widgets.dart';
import 'package:stateful_props/props/focus_prop.dart';
import '../stateful_props_manager.dart';

//TODO: Update RawKeyboardProp so it can make it's own node internally... ideally it can use the Property?
// How? We should be able use addProp and syncProp, as long as make sure to only run it once...
// That means we either do it in init(), or very carefully in didUpdate... init() is problematic.
// We basically want a lazy addProp and syncProp implementation... where something is added on request, and only once.
class KeyboardProp extends StatefulProp<KeyboardProp> {
  KeyboardProp({
    this.focusNode,
    this.autofocus = true,
    this.includeSemantics = true,
    this.key,
    this.onPressed,
  });
  FocusNode focusNode;
  bool autofocus;
  bool includeSemantics;
  Key key;

  // Callbacks
  ValueChanged<RawKeyEvent> onPressed;

  @override
  void init() {
    if (focusNode == null) {
      focusNode = addProp(FocusProp());
    }
  }

  @override
  void update(KeyboardProp newProp) {
    focusNode = newProp.focusNode ?? focusNode;
    autofocus = newProp.autofocus;
    includeSemantics = newProp.includeSemantics;
    // Callbacks
    onPressed = newProp.onPressed;
  }

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return (c) => RawKeyboardListener(
          key: key,
          focusNode: focusNode,
          autofocus: autofocus,
          includeSemantics: includeSemantics,
          onKey: onPressed,
          child: FocusScope(child: childBuilder(c), autofocus: autofocus),
        );
  }
}
