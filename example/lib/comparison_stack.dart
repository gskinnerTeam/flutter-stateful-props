import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

class ComparisonStack extends PropsWidget {
  ComparisonStack({this.stateless, this.stateful, this.classic});
  final PropsWidget stateless;
  final Widget stateful;
  final Widget classic;

  @override
  Widget buildWithProps(BuildContext context) {
    Widget _color(Color c, Widget child) => Container(color: c, child: child);
    Widget _header(String title) =>
        Expanded(child: Container(color: Colors.white.withOpacity(.2), child: Center(child: Text(title)), height: 40));
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(key: ValueKey(Random().nextDouble()), children: [
            if (classic != null) Expanded(child: _color(Colors.grey.shade100, classic)),
            if (stateful != null) Expanded(child: _color(Colors.red.shade100, stateful)),
            if (stateless != null) Expanded(child: _color(Colors.green.shade100, stateless)),
          ]),
        ),
        Center(
          child: FlatButton(
            color: Colors.white,
            onPressed: () => setState(() {}),
            child: Text("Rebuild"),
          ),
        ),
        Row(
          children: [
            if (classic != null) _header("CLASSIC"),
            if (stateful != null) _header("STATE-FULL"),
            if (stateless != null) _header("STATE-LESS"),
          ],
        )
      ],
    );
  }
}
