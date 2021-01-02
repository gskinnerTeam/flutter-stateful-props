import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

import 'package:stateful_props/stateful_props.dart';
import 'comparison_stack.dart';

/// ///////////////////////////////////////////////////
/// Optimized Rebuilds
/// //////////////////////////////////////////////////
/// Show how a ValueProp (or any prop) can be used to rebuild just portions of the tree.

class OptimizedRebuildsExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return ComparisonStack(
      texts: [
        "Shows how you can optimize builds using a `NotifiersListener`.",
        "1. Clicking Toggle or Increment will rebuild only the inner portion, while setState will build everything.",
        "2. The 100px tall box doesn't rebuild, even though it's inside the builder, as it's passed in as a cachedChild"
      ],
      //stateless: OptimizedRebuildsStateless(),
      stateful: OptimizedRebuildsStateful(),
      //classic: OptimizedRebuildsClassic(),
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

class OptimizedRebuildsStateful extends StatefulWidget {
  @override
  _OptimizedRebuildsStatefulState createState() => _OptimizedRebuildsStatefulState();
}

class _OptimizedRebuildsStatefulState extends State<OptimizedRebuildsStateful> with StatefulPropsMixin {
  IntProp _counter;
  BoolProp _toggle;

  @override
  void initProps() {
    _counter = addProp(IntProp(autoBuild: false));
    _toggle = addProp(BoolProp(autoBuild: false));
  }

  void rebuild() => setState(() {});

  @override
  Widget buildWithProps(BuildContext context) {
    return RandomColoredBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          OutlineButton(onPressed: rebuild, child: Text("setState")),
          OutlineButton(onPressed: () => _toggle.toggle(), child: Text("bool.toggle()")),
          OutlineButton(onPressed: () => _counter.increment(), child: Text("int.increment()")),
          // We can nest a build anywhere in the tree, ties to one or more Props
          NotifiersBuilder(
            [_counter, _toggle],
            // Provide a cached child
            child: RandomColoredBox(
                child: SizedBox(width: 100, height: 100, child: Center(child: Text("This is cached")))),
            builder: (_, cachedChild) {
              String content = "counter: ${_counter.value}, isToggled: ${_toggle.value}";
              return Column(children: [
                RandomColoredBox(child: Text(content)),
                cachedChild,
              ]);
            },
          )
        ],
      ),
    );
  }
}

//TODO: There is a pain point when trying to store a list of items in PropsWidget, for example, creating props from a list of changeNotifiers.
// Not sure how to solve... Some sort of ListProp<List<T>> could work? This could enable Restorable lists as well, which is pretty cool!

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
///
///
///

class RandomColoredBox extends StatelessWidget {
  const RandomColoredBox({Key key, this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: child,
      color: RandomColor().randomColor(colorBrightness: ColorBrightness.light),
    );
  }
}
