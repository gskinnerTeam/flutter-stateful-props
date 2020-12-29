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
class SyncExample extends StatefulWidget {
  @override
  _SyncExampleState createState() => _SyncExampleState();
}

class _SyncExampleState extends State<SyncExample> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Provider<Duration>.value(
      // Inject something with provider
      value: Duration(seconds: 1),
      child: ComparisonStack(
        stateless: BasicSyncStateless(this),
        // Suppler ourselves as tickerProvider (TODO: This is not a good demo.. how else can we do this?? )
        stateful: BasicSyncStateful(this),
        //classic: BasicSync(),
      ),
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
        c.read<Duration>().inMilliseconds * .001, // get duration from Provider
        vsync: (w as BasicSyncStateful).vsync, // Get vsync from the current widget,
      );
    });
    // Delayed start
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      tapAnim.controller.forward();
    });
    // Use syntactic sugar to easily add a tween curves and settings
    countTween = tapAnim.tweenInt(curve: Curves.easeOut, begin: 1, end: 10);
    // Listen for mouseInfo
    mouseProp = addProp(MouseRegionProp());
    // Listen for tap
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

    // Render
    return Container(
      decoration: BoxDecoration(color: fillColor, border: Border.all(color: borderColor, width: 10)),
      alignment: Alignment.center,
      child: Text("$label, duration: ${(context.watch<Duration>()).inSeconds}",
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

  static Ref<MouseRegionProp> _mouseProp = Ref();
  static Ref<ValueProp<Animation<int>>> _countTween = Ref();
  static Ref<AnimationProp> _anim = Ref();
  static Ref<TapProp> _tap = Ref();

  @override
  void initProps() {
    // Create Animation that is sync'd to some dependencies
    final tapAnim = syncProp(_anim, (c, w) {
      return AnimationProp(
        1, // Provider.of<Duration>(c).inMilliseconds * .001, // get duration from Provider
        vsync: w.vsync, // Get vsync from the current widget,
      );
    });
    // Delayed start
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      tapAnim.controller.forward();
    });
    // Use syntactic sugar to easily add a tween curves and settings
    Animation<int> intTween = tapAnim.tweenInt(curve: Curves.easeOut, begin: 1, end: 10);
    addProp(_countTween, ValueProp(intTween));
    // Listen for mouseInfo
    addProp(_mouseProp, MouseRegionProp());
    // Listen for tap
    addProp(_tap, TapProp(() => tapAnim.controller.forward(from: 0)));
  }

  Widget buildWithProps(BuildContext context) {
    // Calculate values
    final mouseProp = use(_mouseProp);
    final countTween = use(_countTween);
    double normalizedMouseX = mouseProp.normalizedPosition.dx;
    Color borderColor = Colors.black.withOpacity(normalizedMouseX);
    Color fillColor = Colors.black.withOpacity(countTween.value.value * .03);
    Color textColor = Colors.black.withOpacity(mouseProp.isHovered ? .5 : 1);
    String label = "${mouseProp.position}";
    //print("${countTween.value}");

    // Render
    return Container(
      decoration: BoxDecoration(color: fillColor, border: Border.all(color: borderColor, width: 10)),
      alignment: Alignment.center,
      child: Text("$label, duration: ${(context.watch<Duration>()).inSeconds}",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
    );
  }
}
