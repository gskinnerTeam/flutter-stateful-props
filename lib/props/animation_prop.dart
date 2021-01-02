import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';

import '../stateful_props_manager.dart';

// TODO: Add Restoration to StatefulAnimationController
class AnimationProp extends StatefulProp<AnimationProp> implements TickerProvider {
  AnimationProp(
    this.seconds, {
    this.autoBuild = true,
    this.autoStart = true,
    this.onTick,
    this.vsync,
    this.debugLabel,
    this.initialValue = 0,
    this.lowerBound = 0,
    this.upperBound = 1,
    this.animationBehavior = AnimationBehavior.normal,
  });

  double seconds;
  bool autoBuild;
  final bool autoStart;
  TickerProvider vsync;
  final String debugLabel;
  final double initialValue;
  final double lowerBound;
  final double upperBound;
  final AnimationBehavior animationBehavior;

  // Callbacks
  void Function(AnimationProp value) onTick;

  // Internal State
  Ticker _ticker;
  AnimationController get controller => _controller;
  AnimationController _controller;

  @override
  void init() {
    _controller = AnimationController(
      duration: seconds.duration,
      vsync: vsync ?? this,
      debugLabel: debugLabel,
      value: initialValue,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
    );
    // Add listener to dispatch change events and (optionally) to rebuild the view on tick.
    _controller.addListener(_handleAnimationTick);
    if (autoStart) _controller.forward();
  }

  @override
  void update(AnimationProp newProp) {
    if (seconds != newProp.seconds) {
      seconds = newProp.seconds;
      _controller.duration = seconds.duration;
    }
    if (vsync != newProp.vsync) {
      vsync = newProp.vsync;
      _controller.resync(vsync);
    }
    // Callbacks
    onTick = newProp.onTick ?? onTick;
  }

  @override
  void dispose() => _controller.dispose();

  void _handleAnimationTick() {
    if (autoBuild) {
      setState(() => {});
    }
    onTick?.call(this);
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker ??= Ticker((elapsed) => onTick(elapsed));
    return _ticker;
  }

  // Helper methods
  double get value => controller?.value ?? 0;
  bool get isComplete =>
      controller.status == AnimationStatus.completed || controller.status == AnimationStatus.dismissed;
  bool get isPlaying => isGoingForward || isGoingReverse;
  bool get isGoingForward => controller.status == AnimationStatus.forward;
  bool get isGoingReverse => controller.status == AnimationStatus.reverse;

  // Utilities to make tween usage cleaner  final t = anim1Prop.addDoubleTween(curve: Curves.easeOut)
  Animation<T> addTween<T>(Tween<T> tween, {Curve curve: Curves.linear}) =>
      tween.animate(CurvedAnimation(parent: _controller, curve: curve));

  Animation<double> tweenDouble({double begin: 0.0, double end: 1.0, Curve curve: Curves.linear}) =>
      addTween(Tween<double>(begin: begin, end: end), curve: curve);

  Animation<int> tweenInt({int begin: 0, int end: 100, Curve curve: Curves.linear}) =>
      addTween(IntTween(begin: begin, end: end), curve: curve);
}
