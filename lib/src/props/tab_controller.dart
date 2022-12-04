import 'package:flutter/material.dart';
import 'package:reactives/stateful_props.dart';
import 'package:reactives/src/props/single_ticker_mixin.dart';

class TabControllerProp extends StatefulProp with SingleTickerStatefulPropMixin {
  TabControllerProp(
    StatefulPropsManager manager, {
    int initialIndex = 0,
    required int length,
    bool autoBuild = false,
    VoidCallback? onChange,
  }) : super(manager) {
    controller = TabController(
      initialIndex: initialIndex,
      length: length,
      vsync: this,
    );
    listener = NotifierListenerProp(manager, controller, autoBuild: autoBuild, onChange: onChange);
  }
  late final TabController controller;
  late final NotifierListenerProp listener;
}
