import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:stateful_props/src/props/single_ticker_mixin.dart';
import 'package:stateful_props/src/stateful_props_manager.dart';
import 'package:stateful_props/src/stateful_prop.dart';

class AnimationControllerProp extends StatefulProp with SingleTickerStatefulPropMixin implements TickerProvider {
  AnimationControllerProp(
    StatefulPropsManager manager,
    Duration duration, {
    Duration? reverseDuration,
    double initialValue = 0,
    double lowerBound = 0,
    double upperBound = 1,
    TickerProvider? vsync,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    this.autoBuild = false,
    bool autoPlay = true,
  }) : super(manager) {
    controller = AnimationController(
      vsync: vsync ?? this,
      duration: duration,
      reverseDuration: reverseDuration,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
    );
    if (autoBuild) controller.addListener(manager.scheduleBuild);
    if (autoPlay) controller.forward();
  }

  final bool autoBuild;
  late final AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
