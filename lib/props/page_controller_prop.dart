import 'package:flutter/widgets.dart';
import '../stateful_props_manager.dart';

//TODO: Could we allow you to change the keepPage or viewPortFraction by re-creating the controller internally?
class PageControllerProp extends StatefulProp<PageControllerProp> {
  PageControllerProp({this.initialPage: 0, this.keepPage: true, this.viewportFraction: 1.0, this.onChanged});
  final int initialPage;
  final bool keepPage;
  final double viewportFraction;

  // Callbacks
  void Function(PageControllerProp prop) onChanged;

  // Internal state
  PageController _controller;

  @override
  void init() {
    _controller = PageController(
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
    );
    _controller.addListener(_handlePageChanged);
  }

  @override
  void update(PageControllerProp newProp) {
    onChanged = newProp.onChanged;
  }

  @override
  void dispose() => _controller.dispose();

  void _handlePageChanged() => onChanged?.call(this);

  // Helper Methods
  ScrollPosition get position => _controller.position;
  PageController get controller => _controller;
}
