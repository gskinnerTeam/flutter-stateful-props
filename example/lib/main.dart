import 'package:example/optimized_rebuilds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:stateful_props/props/future_prop.dart';
import 'package:stateful_props/stateful_props.dart';

import 'basic_animator.dart';
import 'basic_builders.dart';
import 'basic_focus.dart';
import 'basic_keyboard.dart';
import 'basic_text_controller.dart';
import 'scroll_to_top_example.dart';
import 'sync_props_example.dart';

export 'comparison_stack.dart';

void main() {
  runApp(MaterialApp(home: Scaffold(body: StatefulPropsDemo())));
}

// Create a list of experiments/tests so we can make a tab-menu from them.
class Experiment {
  final String title;
  final Widget Function() builder;
  Experiment(this.title, this.builder);
}

List<Experiment> widgets = [
  Experiment("OptimizedBuilders", () => OptimizedRebuildsExample()),
  Experiment("Builders", () => BasicBuilderExample()),
  Experiment("Animator", () => BasicAnimatorExample()),
  Experiment("TextEdit", () => BasicTextControllerExample()),
  //TODO: DependencySync needs better controls for changing provided data
  Experiment("DependencySync", () => SyncExample()),
  Experiment("KeyboardListener", () => BasicKeyboardExample()),
  Experiment("FocusNode", () => BasicFocusExample()),
  Experiment("ScrollAndFadeIn", () => ScrollToTopExample()),
];

// Demo wraps a bunch of tests
class StatefulPropsDemo extends StatefulWidget {
  @override
  _StatefulPropsDemoState createState() => _StatefulPropsDemoState();
}

class _StatefulPropsDemoState extends State<StatefulPropsDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Create a list of btns for each experiment
    List<Widget> bottomBtns = List.generate(widgets.length, (index) => Expanded(child: _buildBtn(index)));
    // Provide a ChangeNotifier any of the Examples can use
    return ChangeNotifierProvider(
      create: (_) => Deps(),
      // Provide root restoration scope in case some of the demos want to test it
      child: RootRestorationScope(
        restorationId: "statefulDemo",
        child: Row(
          children: [
            /// ///////////////////////////
            /// Left Menu (Provider Config)
            ProviderMenu(),
            Expanded(
              child: Column(children: [
                /// ///////////////////////////
                /// Main Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: widgets[_index].builder.call(),
                  ),
                ),

                /// ///////////////////////////
                /// Bottom Menu
                Row(mainAxisAlignment: MainAxisAlignment.center, children: bottomBtns)
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(int index) {
    return FlatButton(
      padding: EdgeInsets.symmetric(vertical: 40),
      onPressed: () => setState(() => _index = index),
      child: Text(
        widgets[index].title,
        style: TextStyle(fontWeight: _index == index ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}

class ProviderMenu extends StatefulWidget {
  @override
  _ProviderMenuState createState() => _ProviderMenuState();
}

class _ProviderMenuState extends State<ProviderMenu> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Deps deps = Provider.of(context);
    return Container(
      padding: EdgeInsets.all(24),
      color: Colors.grey.shade300,
      child: Column(
        children: [
          Text("Provided Values", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          OutlineButton(
            child: Text("Toggle: ${deps.toggle}"),
            onPressed: () => deps.toggle = !deps.toggle,
          ),
          OutlineButton(
            child: Text("Duration: ${deps.duration}"),
            onPressed: () {
              deps.duration++;
              if (deps.duration > 3) deps.duration = .5;
            },
          ),
          OutlineButton(
            child: Text("Inject Vsync: ${deps.vsync == null ? "false" : "true"}"),
            onPressed: () {
              deps.vsync = deps.vsync == null ? this : null;
            },
          ),
        ],
      ),
    );
  }
}

class Deps extends ChangeNotifier {
  TickerProvider _vsync;
  double _duration = 1;
  bool _toggle = false;

  bool get toggle => _toggle;
  set toggle(bool toggle) {
    _toggle = toggle;
    notifyListeners();
  }

  double get duration => _duration;
  set duration(double duration) {
    _duration = duration;
    notifyListeners();
  }

  TickerProvider get vsync => _vsync;
  set vsync(TickerProvider vsync) {
    _vsync = vsync;
    notifyListeners();
  }
}

Deps deps = Deps();
