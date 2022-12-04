import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Creates and disposes a [FocusNode].
class FocusNodeProp extends StatefulProp with ChangeNotifier {
  FocusNodeProp(StatefulPropsManager manager, {FocusNode? node}) : super(manager) {
    this.node = (node ?? FocusNode())..addListener(notifyListeners);
  }

  late final FocusNode node;

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }
}
