import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'stateful_prop_demo.dart';
import 'dart:math';

import 'package:flutter/material.dart';

import 'basic_animator.dart';
import 'basic_builders.dart';
import 'basic_focus.dart';
import 'basic_keyboard.dart';
import 'basic_text_controller.dart';
import 'scroll_to_top_example.dart';
import 'sync_props_example.dart';

export 'comparison_stack.dart';

void main() {
  runApp(MaterialApp(home: Scaffold(body: StatefulPropsDemo())));
}

// Create a list of experiments/tests so we can make a tab-menu from them.
class Experiment {
  final String title;
  final Widget Function() builder;
  Experiment(this.title, this.builder);
}

List<Experiment> widgets = [
  Experiment("BasicBuilderExample", () => BasicBuilderExample()),
  Experiment("BasicAnimator", () => BasicAnimatorExample()),
  Experiment("BasicTextController", () => BasicTextControllerExample()),
  Experiment("BasicSync", () => SyncExample()),
  Experiment("KeyboardListener", () => BasicKeyboardExample()),
  Experiment("FocusNode", () => BasicFocusExample()),
  Experiment("ScrollToTopAndFadeIn", () => ScrollToTopExample()),
];

// Demo wraps a bunch of tests
class StatefulPropsDemo extends StatefulWidget {
  @override
  _StatefulPropsDemoState createState() => _StatefulPropsDemoState();
}

class _StatefulPropsDemoState extends State<StatefulPropsDemo> with SingleTickerProviderStateMixin {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    Widget _makeBtn(int index) => FlatButton(
          onPressed: () => setState(() => _index = index),
          child: Text(widgets[index].title,
              style: TextStyle(fontWeight: _index == index ? FontWeight.bold : FontWeight.normal)),
          padding: EdgeInsets.symmetric(vertical: 40),
        );
    return RootRestorationScope(
      restorationId: "statefulDemo",
      child: Column(children: [
        // Content
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: widgets[_index].builder.call(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widgets.length, (index) {
            return Expanded(child: _makeBtn(index));
          }),
        )
      ]),
    );
  }
}
