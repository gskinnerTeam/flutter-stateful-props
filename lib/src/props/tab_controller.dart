import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

class TabControllerProp extends StatefulProp with SingleTickerStatefulPropMixin {
  TabControllerProp(
    StatefulPropsManager manager, {
    int initialIndex = 0,
    required int length,
    bool autoBuild = false,
    VoidCallback? onChange,
    Duration? animationDuration,
  }) : super(manager) {
    controller = TabController(
      initialIndex: initialIndex,
      animationDuration: animationDuration,
      length: length,
      vsync: this,
    );
    listener = NotifierListenerProp(manager, controller, autoBuild: autoBuild, onChange: onChange);
  }
  late final TabController controller;
  late final NotifierListenerProp listener;

  int get index => controller.index;
}
