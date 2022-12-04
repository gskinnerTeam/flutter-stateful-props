import 'package:flutter/material.dart';
import 'package:reactives/stateful_props.dart';

class AnimationsDemo extends StatefulWidget {
  const AnimationsDemo({Key? key}) : super(key: key);

  @override
  State<AnimationsDemo> createState() => _AnimationsDemoState();
}

class _AnimationsDemoState extends State<AnimationsDemo> with StatefulPropsMixin {
  late final _anim1 = AnimationControllerProp(this, const Duration(seconds: 3));

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _anim1.controller.forward(from: 0),
      child: FadeTransition(
        opacity: _anim1.controller,
        child: const FlutterLogo(size: 200),
      ),
    );
  }
}
