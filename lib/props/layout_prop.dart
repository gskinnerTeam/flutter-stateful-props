import 'dart:async';

import 'package:flutter/material.dart';

import '../stateful_props_manager.dart';

class LayoutProp extends StatefulProp<LayoutProp> {
  static Size defaultContextSize = Size(1, 1);

  LayoutProp({this.key, this.measureContext = false}) {
    _contextSize = defaultContextSize;
  }
  Key key;
  bool measureContext;

  //Helper methods
  BoxConstraints get constraints => _constraints;
  Size get parentSize => _constraints.biggest;
  Size get contextSize => _contextSize;

  //Internal state
  BoxConstraints _constraints = BoxConstraints();
  Size _contextSize;

  @override
  void init() {
    // In order to get a proper measurement for size we need to layout twice...
    //TODO: Can we do something else here?
    if (measureContext) {
      scheduleMicrotask(() => setState(() {}));
    }
  }

  @override
  void update(LayoutProp newProp) {
    key = newProp.key;
  }

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return (c) => LayoutBuilder(
          key: key,
          builder: (context, constraints) {
            _constraints = constraints;
            if (measureContext) {
              RenderBox rb = context.findRenderObject() as RenderBox;
              if (rb?.hasSize ?? false) {
                _contextSize = rb.size;
              }
            }
            return childBuilder(context);
          },
        );
  }
}
