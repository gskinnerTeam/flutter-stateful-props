import 'package:example/optimized_rebuilds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stateful_props/props/future_prop.dart';
import 'package:stateful_props/stateful_props.dart';

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
  Experiment("OptimizedBuilders", () => OptimizedRebuildsExample()),
  Experiment("Builders", () => BasicBuilderExample()),
  Experiment("Animator", () => BasicAnimatorExample()),
  Experiment("TextEdit", () => BasicTextControllerExample()),
  //TODO: DependencySync needs better controls for changing provided data
  Experiment("DependencySync", () => SyncExample()),
  Experiment("KeyboardListener", () => BasicKeyboardExample()),
  Experiment("FocusNode", () => BasicFocusExample()),
  Experiment("ScrollAndFadeIn", () => ScrollToTopExample()),
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

/*
* StreamBuilder
* MouseRegion
* LayoutBuilder
* Primitives
* GestureProp
* MultipleAnimations
*/

// "Hello World" Examples

class HelloWorld extends StatefulWidget {
  @override
  //_HelloFutureState createState() => _HelloFutureState();
  //_HelloTimerState createState() => _HelloTimerState();
  //_HelloTextEditingState createState() => _HelloTextEditingState();
  //_HelloTextEditingState createState() => _HelloTextEditingState();
  _HelloFocusNodeState createState() => _HelloFocusNodeState();
}

// Run a repeating timer that will be automatically cleaned up on dispose()
class _HelloTimerState extends State<HelloWorld> with StatefulPropsMixin {
  TimerProp timer;
  IntProp intProp;
  @override
  void initProps() {
    intProp = addProp(IntProp());
    // No need to cancel this, it's already handled
    timer = addProp(TimerProp(.5, (_) => intProp.value++, periodic: true));
  }

  @override
  Widget buildWithProps(BuildContext context) => Text("Ticks: ${intProp.value}");
}

// Create a couple TextFields with some FocusNodes:
class _HelloTextEditingState extends State<HelloWorld> with StatefulPropsMixin {
  TextEditProp textEdit1;

  @override
  void initProps() {
    textEdit1 = addProp(TextEditProp(onChanged: (prop) => print(prop.text)));
  }

  @override
  Widget buildWithProps(BuildContext context) => TextField(controller: textEdit1.controller);
}

// Create a FocusNode and count when it throws an event:
class _HelloFocusNodeState extends State<HelloWorld> with StatefulPropsMixin {
  FocusProp focus1;
  IntProp focusCount;

  @override
  void initProps() {
    focus1 = addProp(FocusProp(onChanged: (_) => focusCount.increment()));
    focusCount = addProp(IntProp());
  }

  @override
  Widget buildWithProps(BuildContext context) {
    return Column(
      children: [TextField(focusNode: focus1.node), TextField(), Text("FocusEvent Count: $focusCount")],
    );
  }
}

// Load a future when widget is mounted, and refresh it on tap
class _HelloFutureState extends State<HelloWorld> with StatefulPropsMixin {
  FutureProp<String> future;

  @override
  void initProps() {
    // Load a future when the widget is first mounted
    future = addProp(FutureProp(initial: _loadData()));
    // Refresh when the widget is tapped
    addProp(TapProp(() => future.value = _loadData()));
  }

  Future<String> _loadData() => Future.delayed(Duration(seconds: 1), () => "result");

  @override
  Widget buildWithProps(BuildContext context) => Text("${future.snapshot.hasData}");
}

class _HelloStreamState extends State<HelloWorld> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
