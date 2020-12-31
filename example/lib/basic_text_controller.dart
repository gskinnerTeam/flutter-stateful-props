import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:stateful_props/stateful_props.dart';
import 'comparison_stack.dart';

/// ///////////////////////////////////////////////////
/// Basic TextController Example
/// //////////////////////////////////////////////////
/// Uses a TextEditProp to listen for textField changes, and an IntProp to count the number of change events

class BasicTextControllerExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return ComparisonStack(
      stateless: BasicTextControllerStateless(),
      stateful: BasicTextControllerStateful(),
      //classic: BasicTextControllerClassic(),
    );
  }
}

/// ///////////////////////////////////
/// Classic
/// //////////////////////////////////
//TODO ADD EXAMPLE

/// ///////////////////////////////////
/// State-ful Props
/// //////////////////////////////////

class BasicTextControllerStateful extends StatefulWidget {
  @override
  _BasicTextControllerStatefulState createState() => _BasicTextControllerStatefulState();
}

class _BasicTextControllerStatefulState extends State<BasicTextControllerStateful> with StatefulPropsMixin {
  TextEditProp _text1;
  IntProp _changeCount;

  @override
  void initProps() {
    _text1 = addProp(TextEditProp(text: "Hello!", onChanged: _handleTextChanged));
    _changeCount = addProp(IntProp());
  }

  void _handleTextChanged(prop) => _changeCount.value++;

  @override
  Widget buildWithProps(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${_changeCount.value}"),
          TextFormField(controller: _text1.controller),
        ],
      ),
    );
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class BasicTextControllerStateless extends PropsWidget {
  static Ref<TextEditProp> _text1 = Ref();
  static Ref<IntProp> _changeCount = Ref();

  @override
  void initProps() {
    addProp(_text1, TextEditProp(text: "Hello!", onChanged: _handleTextChanged));
    addProp(_changeCount, IntProp());
  }

  void _handleTextChanged(prop) => use(_changeCount).value++;

  @override
  Widget buildWithProps(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${use(_changeCount).value}"),
          TextFormField(controller: use(_text1).controller),
        ],
      ),
    );
  }
}
