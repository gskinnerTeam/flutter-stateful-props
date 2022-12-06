import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Creates and disposes a [ScrollController].
class TransformationControllerProp extends StatefulProp {
  TransformationControllerProp(
    StatefulPropsMixin manager, {
    Matrix4? initialMatrix,
    bool autoBuild = false,
    VoidCallback? onChange,
  }) : super(manager) {
    controller = TransformationController(initialMatrix);
    listener = NotifierListenerProp(manager, controller, autoBuild: autoBuild, onChange: onChange);
  }

  late final TransformationController controller;
  late final NotifierListenerProp listener;

  Matrix4 get matrix => controller.value;
}
