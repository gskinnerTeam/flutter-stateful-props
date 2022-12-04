import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

class PageControllerDemo extends StatefulWidget {
  const PageControllerDemo({Key? key}) : super(key: key);

  @override
  State<PageControllerDemo> createState() => _PageControllerDemoState();
}

class _PageControllerDemoState extends State<PageControllerDemo> with StatefulPropsMixin {
  late final _pages = PageControllerProp(this, viewportFraction: .5);

  void _handleBtnPressed() {
    _pages.controller.animateToPage(0, duration: const Duration(seconds: 1), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pages.controller,
            children: const [
              FlutterLogo(),
              FlutterLogo(),
              FlutterLogo(),
            ],
          ),
        ),
        TextButton(
            onPressed: _handleBtnPressed,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Animate To Index 1'),
            ))
      ],
    );
  }
}
