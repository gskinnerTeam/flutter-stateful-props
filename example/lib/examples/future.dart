import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reactives/stateful_props.dart';

class FuturePropDemo extends StatefulWidget {
  const FuturePropDemo({Key? key}) : super(key: key);

  @override
  State<FuturePropDemo> createState() => _FuturePropDemoState();
}

class _FuturePropDemoState extends State<FuturePropDemo> with StatefulPropsMixin {
  /// FutureProp holds an initial future, and exposes its current state as a snapshot.
  late final _future = FutureProp<String>(this, _loadSomething());

  /// Easily re-assign new futures and auto-build the widget.
  void refresh() => _future.future = _loadSomething();

  /// Some mock future...
  Future<String> _loadSomething() async {
    await Future.delayed(const Duration(seconds: 1));
    return Random().nextInt(9999).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('data: ${_future.snapshot.data ?? 'null'}'),
        Text('connection state: ${_future.snapshot.connectionState}'),
        CheckboxListTile(
            value: _future.preserveState,
            onChanged: (value) {
              setState(() => _future.preserveState = !_future.preserveState);
            },
            title: const Text('PRESERVE STATE')),
        OutlinedButton(onPressed: refresh, child: const Text('REFRESH')),
      ],
    );
  }
}
