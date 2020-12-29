import 'package:flutter/widgets.dart';
import '../stateful_props_manager.dart';

class FocusProp extends StatefulProp<FocusProp> {
  FocusProp(
      {this.debugLabel,
      this.onKey,
      this.skipTraversal: false,
      this.canRequestFocus: true,
      this.descendantsAreFocusable: true,
      this.onChanged});
  String debugLabel;
  FocusOnKeyCallback onKey;
  bool skipTraversal;
  bool canRequestFocus;
  bool descendantsAreFocusable;

  // Callbacks
  void Function(FocusProp value) onChanged;

  // Helper methods
  FocusNode get node => _node;
  bool get hasFocus => _node.hasFocus;

  // Internal state
  FocusNode _node;

  @override
  void init() {
    _node = FocusNode(
        debugLabel: debugLabel,
        onKey: onKey,
        skipTraversal: skipTraversal,
        canRequestFocus: canRequestFocus,
        descendantsAreFocusable: descendantsAreFocusable);
    _node.addListener(_handleFocusChanged);
  }

  @override
  void update(FocusProp newProp) {
    if (compareValuesForChange(debugLabel, newProp.debugLabel)) {
      _node.debugLabel = debugLabel = newProp.debugLabel;
    }
    if (compareValuesForChange(skipTraversal, newProp.skipTraversal)) {
      skipTraversal = _node.skipTraversal = newProp.skipTraversal;
    }
    if (compareValuesForChange(canRequestFocus, newProp.canRequestFocus)) {
      canRequestFocus = _node.canRequestFocus = newProp.canRequestFocus;
    }
    if (compareValuesForChange(canRequestFocus, newProp.descendantsAreFocusable)) {
      descendantsAreFocusable = _node.descendantsAreFocusable = newProp.descendantsAreFocusable;
    }
    // Callbacks
    onChanged = newProp.onChanged ?? onChanged;
  }

  @override
  void dispose() => _node.dispose();

  void _handleFocusChanged() => onChanged?.call(this);
}
