import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stateful_props/stateful_props.dart';
import 'comparison_stack.dart';

/// ///////////////////////////////////////////////////
/// Basic Builder Example
/// //////////////////////////////////////////////////
/// Show a Future and Layout Builder in use
///
class BasicBuilderExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return Provider<int>.value(
      value: 0,
      child: ComparisonStack(
        classic: BasicBuilderClassic(),
        stateful: BasicBuilderStateful(),
        stateless: BasicBuilderStateless(),
      ),
    );
  }
}

/// ///////////////////////////////////
/// Classic
/// //////////////////////////////////
class BasicBuilderClassic extends StatefulWidget {
  @override
  _BasicBuilderClassicState createState() => _BasicBuilderClassicState();
}

class _BasicBuilderClassicState extends State<BasicBuilderClassic> {
  Future<int> _someFuture;
  bool _isOver;
  @override
  void initState() {
    _someFuture = _loadData();
    super.initState();
  }

  // Wait 1 second, return random Integer
  Future<int> _loadData() => Future.delayed(Duration(seconds: 1), () => Random().nextInt(999));

  @override
  Widget build(BuildContext _) {
    return MouseRegion(
      onExit: (_) => setState(() => _isOver = false),
      onEnter: (_) => setState(() => _isOver = true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _someFuture = _loadData()),
        child: LayoutBuilder(builder: (lc, constraints) {
          return FutureBuilder<int>(
              future: _someFuture,
              builder: (fc, snapshot) {
                Size contextSize = Size(1, 1);
                RenderBox rb = fc.findRenderObject() as RenderBox;
                if (rb?.hasSize ?? false) {
                  contextSize = rb.size;
                }
                print("$this ${fc.watch<int>()}");
                return _Content(snapshot, constraints, contextSize);
              });
        }),
      ),
    );
  }
}

/// ///////////////////////////////////
/// State-ful Props
/// //////////////////////////////////
class BasicBuilderStateful extends StatefulWidget {
  @override
  _BasicBuilderStatefulState createState() => _BasicBuilderStatefulState();
}

class _BasicBuilderStatefulState extends State<BasicBuilderStateful> with StatefulPropsMixin {
  LayoutProp layout;
  FutureProp<int> someFuture;

  @override
  void initProps() {
    layout = addProp(LayoutProp(measureContext: true));
    someFuture = addProp(FutureProp(_loadData()));
    addProp(TapProp(() => someFuture.future = _loadData()));
  }

  // Wait 1 second, return random Integer
  Future<int> _loadData() => Future.delayed(Duration(seconds: 1), () => Random().nextInt(999));

  @override
  Widget buildWithProps(BuildContext context) {
    print("$this ${context.watch<int>()}");
    return _Content(someFuture.snapshot, layout.constraints, layout.contextSize);
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class BasicBuilderStateless extends PropsWidget {
  static const Ref<LayoutProp> _layout = Ref();
  static const Ref<FutureProp<int>> _someFuture = Ref();
  static const Ref<TapProp> _tap = Ref();

  LayoutProp get layout => use(_layout);
  FutureProp<int> get someFuture => use(_someFuture);

  @override
  void initProps() {
    addProp(_layout, LayoutProp(measureContext: true));
    addProp(_someFuture, FutureProp(_loadData()));
    addProp(_tap, TapProp(() => someFuture.future = _loadData()));
    print("$this ${context.watch<int>()}");
  }

  // Wait 1 second, return random Integer
  Future<int> _loadData() => Future.delayed(Duration(seconds: 1), () => Random().nextInt(999));

  @override
  Widget buildWithProps(BuildContext context) {
    print("$this ${context.watch<int>()}");
    return _Content(someFuture.snapshot, layout.constraints, layout.contextSize);
  }
}

/// ///////////////////////////////
/// Shared
Widget _Content(AsyncSnapshot<dynamic> snapshot, BoxConstraints constraints, Size contextSize) {
  bool hasLoaded = snapshot?.connectionState != ConnectionState.waiting;
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("parentWidth${constraints.maxWidth}, contextWith${contextSize.width}}"),
        Text("future=${hasLoaded ? snapshot.data : "Loading..."}")
      ],
    ),
  );
}
