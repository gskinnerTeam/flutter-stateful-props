import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Creates and disposes a [FocusNode].
class FocusNodeProp extends StatefulProp with ChangeNotifier {
  FocusNodeProp(
    StatefulPropsManager manager, {
    FocusNode? node,
    this.onKey,
    this.onKeyEvent,
    this.skipTraversal = false,
    this.canRequestFocus = true,
    this.descendantsAreFocusable = true,
    this.descendantsAreTraversable = true,
  }) : super(manager) {
    this.node = (node ??
        FocusNode(
          onKey: onKey,
          onKeyEvent: onKeyEvent,
          skipTraversal: skipTraversal,
          canRequestFocus: canRequestFocus,
          descendantsAreFocusable: descendantsAreFocusable,
          descendantsAreTraversable: descendantsAreTraversable,
        ))
      ..addListener(notifyListeners);
  }

  final FocusOnKeyCallback? onKey;
  final FocusOnKeyEventCallback? onKeyEvent;
  final bool skipTraversal;
  final bool canRequestFocus;
  final bool descendantsAreFocusable;
  final bool descendantsAreTraversable;

  late final FocusNode node;

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }
}
