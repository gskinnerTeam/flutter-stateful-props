import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stateful_props/stateful_props.dart';
import 'comparison_stack.dart';

/// ///////////////////////////////////////////////////
/// Sync dependencies example
/// //////////////////////////////////////////////////
// * AnimationController with context and widget dependencies.
// * Uses syncProp() so controller stays in sync with dependencies
// * Use `tweenInt` helper method to fade with a stepped fashion (10%, 20%, etc... )
// * Using `MouseRegionProp` to track mouseInfo like .isHovered, .localPosition etc
class SyncExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Deps deps = Provider.of(context);
    return ComparisonStack(
      stateless: BasicSyncStateless(deps.vsync),
      // Suppler ourselves as tickerProvider (TODO: This is not a good demo.. how else can we do this?? )
      stateful: BasicSyncStateful(deps.vsync),
      //classic: BasicSync(),
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

class BasicSyncStateful extends StatefulWidget {
  const BasicSyncStateful(this.vsync, {Key key}) : super(key: key);
  final TickerProvider vsync;

  @override
  _BasicSyncStatefulState createState() => _BasicSyncStatefulState();
}

class _BasicSyncStatefulState extends State<BasicSyncStateful> with StatefulPropsMixin {
  MouseRegionProp mouseProp;
  Animation<int> countTween;

  @override
  void initProps() {
    // Create Animation that is sync'd to some dependencies
    AnimationProp tapAnim = syncProp((c, w) {
      return AnimationProp(
        c.watch<Deps>().duration, // get duration from Provider
        vsync: w.vsync, // Get vsync from the current widget,
        autoStart: false,
      );
    });
    // Delayed start
    addProp(TimerProp(.1, (_) => tapAnim.controller.forward()));
    // Use syntactic sugar to easily add a tween curves and settings
    countTween = tapAnim.tweenInt(curve: Curves.easeOut, begin: 1, end: 10);
    // Add mousePos and tap handlers
    mouseProp = addProp(MouseRegionProp());
    addProp(TapProp(() => tapAnim.controller.forward(from: 0)));
  }

  Widget buildWithProps(BuildContext context) {
    // Calculate values
    double normalizedMouseX = mouseProp.normalizedPosition.dx;
    Color borderColor = Colors.black.withOpacity(normalizedMouseX);
    Color fillColor = Colors.red.shade800.withOpacity(countTween.value * .1);
    Color textColor = Colors.black.withOpacity(mouseProp.isHovered ? .5 : 1);
    String label = "${mouseProp.position}";
    //print("${countTween.value}");
    Deps deps = Provider.of(context);
    // Render
    return Container(
      decoration: BoxDecoration(color: fillColor, border: Border.all(color: borderColor, width: 10)),
      alignment: Alignment.center,
      child: Text("ticker: ${widget.vsync}, $label, duration: ${deps.duration}",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
    );
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class BasicSyncStateless extends PropsWidget<BasicSyncStateless> {
  BasicSyncStateless(this.vsync, {Key key}) : super(key: key);
  final TickerProvider vsync;

  static final Ref<MouseRegionProp> _mouseProp = Ref();
  static final Ref<ValueProp<Animation<int>>> _countTween = Ref();
  static final Ref<TimerProp> _timer = Ref();
  static final Ref<AnimationProp> _anim = Ref();
  static final Ref<TapProp> _tap = Ref();

  MouseRegionProp get mouseProp => use(_mouseProp);
  ValueProp<Animation<int>> get countTween => use(_countTween);

  @override
  void initProps() {
    // Create Animation that is sync'd to some dependencies
    final tapAnim = syncProp(_anim, (c, w) {
      return AnimationProp(
        c.watch<Deps>().duration, // get duration from Provider
        vsync: w.vsync, // Get vsync from the current widget,
        autoStart: false,
      );
    });
    // Delayed start
    addProp(_timer, TimerProp(.1, (_) => tapAnim.controller.forward()));
    // Create a tween and store it in a ValueProp
    Animation<int> intTween = tapAnim.tweenInt(curve: Curves.easeOut, begin: 1, end: 10);
    addProp(_countTween, ValueProp(initial: intTween));
    // Add mousePos and tap handlers
    addProp(_mouseProp, MouseRegionProp());
    addProp(_tap, TapProp(() => tapAnim.controller.forward(from: 0)));
  }

  Widget buildWithProps(BuildContext context) {
    // Calculate values
    double normalizedMouseX = mouseProp.normalizedPosition.dx;
    Color borderColor = Colors.black.withOpacity(normalizedMouseX);
    Color fillColor = Colors.black.withOpacity(countTween.value.value * .03);
    Color textColor = Colors.black.withOpacity(mouseProp.isHovered ? .5 : 1);
    String label = "${mouseProp.position}";
    //print("${countTween.value}");
    Deps deps = Provider.of(context);
    // Render
    return Container(
      decoration: BoxDecoration(color: fillColor, border: Border.all(color: borderColor, width: 10)),
      alignment: Alignment.center,
      child: Text("ticker: $vsync, $label, duration: ${deps.duration}",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
    );
  }
}
