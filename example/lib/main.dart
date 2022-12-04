import 'package:example/examples/animations.dart';
import 'package:example/examples/counter.dart';
import 'package:example/examples/focus.dart';
import 'package:example/examples/logic_reuse.dart';
import 'package:example/examples/future.dart';
import 'package:example/examples/page_controller.dart';
import 'package:example/examples/scroll_controller.dart';
import 'package:example/examples/stream.dart';
import 'package:example/examples/text_editing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

void main() {
  runApp(const App());

  /// TODO:
  /// PageController
  /// ScrollController
  /// Stream
  /// StreamController
  /// TabController
  /// TextEditingController
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  List<Widget> get children => [
        const LogicReuseDemo(),
        const FuturePropDemo(),
        const ValuePropDemo(),
        const AnimationsDemo(),
        const FocusDemo(),
        const PageControllerDemo(),
        const ScrollControllerDemo(),
        const TextEditingDemo(),
        const StreamDemo(),
      ];

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with StatefulPropsMixin {
  late final _tabs = TabControllerProp(this, length: widget.children.length);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CustomScrollBehavior(),
      home: Builder(builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabs.controller,
                  children: widget.children.map((e) => Center(child: e)).toList(),
                ),
              ),
              TabBar(
                controller: _tabs.controller,
                tabs: List.generate(
                  widget.children.length,
                  (i) => Text(
                    widget.children[i].toString().replaceFirst('Demo', ''),
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}
