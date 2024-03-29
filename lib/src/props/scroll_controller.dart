import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Creates and disposes a [ScrollController].
class ScrollControllerProp extends StatefulProp {
  ScrollControllerProp(
    StatefulPropsMixin manager, {
    double initialScrollOffset = 0,
    bool keepScrollOffset = true,
    bool autoBuild = false,
    VoidCallback? onChange,
  }) : super(manager) {
    controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
    );
    listener = NotifierListenerProp(manager, controller, autoBuild: autoBuild, onChange: onChange);
  }

  late final ScrollController controller;
  late final NotifierListenerProp listener;

  ScrollPosition? get position => controller.hasClients ? controller.position : null;
  double get px => position?.pixels ?? 0;
}
