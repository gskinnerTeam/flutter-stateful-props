import 'package:flutter/material.dart';

import 'package:stateful_props/stateful_props.dart';
import 'comparison_stack.dart';

/// ///////////////////////////////////////////////////
/// Basic Focus Example
/// //////////////////////////////////////////////////
/// Creates 2 focus nodes and counts the focus-outs and focus-ins.
/// Rebuild the view and display the counts when they change

class BasicFocusExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return ComparisonStack(
      stateless: BasicFocusStateless(),
      stateful: BasicFocusStateful(),
      //classic: BasicFocusClassic(),
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

class BasicFocusStateful extends StatefulWidget {
  @override
  _BasicFocusStatefulState createState() => _BasicFocusStatefulState();
}

class _BasicFocusStatefulState extends State<BasicFocusStateful> with StatefulPropsMixin {
  FocusProp node1;
  FocusProp node2;
  IntProp _focusInCount;
  IntProp _focusOutCount;
  @override
  void initProps() {
    _focusInCount = addProp(IntProp());
    _focusOutCount = addProp(IntProp());
    node1 = addProp(FocusProp(onChanged: _handleFocus));
    node2 = addProp(FocusProp(onChanged: _handleFocus));
  }

  @override
  Widget buildWithProps(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100),
        Text("_focusInCount: ${_focusInCount.value}"),
        Text("_focusOutCount: ${_focusOutCount.value}"),
        TextFormField(focusNode: node1.node),
        TextFormField(focusNode: node2.node),
      ],
    );
  }

  void _handleFocus(FocusProp prop) {
    prop.hasFocus ? _focusInCount.value++ : _focusOutCount.value++;
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class BasicFocusStateless extends PropsWidget {
  static Ref<FocusProp> node1 = Ref();
  static Ref<FocusProp> node2 = Ref();
  static Ref<IntProp> _focusInCount = Ref();
  static Ref<IntProp> _focusOutCount = Ref();

  @override
  void initProps() {
    addProp(_focusInCount, IntProp());
    addProp(_focusOutCount, IntProp());
    addProp(node1, FocusProp(onChanged: _handleFocus));
    addProp(node2, FocusProp(onChanged: _handleFocus));
  }

  @override
  Widget buildWithProps(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100),
        Text("_focusInCount: ${use(_focusInCount).value}"),
        Text("_focusOutCount: ${use(_focusOutCount).value}"),
        TextFormField(focusNode: use(node1).node),
        TextFormField(focusNode: use(node2).node),
      ],
    );
  }

  void _handleFocus(FocusProp prop) {
    prop.hasFocus ? use(_focusInCount).value++ : use(_focusOutCount).value++;
  }
}
