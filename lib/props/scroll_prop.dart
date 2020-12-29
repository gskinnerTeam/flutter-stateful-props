import 'package:flutter/widgets.dart';
import '../stateful_props_manager.dart';

/// ScrollController is pretty much fully immutable, so no updates to sync here.
class ScrollProp extends StatefulProp<ScrollProp> {
  ScrollProp({this.initialScrollOffset: 0.0, this.keepScrollOffset: true, this.debugLabel, this.onChanged});
  final double initialScrollOffset;
  final bool keepScrollOffset;
  final String debugLabel;

  // Callbacks
  void Function(ScrollProp prop) onChanged;

  // Helper Methods
  ScrollPosition get position => _controller.position;
  ScrollController get controller => _controller;

  // Internal state
  ScrollController _controller;

  @override
  void init() {
    _controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      debugLabel: debugLabel,
    );
    _controller.addListener(_handleScrollChanged);
  }

  @override
  void update(ScrollProp newProp) {
    onChanged = newProp.onChanged ?? onChanged;
  }

  @override
  void dispose() => _controller.dispose();

  void _handleScrollChanged() => onChanged?.call(this);
}
