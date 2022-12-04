import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Creates a [StreamController] which is automatically disposed when necessary.
class StreamControllerProp<T> extends StatefulProp {
  StreamControllerProp(
    StatefulPropsManager manager, {
    bool sync = false,
    VoidCallback? onListen,
    VoidCallback? onCancel,
  }) : super(manager) {
    controller = StreamController.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  late final StreamController controller;

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }
}
