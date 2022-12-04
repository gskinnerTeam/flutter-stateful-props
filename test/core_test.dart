import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stateful_props/stateful_props.dart';

void main() {
  testWidgets('intProp, core', (tester) async {
    int buildCount = 0, changeCount = 0;
    final manager = TestWidget(onSetState: () => buildCount++);
    await tester.pumpWidget(manager);
    var iProp = IntProp(manager.state, initial: 1, onChange: (oldV, newV) {
      expect(oldV, 1);
      expect(newV, 10);
      changeCount++;
    });
    expect(iProp.value, 1);
    iProp.value = 10;
    await tester.pump();
    expect(buildCount, 1);
    expect(changeCount, 1);
    expect(iProp.value, 10);
  });

  testWidgets('intProp, autobuild=false', (tester) async {
    int buildCount = 0;
    final manager = TestWidget(onSetState: () => buildCount++);
    await tester.pumpWidget(manager);
    var iProp = IntProp(manager.state, autoBuild: false);
    iProp.value = 10;
    await tester.pump();
    expect(buildCount, 0);
  });
}

// Test that a scroll controller was made, and with the right options
// Test that onChange is called,
// Test autoBuild

class TestWidget extends StatefulWidget {
  TestWidget({this.onSetState});
  final VoidCallback? onSetState;
  late final _TestWidgetState state;

  @override
  State<TestWidget> createState() {
    state = _TestWidgetState();
    return state;
  }
}

class _TestWidgetState extends State<TestWidget> with StatefulPropsMixin {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void setState(VoidCallback fn) {
    widget.onSetState?.call();
    super.setState(fn);
  }
}
