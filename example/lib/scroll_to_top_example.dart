import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';
import 'comparison_stack.dart';

/// ///////////////////////////////////////////////////
/// Basic Focus Example
/// //////////////////////////////////////////////////
/// Creates 2 focus nodes and counts the focus-outs and focus-ins

class ScrollToTopExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return ComparisonStack(
      stateless: ScrollOnStartStateless(),
      stateful: ScrollOnStartStateful(),
      //classic: ScrollOnStartClassic(),
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

class ScrollOnStartStateful extends StatefulWidget {
  @override
  _ScrollOnStartStatefulState createState() => _ScrollOnStartStatefulState();
}

class _ScrollOnStartStatefulState extends State<ScrollOnStartStateful> with StatefulPropsMixin {
  TextEditProp textProp;
  ScrollProp scrollProp;
  AnimationProp anim;

  @override
  void initProps() {
    textProp = addProp(TextEditProp(text: "Stateful Props are Cool!", onChanged: (v) => print(v)));
    scrollProp = addProp(ScrollProp(initialScrollOffset: 200));
    anim = addProp(AnimationProp(1, autoStart: false));
    // Fade in after a slight delay
    addProp(TimerProp(.2, (_) => anim.controller.forward()));
    // Select all text when the view is first shown
    textProp.controller.selection = TextSelection(baseOffset: 0, extentOffset: textProp.controller.text.length);
    //Scroll up 1 frame after the view is first shown
    scheduleMicrotask(() {
      scrollProp.controller.animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeOut);
    });
  }

  @override
  Widget buildWithProps(BuildContext context) => _Content(scrollProp, textProp, anim.value);
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class ScrollOnStartStateless extends PropsWidget {
  static Ref<TextEditProp> _textProp = Ref();
  static Ref<ScrollProp> _scrollProp = Ref();
  static Ref<AnimationProp> _anim = Ref();
  static Ref<TimerProp> _timer = Ref();

  @override
  void initProps() {
    final text = addProp(_textProp, TextEditProp(text: "Stateful Props are Cool!", onChanged: (v) => print(v)));
    addProp(_scrollProp, ScrollProp(initialScrollOffset: 200));
    addProp(_anim, AnimationProp(1, autoStart: false));
    // Fade in after a slight delay
    addProp(_timer, TimerProp(.2, (_) => use(_anim).controller.forward()));
    // Select all text when the view is first shown
    text.controller.selection = TextSelection(baseOffset: 0, extentOffset: text.controller.text.length);
    //Scroll up 1 frame after the view is first shown
    scheduleMicrotask(() {
      use(_scrollProp).controller.animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeOut);
    });
  }

  @override
  Widget buildWithProps(BuildContext context) => _Content(use(_scrollProp), use(_textProp), use(_anim).value);
}

/// ///////////////////////////////////////////
/// Shared
///
Widget _Content(ScrollProp scrollProp, TextEditProp textProp, double value) {
  return SingleChildScrollView(
    controller: scrollProp.controller,
    child: Opacity(
      opacity: value,
      child: Column(
        children: [
          TextFormField(controller: textProp.controller),
          ...List.generate(
            20,
            (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 400,
                height: 200,
                color: Colors.red.shade200,
                child: AnimatedBuilder(
                  animation: textProp.controller,
                  builder: (_, __) => Text(textProp.text),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
