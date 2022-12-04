import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Shows basic usage of a ValueProp, which simply calls setState anytime its value is changed.
/// All of the various primitives are supported, [IntProp], [BoolProp], [DoubleProp], [StringProp] etc
/// You can also create your own with `ValueProp<MyCustomType>`
class ValuePropDemo extends StatefulWidget {
  const ValuePropDemo({Key? key}) : super(key: key);

  @override
  State<ValuePropDemo> createState() => _ValuePropState();
}

class _ValuePropState extends State<ValuePropDemo> with StatefulPropsMixin {
  /// A prop to hold the counter state, and rebuild when it changes.
  /// Basically equivalent to `ValueProp<int>`
  late final _counter = IntProp(this);

  /// Just change the value, and the widget will rebuild. Saves calling setState everytime we want to change this number
  void _handleBtnPressed() => _counter.value++;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _handleBtnPressed,
      child: Text('${_counter.value}'),
    );
  }
}
