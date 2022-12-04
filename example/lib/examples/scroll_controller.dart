import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

class ScrollControllerDemo extends StatefulWidget {
  const ScrollControllerDemo({Key? key}) : super(key: key);

  @override
  State<ScrollControllerDemo> createState() => _ScrollControllerDemoState();
}

class _ScrollControllerDemoState extends State<ScrollControllerDemo> with StatefulPropsMixin {
  late final _scroll = ScrollControllerProp(this);

  void _handleBtnPressed() => _scroll.controller.animateTo(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll.controller,
      child: Column(
        children: [
          const SizedBox(width: double.infinity),
          ...List.generate(8, (index) => const FlutterLogo(size: 200)),
          TextButton(
              onPressed: _handleBtnPressed,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Jump To Top'),
              ))
        ],
      ),
    );
  }
}
