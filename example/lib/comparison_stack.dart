import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

// Shows up to 3 examples side by side and has a "Rebuild" btn that forces all children to rebuild.
// The forced rebuild can be overriden by passing a key directly. Examples that test dependencies will do this.
class ComparisonStack extends PropsWidget {
  ComparisonStack({Key key, this.texts, this.onPressed, this.stateless, this.stateful, this.classic}) : super(key: key);
  final PropsWidget stateless;
  final Widget stateful;
  final Widget classic;
  final VoidCallback onPressed;
  final List<String> texts;

  @override
  Widget buildWithProps(BuildContext context) {
    Widget _color(Color c, Widget child) => Container(color: c, child: child);
    Widget _header(String title) => Expanded(
          child: Container(
            color: Colors.white.withOpacity(.2),
            child: Center(child: Text(title)),
            height: 40,
          ),
        );
    return Stack(
      children: [
        // TOP MENU
        Row(
          children: [
            if (classic != null) _header("CLASSIC"),
            if (stateful != null) _header("STATE-FULL"),
            if (stateless != null) _header("STATE-LESS"),
          ],
        ),
        // CONTENT
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  key: key ?? ValueKey(Random().nextDouble()),
                  children: [
                    if (classic != null) Expanded(child: _color(Colors.grey.shade100, classic)),
                    if (stateful != null) Expanded(child: _color(Colors.red.shade100, stateful)),
                    if (stateless != null) Expanded(child: _color(Colors.green.shade100, stateless)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [if (texts != null) ...texts.map((e) => Text(e))],
                ),
              )
            ],
          ),
        ),
        // MIDDLE BTN
        Center(
          child: FlatButton(
            color: Colors.white,
            onPressed: onPressed ?? () => setState(() {}),
            child: Text("Rebuild"),
          ),
        ),
      ],
    );
  }
}
