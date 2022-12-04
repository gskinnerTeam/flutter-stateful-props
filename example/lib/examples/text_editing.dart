import 'package:flutter/material.dart';
import 'package:reactives/stateful_props.dart';

class TextEditingDemo extends StatefulWidget {
  const TextEditingDemo({Key? key}) : super(key: key);

  @override
  State<TextEditingDemo> createState() => _TextEditingDemoState();
}

class _TextEditingDemoState extends State<TextEditingDemo> with StatefulPropsMixin {
  late final _text = TextEditingControllerProp(this);

  void _handleBtnPressed() => _text.controller.text = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(controller: _text.controller),
          TextButton(
              onPressed: _handleBtnPressed,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Clear Text'),
              ))
        ],
      ),
    );
  }
}
