import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

class FocusDemo extends StatefulWidget {
  const FocusDemo({Key? key}) : super(key: key);

  @override
  State<FocusDemo> createState() => _FocusDemoState();
}

class _FocusDemoState extends State<FocusDemo> with StatefulPropsMixin {
  late final FocusNodeProp focus1 = FocusNodeProp(this)
    ..addListener(() => print('focus1 changed, hasFocus = ${focus1.node.hasFocus}'));
  late final FocusNodeProp focus2 = FocusNodeProp(this)
    ..addListener(() => print('focus2 changed, hasFocus = ${focus2.node.hasFocus}'));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextFormField(focusNode: focus1.node),
      TextFormField(focusNode: focus2.node),
      OutlinedButton(onPressed: focus1.node.requestFocus, child: const Text('Focus1')),
      OutlinedButton(onPressed: focus2.node.requestFocus, child: const Text('Focus2')),
    ]);
  }
}
