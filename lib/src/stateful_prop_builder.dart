import 'package:flutter/widgets.dart';

import 'stateful_prop.dart';
import 'stateful_props_manager.dart';

class StatefulPropBuilder<T extends StatefulProp> extends StatefulWidget {
  final Widget? child;

  final T Function(StatefulPropsMixin manager) init;

  final Widget Function(
    BuildContext context,
    T prop,
    Widget? child,
  ) builder;

  const StatefulPropBuilder({
    Key? key,
    required this.init,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulPropBuilder<T>> createState() => _StatefulPropBuilderState<T>();
}

class _StatefulPropBuilderState<T extends StatefulProp>
    extends State<StatefulPropBuilder<T>> with StatefulPropsMixin {
  late final T prop;

  @override
  void initState() {
    super.initState();
    prop = widget.init(this);
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        prop,
        widget.child,
      );
}
