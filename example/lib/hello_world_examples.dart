/*
TODO
* StreamBuilder
* MouseRegion
* LayoutBuilder
* Primitives
* GestureProp
* MultipleAnimations
*/

// A bunch of ultra-simple "Hello World" style Examples

import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

// Uncomment one of the states below to preview it:
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

//TODO: Implement Streams
class _HelloStreamState extends State<HelloWorld> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
