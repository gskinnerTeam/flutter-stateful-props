import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Creates and disposes a [PageController].
class PageControllerProp extends StatefulProp {
  PageControllerProp(
    StatefulPropsManager manager, {
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1,
    bool autoBuild = false,
    VoidCallback? onChange,
  }) : super(manager) {
    controller = PageController(
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
    );
    listener = NotifierListenerProp(manager, controller, autoBuild: autoBuild, onChange: onChange);
  }
  late final PageController controller;
  late final NotifierListenerProp listener;

  double get page => controller.hasClients ? controller.page! : 0;
}
