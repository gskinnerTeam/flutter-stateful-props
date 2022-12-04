import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Creates and disposes a [TextEditingController].
class TextEditingControllerProp extends StatefulProp with SingleTickerStatefulPropMixin {
  TextEditingControllerProp(
    StatefulPropsManager manager, {
    String? text,
    bool autoBuild = false,
    VoidCallback? onChange,
  }) : super(manager) {
    controller = TextEditingController(text: text);
    listener = NotifierListenerProp(manager, controller, autoBuild: autoBuild, onChange: onChange);
  }

  late final TextEditingController controller;
  late final NotifierListenerProp listener;
}
