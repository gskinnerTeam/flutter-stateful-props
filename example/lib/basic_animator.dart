import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stateful_props/stateful_props.dart';

import 'comparison_stack.dart';

/// ///////////////////////////////////////////////////
/// Basic Animator Example
/// //////////////////////////////////////////////////
/// Creates an Animator, and a Tween and restarts the Animator when tapped.
/// Uses helper method AnimationControllerProp.isComplete to update the view.

class BasicAnimatorExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    Duration duration1 = Duration(seconds: 1);
    Duration duration2 = Duration(seconds: 2);
    return Provider<Duration>.value(
      value: duration1,
      child: ComparisonStack(
        stateless: BasicAnimatorStateless(duration2),
        stateful: BasicAnimatorStateful(duration2),
        classic: BasicAnimatorClassic(duration2),
      ),
    );
  }
}

/// ///////////////////////////////////
/// Classic
/// //////////////////////////////////
class BasicAnimatorClassic extends StatefulWidget {
  BasicAnimatorClassic(this.duration);
  final Duration duration;
  @override
  _BasicAnimatorClassicState createState() => _BasicAnimatorClassicState();
}

class _BasicAnimatorClassicState extends State<BasicAnimatorClassic> with TickerProviderStateMixin {
  AnimationController anim1;
  AnimationController anim2;

  @override
  void initState() {
    super.initState();
    anim1 = AnimationController(vsync: this, duration: widget.duration);
    anim1.forward();
    anim1.addListener(() => setState(() {}));

    anim2 = AnimationController(vsync: this, duration: context.read());
    anim2.forward();
    anim2.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(BasicAnimatorClassic oldWidget) {
    if (oldWidget.duration != widget.duration) {
      anim1.duration = widget.duration;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    anim2.duration = context.read<Duration>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    anim1.dispose();
    anim2.dispose();
    super.dispose();
  }

  void _handlePress() {
    anim1.forward(from: 0);
    anim2.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    bool checkComplete(AnimationController a) =>
        a.status == AnimationStatus.completed || a.status == AnimationStatus.dismissed;
    bool isComplete = checkComplete(anim1) && checkComplete(anim2);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handlePress,
      child: _AnimatedContent(anim1, anim2, isComplete: isComplete),
    );
  }
}

/// ///////////////////////////////////
/// State-ful Props
/// //////////////////////////////////
class BasicAnimatorStateful extends StatefulWidget {
  BasicAnimatorStateful(this.duration);
  final Duration duration;
  @override
  _BasicAnimatorStatefulState createState() => _BasicAnimatorStatefulState();
}

class _BasicAnimatorStatefulState extends State<BasicAnimatorStateful> with StatefulPropsMixin {
  AnimationProp anim1;
  AnimationProp anim2;

  @override
  void initProps() {
    anim1 = syncProp((c, w) => AnimationProp(w.duration.seconds, autoStart: true));
    anim2 = syncProp((c, w) => AnimationProp((c.read<Duration>().seconds), autoStart: true));
    addProp(TapProp(_handlePress));
  }

  void _handlePress() {
    anim1.controller.forward(from: 0);
    anim2.controller.forward(from: 0);
  }

  @override
  Widget buildWithProps(BuildContext context) {
    return _AnimatedContent(
      anim1.controller,
      anim2.controller,
      isComplete: anim1.isComplete && anim2.isComplete,
    );
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class BasicAnimatorStateless extends PropsWidget<BasicAnimatorStateless> {
  BasicAnimatorStateless(this.duration);
  final Duration duration;

  static final Ref<AnimationProp> _anim1 = Ref();
  static final Ref<AnimationProp> _anim2 = Ref();
  static final Ref<TapProp> _tap = Ref();

  AnimationProp get anim1 => use(_anim1);
  AnimationProp get anim2 => use(_anim2);

  @override
  void initProps() {
    syncProp(_anim1, (c, w) => AnimationProp(w.duration.seconds, autoStart: true));
    syncProp(_anim2, (c, w) => AnimationProp(context.watch<Duration>().seconds, autoStart: true));
    addProp(_tap, TapProp(_handlePress));
  }

  void _handlePress() {
    anim1.controller.forward(from: 0);
    anim2.controller.forward(from: 0);
  }

  @override
  Widget buildWithProps(BuildContext context) {
    return _AnimatedContent(
      anim1.controller,
      anim2.controller,
      isComplete: anim1.isComplete && anim2.isComplete,
    );
  }
}

/// ////////////////////////////////////
/// SHARED
class _AnimatedContent extends StatelessWidget {
  const _AnimatedContent(this.controller1, this.controller2, {Key key, this.prop, this.isComplete}) : super(key: key);
  final AnimationProp prop;
  final AnimationController controller1;
  final AnimationController controller2;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    double animValue = controller1?.value ?? prop.value;
    return Container(
      padding: EdgeInsets.all(100),
      alignment: Alignment(0, animValue),
      child: Opacity(
          opacity: controller2.value,
          child: Text((isComplete ?? prop.isComplete) ? "Done! Click to animate" : "Wait for it...")),
    );
  }
}
